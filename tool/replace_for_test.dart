main() {
  var result = _input
      .replaceAll('describe(', 'group(')
      .replaceAll('it(', 'test(')
      .replaceAll('it_fails_ffox(', 'test(')
      .replaceAll('.PREFIX', '.prefix')
      .replaceAll('.EMPTY_PAGE', '.emptyPage')
      .replaceAll('.CROSS_PROCESS_PREFIX', '.crossProcessPrefix')
      .replaceAll('const ', 'var ')
      .replaceAllMapped(RegExp(r'.evaluate\((.*=>[^\(\),]+)\)'), (Match m) {
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
  describe('JSCoverage', function() {
    it('should work', async function({page, server}) {
      await page.coverage.startJSCoverage();
      await page.goto(server.PREFIX + '/jscoverage/simple.html', {waitUntil: 'networkidle0'});
      const coverage = await page.coverage.stopJSCoverage();
      expect(coverage.length).toBe(1);
      expect(coverage[0].url).toContain('/jscoverage/simple.html');
      expect(coverage[0].ranges).toEqual([
        { start: 0, end: 17 },
        { start: 35, end: 61 },
      ]);
    });
    it('should report sourceURLs', async function({page, server}) {
      await page.coverage.startJSCoverage();
      await page.goto(server.PREFIX + '/jscoverage/sourceurl.html');
      const coverage = await page.coverage.stopJSCoverage();
      expect(coverage.length).toBe(1);
      expect(coverage[0].url).toBe('nicename.js');
    });
    it('should ignore eval() scripts by default', async function({page, server}) {
      await page.coverage.startJSCoverage();
      await page.goto(server.PREFIX + '/jscoverage/eval.html');
      const coverage = await page.coverage.stopJSCoverage();
      expect(coverage.length).toBe(1);
    });
    it('shouldn\'t ignore eval() scripts if reportAnonymousScripts is true', async function({page, server}) {
      await page.coverage.startJSCoverage({reportAnonymousScripts: true});
      await page.goto(server.PREFIX + '/jscoverage/eval.html');
      const coverage = await page.coverage.stopJSCoverage();
      expect(coverage.find(entry => entry.url.startsWith('debugger://'))).not.toBe(null);
      expect(coverage.length).toBe(2);
    });
    it('should ignore pptr internal scripts if reportAnonymousScripts is true', async function({page, server}) {
      await page.coverage.startJSCoverage({reportAnonymousScripts: true});
      await page.goto(server.EMPTY_PAGE);
      await page.evaluate('console.log("foo")');
      await page.evaluate(() => console.log('bar'));
      const coverage = await page.coverage.stopJSCoverage();
      expect(coverage.length).toBe(0);
    });
    it('should report multiple scripts', async function({page, server}) {
      await page.coverage.startJSCoverage();
      await page.goto(server.PREFIX + '/jscoverage/multiple.html');
      const coverage = await page.coverage.stopJSCoverage();
      expect(coverage.length).toBe(2);
      coverage.sort((a, b) => a.url.localeCompare(b.url));
      expect(coverage[0].url).toContain('/jscoverage/script1.js');
      expect(coverage[1].url).toContain('/jscoverage/script2.js');
    });
    it('should report right ranges', async function({page, server}) {
      await page.coverage.startJSCoverage();
      await page.goto(server.PREFIX + '/jscoverage/ranges.html');
      const coverage = await page.coverage.stopJSCoverage();
      expect(coverage.length).toBe(1);
      const entry = coverage[0];
      expect(entry.ranges.length).toBe(1);
      const range = entry.ranges[0];
      expect(entry.text.substring(range.start, range.end)).toBe(`console.log('used!');`);
    });
    it('should report scripts that have no coverage', async function({page, server}) {
      await page.coverage.startJSCoverage();
      await page.goto(server.PREFIX + '/jscoverage/unused.html');
      const coverage = await page.coverage.stopJSCoverage();
      expect(coverage.length).toBe(1);
      const entry = coverage[0];
      expect(entry.url).toContain('unused.html');
      expect(entry.ranges.length).toBe(0);
    });
    it('should work with conditionals', async function({page, server}) {
      await page.coverage.startJSCoverage();
      await page.goto(server.PREFIX + '/jscoverage/involved.html');
      const coverage = await page.coverage.stopJSCoverage();
      expect(JSON.stringify(coverage, null, 2).replace(/:\d{4}\//g, ':<PORT>/')).toBeGolden('jscoverage-involved.txt');
    });
    describe('resetOnNavigation', function() {
      it('should report scripts across navigations when disabled', async function({page, server}) {
        await page.coverage.startJSCoverage({resetOnNavigation: false});
        await page.goto(server.PREFIX + '/jscoverage/multiple.html');
        await page.goto(server.EMPTY_PAGE);
        const coverage = await page.coverage.stopJSCoverage();
        expect(coverage.length).toBe(2);
      });
      it('should NOT report scripts across navigations when enabled', async function({page, server}) {
        await page.coverage.startJSCoverage(); // Enabled by default.
        await page.goto(server.PREFIX + '/jscoverage/multiple.html');
        await page.goto(server.EMPTY_PAGE);
        const coverage = await page.coverage.stopJSCoverage();
        expect(coverage.length).toBe(0);
      });
    });
    xit('should not hang when there is a debugger statement', async function({page, server}) {
      await page.coverage.startJSCoverage();
      await page.goto(server.EMPTY_PAGE);
      await page.evaluate(() => {
        debugger; // eslint-disable-line no-debugger
      });
      await page.coverage.stopJSCoverage();
    });
  });

  describe('CSSCoverage', function() {
    it('should work', async function({page, server}) {
      await page.coverage.startCSSCoverage();
      await page.goto(server.PREFIX + '/csscoverage/simple.html');
      const coverage = await page.coverage.stopCSSCoverage();
      expect(coverage.length).toBe(1);
      expect(coverage[0].url).toContain('/csscoverage/simple.html');
      expect(coverage[0].ranges).toEqual([
        {start: 1, end: 22}
      ]);
      const range = coverage[0].ranges[0];
      expect(coverage[0].text.substring(range.start, range.end)).toBe('div { color: green; }');
    });
    it('should report sourceURLs', async function({page, server}) {
      await page.coverage.startCSSCoverage();
      await page.goto(server.PREFIX + '/csscoverage/sourceurl.html');
      const coverage = await page.coverage.stopCSSCoverage();
      expect(coverage.length).toBe(1);
      expect(coverage[0].url).toBe('nicename.css');
    });
    it('should report multiple stylesheets', async function({page, server}) {
      await page.coverage.startCSSCoverage();
      await page.goto(server.PREFIX + '/csscoverage/multiple.html');
      const coverage = await page.coverage.stopCSSCoverage();
      expect(coverage.length).toBe(2);
      coverage.sort((a, b) => a.url.localeCompare(b.url));
      expect(coverage[0].url).toContain('/csscoverage/stylesheet1.css');
      expect(coverage[1].url).toContain('/csscoverage/stylesheet2.css');
    });
    it('should report stylesheets that have no coverage', async function({page, server}) {
      await page.coverage.startCSSCoverage();
      await page.goto(server.PREFIX + '/csscoverage/unused.html');
      const coverage = await page.coverage.stopCSSCoverage();
      expect(coverage.length).toBe(1);
      expect(coverage[0].url).toBe('unused.css');
      expect(coverage[0].ranges.length).toBe(0);
    });
    it('should work with media queries', async function({page, server}) {
      await page.coverage.startCSSCoverage();
      await page.goto(server.PREFIX + '/csscoverage/media.html');
      const coverage = await page.coverage.stopCSSCoverage();
      expect(coverage.length).toBe(1);
      expect(coverage[0].url).toContain('/csscoverage/media.html');
      expect(coverage[0].ranges).toEqual([
        {start: 17, end: 38}
      ]);
    });
    it('should work with complicated usecases', async function({page, server}) {
      await page.coverage.startCSSCoverage();
      await page.goto(server.PREFIX + '/csscoverage/involved.html');
      const coverage = await page.coverage.stopCSSCoverage();
      expect(JSON.stringify(coverage, null, 2).replace(/:\d{4}\//g, ':<PORT>/')).toBeGolden('csscoverage-involved.txt');
    });
    it('should ignore injected stylesheets', async function({page, server}) {
      await page.coverage.startCSSCoverage();
      await page.addStyleTag({content: 'body { margin: 10px;}'});
      // trigger style recalc
      const margin = await page.evaluate(() => window.getComputedStyle(document.body).margin);
      expect(margin).toBe('10px');
      const coverage = await page.coverage.stopCSSCoverage();
      expect(coverage.length).toBe(0);
    });
    describe('resetOnNavigation', function() {
      it('should report stylesheets across navigations', async function({page, server}) {
        await page.coverage.startCSSCoverage({resetOnNavigation: false});
        await page.goto(server.PREFIX + '/csscoverage/multiple.html');
        await page.goto(server.EMPTY_PAGE);
        const coverage = await page.coverage.stopCSSCoverage();
        expect(coverage.length).toBe(2);
      });
      it('should NOT report scripts across navigations', async function({page, server}) {
        await page.coverage.startCSSCoverage(); // Enabled by default.
        await page.goto(server.PREFIX + '/csscoverage/multiple.html');
        await page.goto(server.EMPTY_PAGE);
        const coverage = await page.coverage.stopCSSCoverage();
        expect(coverage.length).toBe(0);
      });
    });
    it('should work with a recently loaded stylesheet', async function({page, server}) {
      await page.coverage.startCSSCoverage();
      await page.evaluate(async url => {
        document.body.textContent = 'hello, world';

        const link = document.createElement('link');
        link.rel = 'stylesheet';
        link.href = url;
        document.head.appendChild(link);
        await new Promise(x => link.onload = x);
      }, server.PREFIX + '/csscoverage/stylesheet1.css');
      const coverage = await page.coverage.stopCSSCoverage();
      expect(coverage.length).toBe(1);
    });
  });
''';
