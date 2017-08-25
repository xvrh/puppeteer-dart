/*
const CHROME_PROFILE_PATH = path.join(os.tmpdir(), 'puppeteer_dev_profile-');

const List<String> _defaultArgs = const <String>[
  '--disable-background-networking',
  '--disable-background-timer-throttling',
  '--disable-client-side-phishing-detection',
  '--disable-default-apps',
  '--disable-hang-monitor',
  '--disable-popup-blocking',
  '--disable-prompt-on-repost',
  '--disable-sync',
  '--enable-automation',
  '--enable-devtools-experiments',
  '--metrics-recording-only',
  '--no-first-run',
  '--password-store=basic',
  '--remote-debugging-port=0',
  '--safebrowsing-disable-auto-update',
  '--use-mock-keychain',
];


  /**
   * @param {!Object=} options
   * @return {!Promise<!Browser>}
   */
  launch({bool headless: true}) async {
    const userDataDir = fs.mkdtempSync(CHROME_PROFILE_PATH);

    const chromeArguments = DEFAULT_ARGS.concat([
    `--user-data-dir=${userDataDir}`,
    ]);
    if (headless) {
      chromeArguments.push(
          '--headless',
          '--disable-gpu',
          '--hide-scrollbars',
          '--mute-audio'
      );
    }
    let chromeExecutable = options.executablePath;
    if (typeof chromeExecutable !== 'string') {
      const revisionInfo = Downloader.revisionInfo(Downloader.currentPlatform(), ChromiumRevision);
      console.assert(revisionInfo.downloaded, `Chromium revision is not downloaded. Run "npm install"`);
    chromeExecutable = revisionInfo.executablePath;
    }
    if (Array.isArray(options.args))
    chromeArguments.push(...options.args);

    const chromeProcess = childProcess.spawn(chromeExecutable, chromeArguments, {});
    if (options.dumpio) {
    chromeProcess.stdout.pipe(process.stdout);
    chromeProcess.stderr.pipe(process.stderr);
    }

    // Cleanup as processes exit.
    let killed = false;
    process.once('exit', killChrome);
    chromeProcess.once('close', () => removeSync(userDataDir));

    if (options.handleSIGINT !== false)
    process.once('SIGINT', killChrome);

    try {
    const connectionDelay = options.slowMo || 0;
    const browserWSEndpoint = await waitForWSEndpoint(chromeProcess, options.timeout || 30 * 1000);
    const connection = await Connection.create(browserWSEndpoint, connectionDelay);
    return new Browser(connection, !!options.ignoreHTTPSErrors, killChrome);
    } catch (e) {
    killChrome();
    throw e;
    }

    killChrome() {
    if (killed)
    return;
    killed = true;
    if (process.platform === 'win32')
    childProcess.execSync(`taskkill /pid ${chromeProcess.pid} /T /F`);
    else
    chromeProcess.kill('SIGKILL');
    }
  }

  /**
   * @param {string} options
   * @return {!Promise<!Browser>}
   */
  connect({browserWSEndpoint, ignoreHTTPSErrors = false}) async {
    const connection = await Connection.create(browserWSEndpoint);
    return new Browser(connection, !!ignoreHTTPSErrors);
  }


/**
 * @param {!ChildProcess} chromeProcess
 * @param {number} timeout
 * @return {!Promise<string>}
 */
waitForWSEndpoint(chromeProcess, timeout) {
  return new Promise((resolve, reject) {
      const rl = readline.createInterface({ input: chromeProcess.stderr });
  let stderr = '';
  const listeners = [
    helper.addEventListener(rl, 'line', onLine),
    helper.addEventListener(rl, 'close', onClose),
    helper.addEventListener(chromeProcess, 'exit', onClose)
  ];
  const timeoutId = timeout ? setTimeout(onTimeout, timeout) : 0;

  function onClose() {
    cleanup();
    reject(new Error([
      'Failed to launch chrome!',
      stderr,
      '',
      'TROUBLESHOOTING: https://github.com/GoogleChrome/puppeteer/blob/master/docs/troubleshooting.md',
      '',
    ].join('\n')));
  }

  function onTimeout() {
    cleanup();
    reject(new Error(`Timed out after ${timeout} ms while trying to connect to Chrome! The only Chrome revision guaranteed to work is r${ChromiumRevision}`));
  }

  /**
   * @param {string} line
   */
  function onLine(line) {
    stderr += line + '\n';
    const match = line.match(/^DevTools listening on (ws:\/\/.*)$/);
    if (!match)
    return;
    cleanup();
    resolve(match[1]);
  }

  function cleanup() {
    if (timeoutId)
      clearTimeout(timeoutId);
    helper.removeEventListeners(listeners);
  }
});
}
*/