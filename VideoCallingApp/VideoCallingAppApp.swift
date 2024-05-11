//
//  VideoCallingAppApp.swift
//  VideoCallingApp
//
//  Created by Jaxxi.ai on 4/8/24.
//

import SwiftUI
import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import Stripe

// no changes in your AppDelegate class
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        StripeAPI.defaultPublishableKey = "pk_test_51PEFIZSGysvXgBPGnZXT1cL1FcEmCqDP7ERHadRyPq7x7IketzrVJMW0rndz5ExFEeDX448o05kERR5FCFWRzxgb00urtJBCZe"
        FirebaseApp.configure()
        return true
    }
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
}

@main
struct VideoCallingAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        let firebaseAuth = Auth.auth()
        WindowGroup {
//            ContentView()
//            LoginPage()
            MainRoutingScreen()
//            MainAuthScreen()
        }
    }
}
