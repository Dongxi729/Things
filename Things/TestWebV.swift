//
//  TestWebV.swift
//  Things
//
//  Created by 郑东喜 on 2017/7/14.
//  Copyright © 2017年 郑东喜. All rights reserved.
//

import UIKit
import WebKit

class TestWebV: UIViewController,WKScriptMessageHandler {
    
    ///网页模板
    lazy var webView: WKWebView = {
        var wkV : WKWebView = WKWebView.init()
        
        //配置webview
        let configuration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        
        userContentController.add(self as WKScriptMessageHandler, name: "shareWeixinInfo")
        
        userContentController.add(self as WKScriptMessageHandler, name: "setAlias")
        
        wkV = WKWebView.init(frame: self.view.bounds, configuration: configuration)
        
        ///由于设置了edgesForExtendedLayout,防止了页面全部控件向上偏移，所以在子页面数大于2的时候，矫正
        wkV = WKWebView.init(frame: CGRect.init(x: 0, y: 20, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 20), configuration: configuration)

        return wkV
        
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(webView)
        
        let html = "WKWebViewMessageHandler"
        let path = Bundle.main.path(forResource: html, ofType: ".html")
        
        do {
            let htmlStr = try NSString.init(contentsOfFile: path!, encoding: String.Encoding.utf8.rawValue)
            self.webView.loadHTMLString(htmlStr as String, baseURL: Bundle.main.bundleURL)
        } catch {
            
        }

    }
    
    // MARK:- js交互
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let msg = message.name
        if msg == "logout" {
            print("payClick")
        }
    }
}
