self.hello = () => `Hello from ${chrome.runtime.id}`;

self.devtoolsPageLoaded = new Promise((resolve) => {
  chrome.runtime.onMessage.addListener((message) => {
    if (message === 'devtools_page') resolve(true);
  });
});
