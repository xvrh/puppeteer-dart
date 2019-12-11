import 'package:petitparser/petitparser.dart';

// ignore_for_file: non_constant_identifier_names

/// Take a Javascript function shorthand syntax and convert it to a classical
/// function declaration.
/// Returns the string as it if this is already a classical function declaration
/// Returns null if we cannot parse recognize the declaration
String convertToFunctionDeclaration(String javascript) {
  var grammar = JsGrammar();
  var result = grammar.parse(javascript);

  if (result.isSuccess) {
    var tokens = result.value as List;

    if (tokens.contains(_isFunction)) {
      return javascript;
    } else {
      var hasBodyStatement = tokens.contains(_hasBodyStatements);
      var arguments = tokens.whereType<_Arguments>().single;
      var functionBody = tokens.whereType<_FunctionBody>().single;
      var isAsync = tokens.contains(_isAsync);

      var body = hasBodyStatement
          ? '{ ${functionBody.value}'
          : '{ return ${functionBody.value} }';

      var argumentString = arguments.arguments;
      if (!argumentString.startsWith('(')) {
        argumentString = '($argumentString)';
      }

      return '${isAsync ? 'async ' : ''}function$argumentString$body';
    }
  } else {
    return null;
  }
}

class JsGrammar extends GrammarParser {
  JsGrammar() : super(JsGrammarDefinition());
}

class JsGrammarDefinition extends GrammarDefinition {
  Parser token(input) {
    if (input is String) {
      input = input.length == 1 ? char(input) : string(input as String);
    } else if (input is Function) {
      input = ref(input as Function);
    }
    if (input is! Parser || input is TrimmingParser || input is TokenParser) {
      throw ArgumentError('Invalid token parser: $input');
    }
    return (input as Parser).token().trim(ref(HIDDEN_STUFF));
  }

  @override
  Parser start() => ref(functionDeclarationOrShortHand).end();

  Parser functionDeclarationOrShortHand() =>
      ref(functionDeclaration) | ref(functionShorthand);

  Parser functionDeclaration() =>
      ref(token, 'async').optional() &
      ref(token, 'function').map((_) => _isFunction) &
      ref(identifier).optional() &
      ref(arguments) &
      ref(token, '{') &
      ref(body);

  Parser functionShorthand() =>
      ref(token, 'async').optional().map((t) => t != null ? _isAsync : null) &
      ref(functionShorthandArguments).flatten().map((t) => _Arguments(t)) &
      ref(token, '=>') &
      ref(token, '{')
          .optional()
          .map((v) => v != null ? _hasBodyStatements : null) &
      ref(body);

  Parser functionShorthandArguments() => ref(arguments) | ref(identifier);

  Parser arguments() =>
      ref(token, '(') & ref(argumentList).optional() & ref(token, ')');

  Parser argumentList() => ref(argument).separatedBy(ref(token, ','));

  Parser argument() => ref(token, '...').optional() & ref(identifier);

  Parser identifier() =>
      ref(token, ref(IDENTIFIER)).map((v) => v.value[0] + v.value[1].join(''));

  Parser body() => ref(any).star().map((v) => _FunctionBody(v.join('')));

  Parser IDENTIFIER() => ref(IDENTIFIER_START) & ref(IDENTIFIER_PART).star();

  Parser IDENTIFIER_START() => ref(IDENTIFIER_START_NO_DOLLAR) | char('\$');

  Parser IDENTIFIER_START_NO_DOLLAR() => ref(LETTER) | char('_');

  Parser IDENTIFIER_PART() => ref(IDENTIFIER_START) | ref(DIGIT);

  Parser LETTER() => letter();

  Parser DIGIT() => digit();

  Parser NEWLINE() => pattern('\n\r');

  Parser HIDDEN_STUFF() =>
      ref(WHITESPACE) | ref(SINGLE_LINE_COMMENT) | ref(MULTI_LINE_COMMENT);

  Parser WHITESPACE() => whitespace();

  Parser SINGLE_LINE_COMMENT() =>
      string('//') & ref(NEWLINE).neg().star() & ref(NEWLINE).optional();

  Parser MULTI_LINE_COMMENT() =>
      string('/*') &
      (ref(MULTI_LINE_COMMENT) | string('*/').neg()).star() &
      string('*/');
}

final _isFunction = Object();
final _hasBodyStatements = Object();
final _isAsync = Object();

class _FunctionBody {
  final String value;

  _FunctionBody(this.value);

  @override
  String toString() => value;
}

class _Arguments {
  final String arguments;

  _Arguments(this.arguments);
}
