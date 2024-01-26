//
//  WebViewManager.swift
//  MinBrowser
//
//  Created by ou on 1/20/24.
//

import Foundation
import WebKit


class WebViewManager: ObservableObject {
    @Published var webViews: [URL: WKWebView] = [:]
    var customUserAgent: String?

    func loadWebView(url: URL) {
        if webViews[url] == nil {
            let webView = WKWebView()
            webView.customUserAgent = customUserAgent
            webView.load(URLRequest(url: url))
            webViews[url] = webView
        }
    }
}
