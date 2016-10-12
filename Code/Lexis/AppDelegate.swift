//
//  AppDelegate.swift
//  Lexis
//
//  Created by Wellington Moreno on 8/20/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import AromaSwiftClient
import Archeota
import Crashlytics
import Fabric
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{

    var window: UIWindow?

    private let buildNumber: String = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String ?? ""

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
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
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication)
    {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication)
    {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        AromaClient.sendLowPriorityMessage(withTitle: "App Entered Background")
    }

    func applicationWillEnterForeground(_ application: UIApplication)
    {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication)
    {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication)
    {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        AromaClient.sendMediumPriorityMessage(withTitle: "App Terminated")
    }

    func applicationDidReceiveMemoryWarning(_ application: UIApplication)
    {
        AromaClient.beginMessage(withTitle: "Memory Warning")
            .withPriority(.medium)
            .addBody("Build #\(buildNumber)")
            .send()
    }

}

