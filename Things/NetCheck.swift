//
//  NetCheck.swift
//  NetworkStatus
//
//  Created by 郑东喜 on 2017/3/31.
//  Copyright © 2017年 com.personal. All rights reserved.
//

import UIKit

class NetCheck: NSObject {
    
    var hostReachability = Reachability()
    
    var routerReachability = Reachability()
    
    static let shared = NetCheck()
    
    var comfun:((_ _data:NetworkStatus)->Void)?
    
    
    
    /// 网络鉴别
    ///
    /// - Parameter _com: 返回NetCode(0,1,2)
    /// - Parameter _com: 0 为没网络  1无线网络  2WWAN(蜂窝)
    func xxx(getNetCode _com: @escaping (_ _data:NetworkStatus)->Void) -> Void {
        
        comfun = _com
        
        NotificationCenter.default.addObserver(self, selector: #selector(appReachabilityChanged(notification:)), name: NSNotification.Name.reachabilityChanged, object: nil)
        
        appleReachabilityTest()
    }
    
    
    /// 测试网络连通
    func appleReachabilityTest() {
        /// Reachability使用了通知，当网络状态发生变化时发送通知kReachabilityChangedNotification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.appReachabilityChanged),
                                               name: NSNotification.Name.reachabilityChanged,
                                               object: nil)
        
        // 被通知函数运行的线程应该由startNotifier函数执行的线程决定
        DispatchQueue.main.async {[weak self] in
            
            
            let remoteHostName: String = "www.bing.com"
            self?.hostReachability = Reachability(hostName: remoteHostName)
            self?.hostReachability.startNotifier()
            
            self?.routerReachability = Reachability.forInternetConnection()
            self?.routerReachability.startNotifier()
        }
    }
    
    func appReachabilityChanged(notification : Notification) -> Void {
        let reach: Reachability? = notification.object as! Reachability?
        if (reach?.isKind(of: Reachability.self))! {
            let status: NetworkStatus? = reach?.currentReachabilityStatus()
            
            self.comfun!(status!)
            
            /// 去除通知，防止循环引用。。
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.reachabilityChanged, object: nil)
        }
    }
}
