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
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        context.coordinator.webView = webView
        context.coordinator.codeToRun = codeToRun
        context.coordinator.onResult = onResult

        if let htmlPath = Bundle.main.path(forResource: "pyodide_runner", ofType: "html"),
           let html = try? String(contentsOfFile: htmlPath, encoding: .utf8) {
            webView.loadHTMLString(html, baseURL: Bundle.main.bundleURL)
        }

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {

    }
    

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var webView: WKWebView?
        var codeToRun: String = ""
        var onResult: ((Bool, String) -> Void)?

        private func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) async {
            await self.runPythonCode()
        }
        
        func runPythonCode() async {
            guard let webView = webView else { return }

            let escapedCode = codeToRun
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "`", with: "\\`")

            let js =
"""

"""
            do {
                let result = try await webView.evaluateJavaScriptAsync("runPython(`\(escapedCode)`)")
                
                if let dict = result as? [String: Any] {
                    if dict["success"] as? Bool == true {
                        onResult?(true, dict["result"] as? String ?? "")
                    } else {
                        onResult?(false, dict["error"] as? String ?? "Unknown error")
                    }
                }
            } catch {
                onResult?(false, error.localizedDescription)
            }
        }
    }
}

extension WKWebView {
    func evaluateJavaScriptAsync(_ script: String) async throws -> Any {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                self.evaluateJavaScript(script) { result, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: result ?? "")
                    }
                }
            }
        }
    }
}
