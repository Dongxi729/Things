//
//  UIWebVC.swift
//  Things
//
//  Created by 郑东喜 on 2017/7/5.
//  Copyright © 2017年 郑东喜. All rights reserved.
//

import UIKit

class UIWebVC: UIViewController {

    let urlStr : String = "http://39.108.179.192/app"
    
    lazy var webView: UIWebView = {
        let d : UIWebView = UIWebView.init(frame: CGRect.init(x: 0, y: 20, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 20))
        d.loadRequest(URLRequest.init(url: URL.init(string: self.urlStr)!, cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 10))
        return d
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.addSubview(webView)
        
        //获取自定义消息推送内容
        NotificationCenter.default.addObserver(self, selector: #selector(networkDidReceiveMessage(notification:)), name: NSNotification.Name.jpfNetworkDidReceiveMessage, object: nil)
    }
    
    func networkDidReceiveMessage(notification : Notification) -> Void {
        let userInfo = notification.userInfo
        let content = userInfo?["content"] as? String
        let extras = userInfo?["extras"] as? NSDictionary
        let customizeField = extras?["customizeField1"] as? String
        
        let alVC : UIAlertController = UIAlertController.init(title: content, message: customizeField, preferredStyle: .alert)
        
        //        alVC.addAction(UIAlertAction.init(title: "好的", style: .default, handler: nil))
        alVC.addAction(UIAlertAction.init(title: "好的", style: .default, handler: { (alert) in
            let dicNotifi = notification.userInfo! as NSDictionary
            let xxx = (dicNotifi["extras"] as? NSDictionary)?["url"] as! String
            
            print("执行")
            
            let vc = ViewController()
            vc.urlStr = xxx
            
            UIApplication.shared.keyWindow?.rootViewController = vc
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
