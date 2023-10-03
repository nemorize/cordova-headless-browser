// noinspection NpmUsedModulesInstalled
const exec = require('cordova/exec');

class CordovaHeadlessBrowser {
    /**
     * The instance ID.
     *
     * @type {number}
     */
    instanceId = -1;

    /**
     * Whether the browser is ready.
     *
     * @type {boolean}
     */
    isReady = false;

    /**
     * On ready callbacks.
     *
     * @type {Array<function>}
     */
    onReadyCallbacks = [];

    constructor () {
    }

    /**
     * Initialize the headless browser with the given URL.
     *
     * @param {string} url The URL to load.
     */
    async init (url) {
        return new Promise((resolve, reject) => {
            exec((id) => {
                this.instanceId = id;
                this.readyHandler();
                resolve();
            }, reject, 'CordovaHeadlessBrowser', 'open', [ url ]);
        });
    }

    /**
     * Handle the ready event.
     * This will be called by the native code when the browser is ready.
     */
    readyHandler () {
        exec(() => {
            this.isReady = true;
            this.onReadyCallbacks.forEach((callback) => {
                callback();
            });
        }, _=>_, 'CordovaHeadlessBrowser', 'onReady', [ this.instanceId ]);
    }

    /**
     * Wait for the browser to be ready.
     *
     * @return {Promise<void>}
     */
    async waitForReady () {
        return new Promise((resolve) => {
            this.onReady(() => {
                resolve();
            });
        });
    }

    /**
     * On the ready event.
     *
     * @param {function} callback The callback to call when the event is fired.
     */
    onReady (callback) {
        if (this.instanceId === -1) {
            throw new Error('The browser is not initialized.');
        }
        if (this.instanceId === -10) {
            throw new Error('The browser is closed.');
        }

        if (this.isReady) {
            callback();
            return;
        }
        this.onReadyCallbacks.push(callback);
    }

    /**
     * Wait for the browser to navigate to a new page.
     *
     * @return {Promise<void>}
     */
    async waitForNavigation () {
        await this.waitForReady();
        return new Promise((resolve, reject) => {
            exec(() => {
                resolve();
            }, reject, 'CordovaHeadlessBrowser', 'onReady', [ this.instanceId ]);
        });
    }

    /**
     * Evaluate the given script.
     * If the browser is not ready, it will wait for it to be ready.
     *
     * @param {string} script The script to evaluate. It will be wrapped in a function, so if you want to return a value, you need to use a return statement.
     * @return {Promise<any>} The result of the script.
     */
    async evaluate (script) {
        await this.waitForReady();
        return new Promise((resolve, reject) => {
            let encodedScript = 'JSON.stringify((() => { ' + script + ' }) () ?? null);';
            exec((json) => {
                resolve(JSON.parse(json));
            }, reject, 'CordovaHeadlessBrowser', 'evaluate', [ this.instanceId, encodedScript ]);
        });
    }

    /**
     * Get the current URL.
     * If the browser is not ready, it will wait for it to be ready.
     *
     * @return {Promise<string>} The current URL.
     */
    async getUrl () {
        await this.waitForReady();
        return new Promise((resolve, reject) => {
            exec((url) => {
                resolve(url);
            }, reject, 'CordovaHeadlessBrowser', 'getUrl', [ this.instanceId ]);
        });
    }

    /**
     * Close the browser.
     */
    close () {
        exec(_=>_, _=>_, 'CordovaHeadlessBrowser', 'close', [ this.instanceId ]);
        this.instanceId = -10;
    }
}

exports.instance = CordovaHeadlessBrowser;