//
//  ViewController.swift
//  Things
//
//  Created by 郑东喜 on 2017/7/5.
//  Copyright © 2017年 郑东喜. All rights reserved.
//

import UIKit
import WebKit

/// 屏幕宽度
let SCREEN_WIDTH = UIScreen.main.bounds.width

/// 屏幕高度
let SCREEN_HEIGHT = UIScreen.main.bounds.height

class ViewController: UIViewController,WKScriptMessageHandler {
    
    
    /// 背景图片
    lazy var maskV: UIView = {
        let d : UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 20))
        d.backgroundColor = UIColor.white
        return d
    }()
    
    var urlStr : String = "http://39.108.179.192/app"
    
    
    lazy var refreshControl: UIRefreshControl = {
        let d : UIRefreshControl = UIRefreshControl.init(frame: CGRect.init(x: 0, y: 20, width: SCREEN_WIDTH, height: 10))
        d.addTarget(self, action: #selector(refreshSEL(sender:)), for: .valueChanged)
        return d
    }()
    
    func refreshSEL(sender : UIRefreshControl) -> Void {
        self.webView.reload()
        
        if !self.webView.isLoading {
            sender.endRefreshing()
        }
        
    }
    
    ///网页模板
    lazy var webView: WKWebView = {
        var wkV : WKWebView = WKWebView.init()
        
        //配置webview
        var configuration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        
        // 禁止选择CSS
        let css = "body{-webkit-user-select:none;-webkit-user-drag:none;}"
        
        // CSS选中样式取消
        let javascript = NSMutableString.init()
        
        javascript.append("var style = document.createElement('style');")
        javascript.append("style.type = 'text/css';")
        javascript.appendFormat("var cssContent = document.createTextNode('%@');", css)
        javascript.append("style.appendChild(cssContent);")
        javascript.append("document.body.appendChild(style);")
        
        
        // javascript注入
        let noneSelectScript = WKUserScript.init(source: javascript as String, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        
        userContentController.addUserScript(noneSelectScript)
        
        configuration.userContentController = userContentController

        
        userContentController.add(LeakAvoider.init(delegate: self as WKScriptMessageHandler), name: "setAlias")
        userContentController.add(LeakAvoider.init(delegate: self as WKScriptMessageHandler), name: "shareWeixinInfo")
        userContentController.add(LeakAvoider.init(delegate: self as WKScriptMessageHandler), name: "weixinPay")
        
        ///由于设置了edgesForExtendedLayout,防止了页面全部控件向上偏移，所以在子页面数大于2的时候，矫正
        wkV = WKWebView.init(frame: CGRect.init(x: 0, y: 20, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 20), configuration: configuration)
        
        wkV.navigationDelegate = self;
        
        //词句注释，无法唤起微信支付
        wkV.uiDelegate = self
        
        //动画过度
        wkV.alpha = 0
        
        UIView.animate(withDuration: 1.0) {
            wkV.alpha = 1.0
        }
        
        
        /// 取出webView中滑动视图的横竖滑动条
        wkV.scrollView.showsVerticalScrollIndicator = false
        wkV.scrollView.showsHorizontalScrollIndicator = false
        
        return wkV
        
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        
        view.addSubview(webView)
        view.addSubview(maskV)
        
        
        NetCheck.shared.xxx { (code) in
            if code.rawValue == 0 {
                
                print("00")
                let request : URLRequest = NSURLRequest.init(url: URL.init(string: self.urlStr)!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 0) as URLRequest
                self.webView.load(request)
            } else {
                print("1")
                let request : URLRequest = NSURLRequest.init(url: URL.init(string: self.urlStr)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 0) as URLRequest
                self.webView.load(request)
            }
        }
//        /// 加载本地测试
//        let html = "WKWebViewMessageHandler"
//        let path = Bundle.main.path(forResource: html, ofType: ".html")
//        
//        do {
//            let htmlStr = try NSString.init(contentsOfFile: path!, encoding: String.Encoding.utf8.rawValue)
//            self.webView.loadHTMLString(htmlStr as String, baseURL: Bundle.main.bundleURL)
//        } catch {
//            
//        }
//        
        
        self.webView.scrollView.addSubview(refreshControl)
        
        //获取自定义消息推送内容
        NotificationCenter.default.addObserver(self, selector: #selector(networkDidReceiveMessage(notification:)), name: NSNotification.Name.jpfNetworkDidReceiveMessage, object: nil)
    }
    
    
    
    func networkDidReceiveMessage(notification : Notification) -> Void {
        let userInfo = notification.userInfo
        let content = userInfo?["content"] as? String
        let extras = userInfo?["extras"] as? NSDictionary
        let customizeField = extras?["customizeField1"] as? String
        
        let alVC : UIAlertController = UIAlertController.init(title: content, message: customizeField, preferredStyle: .alert)
        
        alVC.addAction(UIAlertAction.init(title: "好的", style: .default, handler: { (alert) in
            let dicNotifi = notification.userInfo! as NSDictionary
            if let getNotifiStr = (dicNotifi["extras"] as? NSDictionary)?["url"] as? String {
                print("执行")
                
                let vc = ViewController()
                vc.urlStr = getNotifiStr
                
                print(".....",getNotifiStr)
                
                self.present(vc, animated: true, completion: nil)
                
                UIApplication.shared.keyWindow?.rootViewController = vc
            }
        }))
        
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.rootViewController?.present(alVC, animated: true, completion: nil)
        }
        
//        Optional([AnyHashable("content"): 这是一个测试通知。。, AnyHashable("extras"): {
//            url = "http://localhost:8080http://39.108.179.192/app";
//            }, AnyHashable("title"): 测试标题])
        print("\((#file as NSString).lastPathComponent):(\(#line))\n",notification.userInfo)
        
        let dicNotifi = notification.userInfo! as NSDictionary
        let urlStr = (dicNotifi["extras"] as? NSDictionary)?["url"]
        
        print(urlStr as Any)
    }
}


// MARK: - WKNavigationDelegate
extension ViewController : WKNavigationDelegate,WKUIDelegate {
    
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {

        print(error.localizedDescription)
    }
    
    ///开始加载
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    
    /// 加载完成
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.navigationItem.title = webView.title
        //解决ios9 以上机型长按弹出alertController的问题，但是有时候灵，有时候不灵验
        self.webView.evaluateJavaScript("document.documentElement.style.webkitTouchCallout='none';", completionHandler: nil)

        
        self.refreshControl.endRefreshing()
    }
    
    
    /// 设置别名
    func setAlias1() -> String {
        return tokenStr!
    }
    
    
    @available(iOS 10.0, *)
    func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKPreviewElementInfo) -> Bool {
        return false
    }
    
    
    // MARK:- 允许拦截
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        let ddd = (navigationAction.request.url?.absoluteString)!
        decisionHandler(.allow)
   
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let msg = message.name
     
        if msg == "shareWeixinInfo" {
            print("shareWeixinInfo")
            
            print(message.body)
            
            if message.body is String {
                JPUSHService.setAlias(message.body as! String, completion: { (iResCode, iAlias, seq) in
                    
                }, seq: Int(arc4random()))
            }
        }
        
        if msg == "setAlias" {
            print("...........")
            print(message.body)
            print("...........")
            
            let dic = message.body as? NSDictionary
            print(dic?["content"] as Any)
            
            if let aliasStr = dic?["content"] as? String {
                JPUSHService.setAlias(aliasStr, completion: { (iResCode, iAlias, seq) in
                    print(";;;;;;;;;;;")
                }, seq: Int(arc4random()))
            }
        }
    }
}



// MARK:- 弱引用交互事件
class LeakAvoider : NSObject, WKScriptMessageHandler {
    weak var delegate : WKScriptMessageHandler?
    init(delegate:WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }
    
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        self.delegate?.userContentController(
            userContentController, didReceive: message)
    }
}
