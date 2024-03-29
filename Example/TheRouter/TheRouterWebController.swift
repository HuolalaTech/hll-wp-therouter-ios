//
//  TheRouterWebController.swift
//  TheRouter_Example
//
//  Created by mars.yao on 2023/8/21.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import WebKit
import TheRouter

class TheRouterWebController: UIViewController {
    
    var webView: WKWebView?
    
    var baseUrl: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "WKWebView"
        self.initWebView()
        self.loadWebView(baseURL: self.baseUrl)
    }
    
    private func initWebView() {
        let preferences = WKPreferences()
        let userContentController = WKUserContentController()
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.userContentController = userContentController
        
        self.webView = WKWebView(frame: self.view.bounds, configuration: configuration)
        self.webView?.uiDelegate = self
        self.webView?.navigationDelegate = self
        self.view.addSubview(self.webView!)
    }
    
    private func loadWebView(baseURL: String?) {
        guard let baseURL = baseURL else { return }
        let url = URL(string: baseURL)!
        let request = URLRequest(url: url)
        self.webView?.load(request)
    }
    

}


extension TheRouterWebController: WKUIDelegate, WKNavigationDelegate {
    
    // 页面开始加载时调用
     func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
     }
     // 当内容开始返回时调用
     func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
     }
     // 页面加载完成之后调用
     func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
     }
    
     // 页面加载失败时调用
     func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
     }
    
     // 接收到服务器跳转请求之后调用
     func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
     }
}


extension TheRouterWebController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) { }
    
}

extension TheRouterWebController: TheRouterable {
    
    static var patternString: [String] {
        ["scheme://webview/home"]
    }
    
    static func registerAction(info: [String : Any]) -> Any {
        let webVC = TheRouterWebController()
        webVC.baseUrl = info["url"] as? String ?? ""
        return webVC
    }
    
    static var priority: UInt {
        TheRouterDefaultPriority
    }
    
}
