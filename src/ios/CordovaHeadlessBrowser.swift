import WebKit

@objc class CordovaHeadlessBrowser: CDVPlugin {
    var wvInstances: [Int:WKWebView] = [:]

    @objc(open:)
    func open (command: CDVInvokedUrlCommand) {
        let url = command.argument(at: 0) as! String

        guard let url = URL(string: url) else {
            let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Invalid URL")
            self.commandDelegate!.send(result, callbackId: command.callbackId)
            return
        }

        let wv = WKWebView(frame: CGRect.zero)
        UIApplication.shared.windows.first?.addSubview(wv)

        wv.load(URLRequest(url: url))

        let id = wvInstances.count + 1
        wvInstances[id] = wv

        let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: id)
        self.commandDelegate!.send(result, callbackId: command.callbackId)
    }

    @objc(evaluate:)
    func evaluate (command: CDVInvokedUrlCommand) {
        let id = command.argument(at: 0) as! Int
        let script = command.argument(at: 1) as! String

        guard let wv = wvInstances[id] else {
            let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Invalid WebView ID")
            self.commandDelegate!.send(result, callbackId: command.callbackId)
            return
        }

        wv.evaluateJavaScript(script) { (result, error) in
            if let error = error {
                let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error.localizedDescription)
                self.commandDelegate!.send(result, callbackId: command.callbackId)
                return
            }
            wv.endEditing(true)

            let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: result as? String)
            self.commandDelegate!.send(result, callbackId: command.callbackId)
        }
    }

    @objc(getUrl:)
    func getUrl (command: CDVInvokedUrlCommand) {
        let id = command.argument(at: 0) as! Int
        guard let wv = wvInstances[id] else {
            let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Invalid WebView ID")
            self.commandDelegate!.send(result, callbackId: command.callbackId)
            return
        }

        let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: wv.url?.absoluteString)
        self.commandDelegate!.send(result, callbackId: command.callbackId)
    }

    @objc(close:)
    func close (command: CDVInvokedUrlCommand) {
        let id = command.argument(at: 0) as! Int
        guard let wv = wvInstances[id] else {
            let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Invalid WebView ID")
            self.commandDelegate!.send(result, callbackId: command.callbackId)
            return
        }

        wv.removeFromSuperview()
        wvInstances.removeValue(forKey: id)

        let result = CDVPluginResult(status: CDVCommandStatus_OK)
        self.commandDelegate!.send(result, callbackId: command.callbackId)
    }

    @objc(onReady:)
    func onReady (command: CDVInvokedUrlCommand) {
        let id = command.argument(at: 0) as! Int
        guard let wv = wvInstances[id] else {
            let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Invalid WebView ID")
            self.commandDelegate!.send(result, callbackId: command.callbackId)
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            if wv.isLoading {
                self?.onReady(command: command)
            } else {
                let result = CDVPluginResult(status: CDVCommandStatus_OK)
                self?.commandDelegate!.send(result, callbackId: command.callbackId)
            }
        }
    }
}
