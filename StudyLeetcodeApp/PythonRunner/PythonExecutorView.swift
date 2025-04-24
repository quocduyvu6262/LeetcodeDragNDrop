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
    let onResult: (Bool, String) -> Void

    func makeUIView(context: Context) -> WKWebView {
        let cfg = WKWebViewConfiguration()
        cfg.userContentController.add(context.coordinator as WKScriptMessageHandler, name: "pyResult")
        cfg.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
//        cfg.preferences.setValue(true, forKey: "allowUniversalAccessFromFileURLs")
        
        let webView = WKWebView(frame: .zero, configuration: cfg)
        webView.navigationDelegate = context.coordinator
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
        const pyodide = await window.pyReady;
        window.webkit.messageHandlers.pyResult.postMessage({
            ok: true,
            value: "Run pyodide here"
        });
    } catch (e) {
        window.webkit.messageHandlers.pyResult.postMessage({
            ok: false,
            value: "hello"
        });
    }
})();
"""

            webView.evaluateJavaScript("setTimeout(function() {\(js)}, 500);") { result, error in
                if let error = error as? WKError {
                    print("[JS] \(error.code): \(error.localizedDescription)")
                    if let details = error.userInfo[NSLocalizedFailureReasonErrorKey] as? String {
                        print("[JS‑stack] \(details)")
                    }
                }
            }
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            print("jere")
            print(message)
            guard message.name == "pyResult",
                  let dict  = message.body as? [String: Any],
                  let ok    = dict["ok"]   as? Bool,
                  let value = dict["value"] as? String
            else { return }
            onResult?(ok, value)
        }
        
    }
}
