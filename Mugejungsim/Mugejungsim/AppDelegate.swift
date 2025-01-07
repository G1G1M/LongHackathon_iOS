//
//  AppDelegate.swift
//  Mugejungsim
//
//  Created by 도현학 on 12/22/24.
//

import UIKit
import KakaoSDKAuth
import KakaoSDKCommon
import UserNotifications


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        KakaoSDK.initSDK(appKey: "429132fa3a9dab5a2dbb2bd18eec5f75")
        return true
    }
    // URL Scheme으로 앱이 열렸을 때 처리
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if AuthApi.isKakaoTalkLoginUrl(url) {
            return AuthController.handleOpenUrl(url: url)
        }
        return false
    }
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // 알림을 클릭했을 때 특정 페이지로 이동
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
            
        if let page = userInfo["page"] as? String {
            DispatchQueue.main.async {
                if let window = UIApplication.shared.windows.first {
                    let rootViewController = window.rootViewController
                        
                    if page == "MyRecordsViewController" {
                        let myRecordsVC = MyRecordsViewController()
                        myRecordsVC.modalPresentationStyle = .fullScreen
                        rootViewController?.present(myRecordsVC, animated: true, completion: nil)
                    }
                        
                    if page == "LoginViewController" {
                        let otherVC = LoginViewController()
                        otherVC.modalPresentationStyle = .fullScreen
                        rootViewController?.present(otherVC, animated: true, completion: nil)
                    }
                }
            }
        }
        completionHandler()
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
}
