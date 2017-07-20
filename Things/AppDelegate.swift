//
//  AppDelegate.swift
//  Things
//
//  Created by 郑东喜 on 2017/7/5.
//  Copyright © 2017年 郑东喜. All rights reserved.
//

import UIKit

import UserNotifications

var tokenStr : String?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    //key
    let appKey = "e698eb8190760ea5b56a8f5c"
    
    //channel
    let channel = "Publish channel"
    
    //是否生产
    let isProduct : Bool = false

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //Required
        //notice: 3.0.0及以后版本注册可以这样写，也可以继续用之前的注册方式
        let entity : JPUSHRegisterEntity = JPUSHRegisterEntity()
        
        
        if #available(iOS 10, *) {
            let entity = JPUSHRegisterEntity()
            entity.types = NSInteger(UNAuthorizationOptions.alert.rawValue) |
                NSInteger(UNAuthorizationOptions.sound.rawValue) |
                NSInteger(UNAuthorizationOptions.badge.rawValue)
            JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self)
            
        } else if #available(iOS 8, *) {
            // 可以自定义 categories
            JPUSHService.register(
                forRemoteNotificationTypes: UIUserNotificationType.badge.rawValue |
                    UIUserNotificationType.sound.rawValue |
                    UIUserNotificationType.alert.rawValue,
                categories: nil)
        } else {
            // ios 8 以前 categories 必须为nil
            JPUSHService.register(
                forRemoteNotificationTypes: UIRemoteNotificationType.badge.rawValue |
                    UIRemoteNotificationType.sound.rawValue |
                    UIRemoteNotificationType.alert.rawValue,
                categories: nil)
        }
        
        // Required
        // init Push
        // notice: 2.1.5版本的SDK新增的注册方法，改成可上报IDFA，如果没有使用IDFA直接传nil
        // 如需继续使用pushConfig.plist文件声明appKey等配置内容，请依旧使用[JPUSHService setupWithOption:launchOptions]方式初始化。
        JPUSHService.setup(withOption: launchOptions, appKey: appKey, channel: channel, apsForProduction: isProduct)
        
        JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self)
        
        return true
    }
}



// MARK:- ios10 适配
extension AppDelegate :JPUSHRegisterDelegate {
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        JPUSHService.handleRemoteNotification(userInfo)
    }
    
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        
        //    let userInfo = response.notification.request.content.userInfo
        //    let request = response.notification.request // 收到推送的请求
        //    let content = request.content // 收到推送的消息内容
        //
        //    let badge = content.badge // 推送消息的角标
        //    let body = content.body   // 推送消息体
        //    let sound = content.sound // 推送消息的声音
        //    let subtitle = content.subtitle // 推送消息的副标题
        //    let title = content.title // 推送消息的标题
        
    }
    
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!,
                                 withCompletionHandler completionHandler: ((Int) -> Void)!) {
        //    let userInfo = notification.request.content.userInfo
        //
        //    let request = notification.request // 收到推送的请求
        //    let content = request.content // 收到推送的消息内容
        //
        //    let badge = content.badge // 推送消息的角标
        //    let body = content.body   // 推送消息体
        //    let sound = content.sound // 推送消息的声音
        //    let subtitle = content.subtitle // 推送消息的副标题
        //    let title = content.title // 推送消息的标题
    }
    
}


// MARK:- 注册token
extension AppDelegate {
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("get the deviceToken  \(deviceToken)")
        
        let token = String(data: deviceToken.base64EncodedData(), encoding: .utf8)?.trimmingCharacters(in: CharacterSet.whitespaces).trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
        tokenStr = token
        
        print("ddd",token)
        
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "DidRegisterRemoteNotification"), object: deviceToken)
        JPUSHService.registerDeviceToken(deviceToken)
        print(deviceToken)
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("did fail to register for remote notification with error ", error)
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        JPUSHService.handleRemoteNotification(userInfo)
        print("受到通知", userInfo)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "AddNotificationCount"), object: nil)  //把  要addnotificationcount
        print(userInfo)
    }
}

extension AppDelegate {
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}
