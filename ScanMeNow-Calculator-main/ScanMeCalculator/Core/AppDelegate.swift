//
//  AppDelegate.swift
//  ScanMeCalculator
//
//  Created by Zein Rezky Chandra on 27/03/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setupUIAppreance()
        
        return true
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

    private func setupUIAppreance() {
        #if GreenBuiltInCamera || GreenCameraRoll
        UITableViewCell.appearance().tintColor = UIColor.systemGreen
        UISwitch.appearance().onTintColor = UIColor.systemGreen
        UINavigationBar.appearance().tintColor = UIColor.systemGreen
        UIButton.appearance().tintColor = UIColor.systemGreen
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemGreen]
        #elseif RedBuiltInCamera || RedCameraRoll
        UITableViewCell.appearance().tintColor = UIColor.red
        UISwitch.appearance().onTintColor = UIColor.red
        UIButton.appearance().tintColor = UIColor.red
        UINavigationBar.appearance().tintColor = UIColor.red
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.red]
        #endif
    }

}

