import 'package:petitparser/petitparser.dart';

// ignore_for_file: non_constant_identifier_names

/// Take a Javascript function shorthand syntax and convert it to a classical
/// function declaration.
/// Returns the string as it if this is already a classical function declaration
/// Returns null if we cannot parse recognize the declaration
String convertToFunctionDeclaration(String javascript) {
  JsGrammar grammar = JsGrammar();
  var result = grammar.parse(javascript);

  if (result.isSuccess) {
    List tokens = result.value;

    if (tokens.contains(_isFunction)) {
      return javascript;
    } else {
      bool hasBodyStatement = tokens.contains(_hasBodyStatements);
      _Arguments arguments = tokens.singleWhere((t) => t is _Arguments);
      _FunctionBody functionBody =
          tokens.singleWhere((t) => t is _FunctionBody);
      bool isAsync = tokens.contains(_isAsync);

      String body = hasBodyStatement
          ? '{ ' + functionBody.value
          : '{ return ${functionBody.value} }';

      String argumentString = arguments.arguments;
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
      input = input.length == 1 ? char(input) : string(input);
    } else if (input is Function) {
      input = ref(input);
    }
    if (input is! Parser || input is TrimmingParser || input is TokenParser) {
      throw ArgumentError('Invalid token parser: $input');
    }
    return input.token().trim(ref(HIDDEN_STUFF));
  }

  @override
  start() => ref(functionDeclarationOrShortHand).end();

  functionDeclarationOrShortHand() =>
      ref(functionDeclaration) | ref(functionShorthand);

  functionDeclaration() =>
      ref(token, 'async').optional() &
      ref(token, 'function').map((_) => _isFunction) &
      ref(identifier).optional() &
      ref(arguments) &
      ref(token, '{') &
      ref(body);

  functionShorthand() =>
      ref(token, 'async').optional().map((t) => t != null ? _isAsync : null) &
      ref(functionShorthandArguments).flatten().map((t) => _Arguments(t)) &
      ref(token, '=>') &
      ref(token, '{')
          .optional()
          .map((v) => v != null ? _hasBodyStatements : null) &
      ref(body);

  functionShorthandArguments() => ref(arguments) | ref(identifier);

  arguments() =>
      ref(token, '(') & ref(argumentList).optional() & ref(token, ')');

  argumentList() => ref(argument).separatedBy(ref(token, ','));

  argument() => ref(token, '...').optional() & ref(identifier);

  identifier() =>
      ref(token, ref(IDENTIFIER)).map((v) => v.value[0] + v.value[1].join(''));

  body() => ref(any).star().map((v) => _FunctionBody(v.join('')));

  IDENTIFIER() => ref(IDENTIFIER_START) & ref(IDENTIFIER_PART).star();

  HEX_DIGIT() => pattern('0-9a-fA-F');

  IDENTIFIER_START() => ref(IDENTIFIER_START_NO_DOLLAR) | char('\$');

  IDENTIFIER_START_NO_DOLLAR() => ref(LETTER) | char('_');

  IDENTIFIER_PART() => ref(IDENTIFIER_START) | ref(DIGIT);

  LETTER() => letter();

  DIGIT() => digit();

  NEWLINE() => pattern('\n\r');

  HIDDEN() => ref(HIDDEN_STUFF).plus();

  HIDDEN_STUFF() =>
      ref(WHITESPACE) | ref(SINGLE_LINE_COMMENT) | ref(MULTI_LINE_COMMENT);

  WHITESPACE() => whitespace();

  SINGLE_LINE_COMMENT() =>
      string('//') & ref(NEWLINE).neg().star() & ref(NEWLINE).optional();

  MULTI_LINE_COMMENT() =>
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
  toString() => value;
}

class _Arguments {
  final String arguments;

  _Arguments(this.arguments);
}
