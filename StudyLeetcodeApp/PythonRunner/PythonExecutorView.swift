//
//  PythonExecutorView.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 4/9/25.
//

import Foundation
import SwiftUI
import WebKit

struct PythonExecutorView: UIViewRepresentable {
    let codeToRun: String
    @Binding var webViewRef: WKWebView?
    let onResult: (Bool, String) -> Void

    func makeUIView(context: Context) -> WKWebView {
        let cfg = WKWebViewConfiguration()
        cfg.userContentController.add(context.coordinator as WKScriptMessageHandler, name: "pyResult")
        cfg.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")

//        cfg.preferences.setValue(true, forKey: "allowUniversalAccessFromFileURLs")
        
        let webView = WKWebView(frame: .zero, configuration: cfg)
        webView.navigationDelegate = context.coordinator
        webView.isInspectable = true
        context.coordinator.webView = webView
        context.coordinator.codeToRun = codeToRun
        context.coordinator.onResult = onResult
        

        if let url = Bundle.main.url(forResource: "index",
                                     withExtension: "html") {
            print("Found index at", url)
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else {
            print("Did not find index")
        }
        
        DispatchQueue.main.async {
            self.webViewRef = webView
        }

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        
    }
    

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var webView: WKWebView?
        var codeToRun: String = ""
        var onResult: ((Bool, String) -> Void)?

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            runPythonCode()
        }
        
        private func runPythonCode() {
            guard let webView else { return }
            let js =
    """
    (async () => {
    try {
        const result = await runPython(`\(codeToRun)`)
        window.webkit.messageHandlers.pyResult.postMessage(result);
    } catch (e) {
        window.webkit.messageHandlers.pyResult.postMessage({
            ok: false,
            value: "hello"
        });
    }
    })();
    """

            webView.evaluateJavaScript(js)
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == "pyResult",
                  let dict  = message.body as? [String: Any],
                  let ok    = dict["ok"]   as? Bool,
                  let value = dict["value"] as? String
            else { return }
            print(value)
            onResult?(ok, value)
        }
        
    }
}
