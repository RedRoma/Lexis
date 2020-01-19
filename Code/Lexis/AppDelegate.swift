//
//  AppDelegate.swift
//  Lexis
//
//  Created by Wellington Moreno on 8/20/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Archeota
import AromaSwiftClient
import Crashlytics
import Fabric
import Kingfisher
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{

    var window: UIWindow?

    private let buildNumber: String = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String ?? ""

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        LOG.level = .debug
        LOG.enable()
        
        AromaClient.TOKEN_ID = "655e0541-b719-47af-9c9e-53e161d26e53"
        
        AromaClient.beginMessage(withTitle: "App Launched")
            .addBody("Build #\(buildNumber)")
            .withPriority(.low)
            .send()
        
        Fabric.with([Crashlytics.self])
        
        NSSetUncaughtExceptionHandler() { error in
            
            AromaClient.beginMessage(withTitle: "App Crashed")
                .addBody("On Device: \(UIDevice.current.name)")
                .addLine(2)
                .addBody("\(error)")
                .withPriority(.high)
                .send()
            
            LOG.error("Uncaught Exception: \(error)")
        }
        
        ImageCache.default.diskStorage.config.sizeLimit = UInt(75.mb)
        ImageCache.default.diskStorage.config.expiration =  .days(3)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication)
    {
    }

    func applicationDidEnterBackground(_ application: UIApplication)
    {
        AromaClient.sendLowPriorityMessage(withTitle: "App Entered Background")
        ImageCache.default.clearMemoryCache()
        ImageCache.default.cleanExpiredDiskCache()
    }

    func applicationWillEnterForeground(_ application: UIApplication)
    {
    }

    func applicationDidBecomeActive(_ application: UIApplication)
    {
    }

    func applicationWillTerminate(_ application: UIApplication)
    {
        AromaClient.sendMediumPriorityMessage(withTitle: "App Terminated")
    }

    func applicationDidReceiveMemoryWarning(_ application: UIApplication)
    {
        AromaClient.beginMessage(withTitle: "Memory Warning")
            .withPriority(.medium)
            .addBody("Build #\(buildNumber)")
            .send()
        
        ImageCache.default.clearMemoryCache()
    }

}

