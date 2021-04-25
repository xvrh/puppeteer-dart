import 'package:petitparser/petitparser.dart';

// ignore_for_file: non_constant_identifier_names

/// Take a Javascript function shorthand syntax and convert it to a classical
/// function declaration.
/// Returns the string as it if this is already a classical function declaration
/// Returns null if we cannot parse recognize the declaration
String? convertToFunctionDeclaration(String javascript) {
  var grammar = JsGrammarDefinition().build();
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

class JsGrammarDefinition extends GrammarDefinition {
  Parser token(input) {
    if (input is String) {
      input = input.length == 1 ? char(input) : string(input);
    } else if (input is Parser Function()) {
      input = ref0(input);
    }
    if (input is! Parser || input is TrimmingParser || input is TokenParser) {
      throw ArgumentError('Invalid token parser: $input');
    }
    return input.token().trim(ref0(HIDDEN_STUFF));
  }

  @override
  Parser start() => ref0(functionDeclarationOrShortHand).end();

  Parser functionDeclarationOrShortHand() =>
      ref0(functionDeclaration) | ref0(functionShorthand);

  Parser functionDeclaration() =>
      ref1(token, 'async').optional() &
      ref1(token, 'function').map((_) => _isFunction) &
      ref0(identifier).optional() &
      ref0(arguments) &
      ref1(token, '{') &
      ref0(body);

  Parser functionShorthand() =>
      ref1(token, 'async').optional().map((t) => t != null ? _isAsync : null) &
      ref0(functionShorthandArguments).flatten().map((t) => _Arguments(t)) &
      ref1(token, '=>') &
      ref1(token, '{')
          .optional()
          .map((v) => v != null ? _hasBodyStatements : null) &
      ref0(body);

  Parser functionShorthandArguments() => ref0(arguments) | ref0(identifier);

  Parser arguments() =>
      ref1(token, '(') & ref0(argumentList).optional() & ref1(token, ')');

  Parser argumentList() => ref0(argument).separatedBy(ref1(token, ','));

  Parser argument() => ref1(token, '...').optional() & ref0(identifier);

  Parser identifier() => ref1(token, ref0(IDENTIFIER))
      .map((v) => v.value[0] + v.value[1].join(''));

  Parser body() => ref0(any).star().map((v) => _FunctionBody(v.join('')));

  Parser IDENTIFIER() => ref0(IDENTIFIER_START) & ref0(IDENTIFIER_PART).star();

  Parser IDENTIFIER_START() => ref0(IDENTIFIER_START_NO_DOLLAR) | char('\$');

  Parser IDENTIFIER_START_NO_DOLLAR() => ref0(LETTER) | char('_');

  Parser IDENTIFIER_PART() => ref0(IDENTIFIER_START) | ref0(DIGIT);

  Parser LETTER() => letter();

  Parser DIGIT() => digit();

  Parser NEWLINE() => pattern('\n\r');

  Parser HIDDEN_STUFF() =>
      ref0(WHITESPACE) | ref0(SINGLE_LINE_COMMENT) | ref0(MULTI_LINE_COMMENT);

  Parser WHITESPACE() => whitespace();

  Parser SINGLE_LINE_COMMENT() =>
      string('//') & ref0(NEWLINE).neg().star() & ref0(NEWLINE).optional();

  Parser MULTI_LINE_COMMENT() =>
      string('/*') &
      (ref0(MULTI_LINE_COMMENT) | string('*/').neg()).star() &
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
