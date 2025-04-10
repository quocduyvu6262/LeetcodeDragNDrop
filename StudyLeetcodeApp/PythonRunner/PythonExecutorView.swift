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
        context.coordinator.webView = webView
        
        if let htmlPath = Bundle.main.path(forResource: "pyodide_runner", ofType: "html"),
           let html = try? String(contentsOfFile: htmlPath, encoding: .utf8) {
            webView.loadHTMLString(html, baseURL: Bundle.main.bundleURL)
        }
        
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let escapedCode = codeToRun.replacingOccurrences(of: "`", with: "\\`")
        let js = "runPython(`\(escapedCode)`)"
        webView.evaluateJavaScript(js) { result, error in
            guard let resultStr = result as? String,
                  let data = resultStr.data(using: .utf8),
                  let parsed = try? JSONDecoder().decode([String: String].self, from: data) else {
                onResult(false, error?.localizedDescription ?? "Failed to execute")
                return
            }
            onResult(parsed["success"] == "true", parsed["output"] ?? parsed["error"] ?? "Unknown error")
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject {
        var webView: WKWebView?
    }
}

