//
//  JPocketApp.swift
//  JPocket
//
//  Created by Ruby on 27/2/24.
//
import SwiftUI
import FirebaseCore

@main
struct JPocketApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: "isKeychainInitialized")
        if isFirstLaunch {
            let key = APIConfig.consumerKey
            let secret = APIConfig.consumerSecret
            saveToKeychain(key: "consumerKey", value: key)
            saveToKeychain(key: "consumerSecret", value: secret)
            UserDefaults.standard.set(true, forKey: "isKeychainInitialized")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
