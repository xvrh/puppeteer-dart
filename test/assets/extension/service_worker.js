self.hello = () => `Hello from ${chrome.runtime.id}`;

chrome.runtime.onMessage.addListener((message) => {
  if (message === 'devtools_page') {
    chrome.tabs.create({ url: 'popup.html?devtools_page' });
  }
});
