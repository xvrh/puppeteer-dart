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
  describe('Tracing', function() {
    beforeEach(async function(state) {
      state.outputFile = path.join(__dirname, 'assets', `trace-${state.parallelIndex}.json`);
      state.browser = await puppeteer.launch(defaultBrowserOptions);
      state.page = await state.browser.newPage();
    });
    afterEach(async function(state) {
      await state.browser.close();
      state.browser = null;
      state.page = null;
      if (fs.existsSync(state.outputFile)) {
        fs.unlinkSync(state.outputFile);
        state.outputFile = null;
      }
    });
    it('should output a trace', async({page, server, outputFile}) => {
      await page.tracing.start({screenshots: true, path: outputFile});
      await page.goto(server.PREFIX + '/grid.html');
      await page.tracing.stop();
      expect(fs.existsSync(outputFile)).toBe(true);
    });
    it('should run with custom categories if provided', async({page, outputFile}) => {
      await page.tracing.start({path: outputFile, categories: ['disabled-by-default-v8.cpu_profiler.hires']});
      await page.tracing.stop();

      const traceJson = JSON.parse(fs.readFileSync(outputFile));
      expect(traceJson.metadata['trace-config']).toContain('disabled-by-default-v8.cpu_profiler.hires');
    });
    it('should throw if tracing on two pages', async({page, server, browser, outputFile}) => {
      await page.tracing.start({path: outputFile});
      const newPage = await browser.newPage();
      let error = null;
      await newPage.tracing.start({path: outputFile}).catch(e => error = e);
      await newPage.close();
      expect(error).toBeTruthy();
      await page.tracing.stop();
    });
    it('should return a buffer', async({page, server, outputFile}) => {
      await page.tracing.start({screenshots: true, path: outputFile});
      await page.goto(server.PREFIX + '/grid.html');
      const trace = await page.tracing.stop();
      const buf = fs.readFileSync(outputFile);
      expect(trace.toString()).toEqual(buf.toString());
    });
    it('should work without options', async({page, server, outputFile}) => {
      await page.tracing.start();
      await page.goto(server.PREFIX + '/grid.html');
      const trace = await page.tracing.stop();
      expect(trace).toBeTruthy();
    });
    it('should return null in case of Buffer error', async({page, server}) => {
      await page.tracing.start({screenshots: true});
      await page.goto(server.PREFIX + '/grid.html');
      const oldBufferConcat = Buffer.concat;
      Buffer.concat = bufs => {
        throw 'error';
      };
      const trace = await page.tracing.stop();
      expect(trace).toEqual(null);
      Buffer.concat = oldBufferConcat;
    });
    it('should support a buffer without a path', async({page, server}) => {
      await page.tracing.start({screenshots: true});
      await page.goto(server.PREFIX + '/grid.html');
      const trace = await page.tracing.stop();
      expect(trace.toString()).toContain('screenshot');
    });
  });
''';
