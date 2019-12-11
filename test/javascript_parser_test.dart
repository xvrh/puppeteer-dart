import 'package:puppeteer/src/javascript_function_parser.dart';
import 'package:test/test.dart';

void main() {
  test('Returns function declaration as it', () {
    var declarations = [
      '''
// some comment
function() {
  console.log('xx');
}
''',
      '''
// some comment
/* som ecom

 */
 
function() {
  console.log('xx');
}
''',
      '/* c */  function () { return true; }',
      'function _() { return true; }',
      'function withName() { return true; }',
      'async function  () { return true; }',
      'async function() { return true; }',
      'async function withName() { return true; }',
      'async function withName(abc, ...args) { return true; }',
    ];

    for (var declaration in declarations) {
      expect(convertToFunctionDeclaration(declaration), equals(declaration));
    }
  });

  test('Convert ', () {
    var declarations = {
      '() => true;': 'function() { return true; }',
      '(a) => 2;': 'function(a) { return 2; }',
      '(a, bcc, cddd) => true;': 'function(a, bcc, cddd) { return true; }',
      '(a, bcc, cddd, ...args) => true;':
          'function(a, bcc, cddd, ...args) { return true; }',
      'a => true;': 'function(a ){ return true; }',
      '(a) => { /**/ return  false; }': 'function(a) { return  false; }',
      '''(a) => {
document.query();
return  false;
}
''': '''function(a) { document.query();
return  false;
}
''',
      '''
async () => {
      return await compute(9, 4);
      }''': '''
async function() { return await compute(9, 4);
      }''',
      '''
async () => await compute(9, 4);''': '''
async function() { return await compute(9, 4); }'''
    };
    for (var declaration in declarations.entries) {
      expect(convertToFunctionDeclaration(declaration.key),
          equals(declaration.value));
    }
  });
}
