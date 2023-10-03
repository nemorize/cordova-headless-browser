# cordova-headless-browser
Cordova plugin that provides a headless browser interface.

## Installation
The plugin is not available on npm. You can install it directly from GitHub.

```sh
# Install latest head version:
cordova plugin add https://github.com/2-page/cordova-headless-browser.git

# Or install from local source:
cordova plugin add "<path-to-plugin-directory>" --nofetch --nosave --link
```

## Platform
Only available for iOS. Android support is planned.

## Usage
The plugin creates the class `CordovaHeadlessBrowser.instance`, and is accessible after the `deviceready` event has been fired.

### Initialize
Create a new instance of the browser and initialize it with a url. You must call `init()` before using the browser.

```js
const browser = new CordovaHeadlessBrowser.instance();
await browser.init('https://www.google.com/');
```

### close
Close the browser. You must call `close()` after using the browser.
If you do not call `close()`, the browser will not be garbage collected and will continue to run in the background.

```js
const browser = new CordovaHeadlessBrowser.instance();
await browser.init('https://www.google.com/');
browser.onReady(async () => {
    await browser.close();
});
```

### onReady
Wait for the browser to be loaded and ready to use. The callback will be called immediately if the browser is already ready.

```js
const browser = new CordovaHeadlessBrowser.instance();
await browser.init('https://www.google.com/');
browser.onReady(() => {
    console.log('Browser is ready');
    browser.onReady(() => {
        console.log('It will print this message immediately, because the browser is already ready');
    })
});
```

### evaluate
Evaluate a javascript expression in the browser. Provided expressions will be wrapped in a function and executed in the browser context.
If you want to return a value from the expression, you must use the `return` keyword.

```js
const browser = new CordovaHeadlessBrowser.instance();
await browser.init('https://www.google.com/');
browser.onReady(async () => {
    const result = await browser.evaluate('return document.title');
    console.log(result); // Google
});
```

> **Note:** It wraps the given expression in `JSON.stringify((() => { // })() ?? null)`, and wraps the result in `JSON.parse()`.
> This means that you can return any value from the expression, but it must be JSON serializable.

### waitForNavigate
Wait for the browser to navigate to a new url.

```js
const browser = new CordovaHeadlessBrowser.instance();
await browser.init('https://www.google.com/');
browser.onReady(async () => {
    await browser.evaluate('location.href = "https://drive.google.com/";');
    await browser.waitForNavigate();
    const result = await browser.evaluate('return document.title');
    console.log(result); // Google Drive
});
```

> **Note:** In fact, it does not wait for the browser to navigate to a new url, but it waits for the browser to be ready again.
> This means that it will finish waiting immediately if the browser is already ready, even if it has not navigated to a new url.

### getUrl
Get the current url of the browser.

```js
const browser = new CordovaHeadlessBrowser.instance();
await browser.init('https://www.google.com/');
browser.onReady(async () => {
    const result = await browser.getUrl();
    console.log(result); // https://www.google.com/
});
```

## License
MIT
