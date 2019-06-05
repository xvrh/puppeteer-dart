main() {
  var result = _input
      .replaceAll('describe(', 'group(')
      .replaceAll('it(', 'test(')
      .replaceAll('it_fails_ffox(', 'test(')
      .replaceAll('.PREFIX', '.prefix')
      .replaceAll('.EMPTY_PAGE', '.emptyPage')
      .replaceAll('.CROSS_PROCESS_PREFIX', '.crossProcessPrefix')
      .replaceAll('const ', 'var ')
      .replaceAllMapped(RegExp(r'.evaluate\((.*=>[^\(\),]+)\)'), (m) {
        var content = m.group(1);
        var quote = content.contains("'") ? '"' : "'";
        return '.evaluate($quote$content$quote)';
      })
      .replaceAll(').toBe(true', ', isTrue')
      .replaceAll(').toBe(false', ', isFalse')
      .replaceAll(').toBeTruthy(', ', isNotNull')
      .replaceAllMapped(RegExp(r'\).toEqual\(([^)]+)\)'), (match) {
        return ', equals(${match.group(1)}))';
      })
      .replaceAllMapped(RegExp(r'\).toBe\(([^)]+)\)'), (match) {
        return ', equals(${match.group(1)}))';
      })
      .replaceAllMapped(RegExp(r'\).toContain\(([^)]+)\)'), (match) {
        return ', contains(${match.group(1)}))';
      })
      .replaceAll('function()', '()')
      .replaceAll('.frames()', '.frames')
      .replaceAll('.url()', '.url')
      .replaceAll('async({page, server}) =>', '() async ')
      .replaceAll('async({page, server, browser}) =>', '() async ')
      .replaceAll('async({page}) =>', '() async ')
      .replaceAll('utils.attachFrame(', 'attachFrame(')
      .replaceAll('utils.detachFrame(', 'detachFrame(')
      .replaceAll('.push(', '.add(')
      .replaceAll('mainFrame()', 'mainFrame')
      .replaceAll('executionContext()', 'executionContext')
      .replaceAll('Promise.all', 'Future.wait');
  print(result);
}

final _input = r'''
  describe('OOPIF', function() {
    beforeAll(async function(state) {
      state.browser = await puppeteer.launch(Object.assign({}, defaultBrowserOptions, {
        args: (defaultBrowserOptions.args || []).concat(['--site-per-process']),
      }));
    });
    beforeEach(async function(state) {
      state.context = await state.browser.createIncognitoBrowserContext();
      state.page = await state.context.newPage();
    });
    afterEach(async function(state) {
      await state.context.close();
      state.page = null;
      state.context = null;
    });
    afterAll(async function(state) {
      await state.browser.close();
      state.browser = null;
    });
    xit('should report oopif frames', async function({page, server, context}) {
      await page.goto(server.PREFIX + '/dynamic-oopif.html');
      expect(oopifs(context).length).toBe(1);
      expect(page.frames().length).toBe(2);
    });
    it('should load oopif iframes with subresources and request interception', async function({page, server, context}) {
      await page.setRequestInterception(true);
      page.on('request', request => request.continue());
      await page.goto(server.PREFIX + '/dynamic-oopif.html');
      expect(oopifs(context).length).toBe(1);
    });
  });
''';
