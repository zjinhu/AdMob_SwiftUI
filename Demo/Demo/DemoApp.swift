//
//  DemoApp.swift
//  Demo
//
//  Created by 狄烨 on 2023/10/18.
//

import SwiftUI
import AdMob_SwiftUI
@main
struct DemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .checkADTracking()
                .adSplash(adUnitID: "ca-app-pub-3278026778756846/4631954192") {
                    print("启动广告关闭,打开内购页面")
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        AdManager.initAD()
        return true
    }
    
}
