//
//  AppDelegate.swift
//  github reps
//
//  Created by Vadim Patalakh on 12/6/18.
//  Copyright © 2018 Vadim Patalakh. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        MagicalRecord.setupCoreDataStack(withStoreNamed: "Repos")

        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        MagicalRecord.cleanUp()
    }
}
