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
  describe('HEADFUL', function() {
    it('background_page target type should be available', async() => {
      const browserWithExtension = await puppeteer.launch(extensionOptions);
      const page = await browserWithExtension.newPage();
      const backgroundPageTarget = await browserWithExtension.waitForTarget(target => target.type() === 'background_page');
      await page.close();
      await browserWithExtension.close();
      expect(backgroundPageTarget).toBeTruthy();
    });
    it('target.page() should return a background_page', async({}) => {
      const browserWithExtension = await puppeteer.launch(extensionOptions);
      const backgroundPageTarget = await browserWithExtension.waitForTarget(target => target.type() === 'background_page');
      const page = await backgroundPageTarget.page();
      expect(await page.evaluate(() => 2 * 3)).toBe(6);
      expect(await page.evaluate(() => window.MAGIC)).toBe(42);
      await browserWithExtension.close();
    });
    it('should have default url when launching browser', async function() {
      const browser = await puppeteer.launch(extensionOptions);
      const pages = (await browser.pages()).map(page => page.url());
      expect(pages).toEqual(['about:blank']);
      await browser.close();
    });
    it('headless should be able to read cookies written by headful', async({server}) => {
      const userDataDir = await mkdtempAsync(TMP_FOLDER);
      // Write a cookie in headful chrome
      const headfulBrowser = await puppeteer.launch(Object.assign({userDataDir}, headfulOptions));
      const headfulPage = await headfulBrowser.newPage();
      await headfulPage.goto(server.EMPTY_PAGE);
      await headfulPage.evaluate(() => document.cookie = 'foo=true; expires=Fri, 31 Dec 9999 23:59:59 GMT');
      await headfulBrowser.close();
      // Read the cookie from headless chrome
      const headlessBrowser = await puppeteer.launch(Object.assign({userDataDir}, headlessOptions));
      const headlessPage = await headlessBrowser.newPage();
      await headlessPage.goto(server.EMPTY_PAGE);
      const cookie = await headlessPage.evaluate(() => document.cookie);
      await headlessBrowser.close();
      // This might throw. See https://github.com/GoogleChrome/puppeteer/issues/2778
      await rmAsync(userDataDir).catch(e => {});
      expect(cookie).toBe('foo=true');
    });
    // TODO: Support OOOPIF. @see https://github.com/GoogleChrome/puppeteer/issues/2548
    xit('OOPIF: should report google.com frame', async({server}) => {
      // https://google.com is isolated by default in Chromium embedder.
      const browser = await puppeteer.launch(headfulOptions);
      const page = await browser.newPage();
      await page.goto(server.EMPTY_PAGE);
      await page.setRequestInterception(true);
      page.on('request', r => r.respond({body: 'YO, GOOGLE.COM'}));
      await page.evaluate(() => {
        const frame = document.createElement('iframe');
        frame.setAttribute('src', 'https://google.com/');
        document.body.appendChild(frame);
        return new Promise(x => frame.onload = x);
      });
      await page.waitForSelector('iframe[src="https://google.com/"]');
      const urls = page.frames().map(frame => frame.url()).sort();
      expect(urls).toEqual([
        server.EMPTY_PAGE,
        'https://google.com/'
      ]);
      await browser.close();
    });
    it('should close browser with beforeunload page', async({server}) => {
      const browser = await puppeteer.launch(headfulOptions);
      const page = await browser.newPage();
      await page.goto(server.PREFIX + '/beforeunload.html');
      // We have to interact with a page so that 'beforeunload' handlers
      // fire.
      await page.click('body');
      await browser.close();
    });
    it('should open devtools when "devtools: true" option is given', async({server}) => {
      const browser = await puppeteer.launch(Object.assign({devtools: true}, headfulOptions));
      const context = await browser.createIncognitoBrowserContext();
      await Promise.all([
        context.newPage(),
        context.waitForTarget(target => target.url().includes('devtools://')),
      ]);
      await browser.close();
    });
  });

  describe('Page.bringToFront', function() {
    it('should work', async() => {
      const browser = await puppeteer.launch(headfulOptions);
      const page1 = await browser.newPage();
      const page2 = await browser.newPage();

      await page1.bringToFront();
      expect(await page1.evaluate(() => document.visibilityState)).toBe('visible');
      expect(await page2.evaluate(() => document.visibilityState)).toBe('hidden');

      await page2.bringToFront();
      expect(await page1.evaluate(() => document.visibilityState)).toBe('hidden');
      expect(await page2.evaluate(() => document.visibilityState)).toBe('visible');

      await page1.close();
      await page2.close();
      await browser.close();
    });
  });

''';
