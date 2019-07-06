//
//  AppDelegate.swift
//  ThrillingPicks
//
//  Created by iOSDeveloper on 5/7/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import GoogleSignIn
import Stripe
import FacebookCore
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        AppEvents.activateApp()
        STPPaymentConfiguration.shared().publishableKey = STripeTestKet
        FirebaseConfiguration.shared.setLoggerLevel(.error)
        FirebaseApp.configure()
        
        if let loggedData = UserDefaults.standard.object(forKey: loggedUserKey) as? Data {
            do {
                let gitData = try JSONDecoder().decode(LoggedUser.self, from: loggedData)
                Global.LoggedUser = gitData
                let clUser = Global.LoggedUser!
                if !(clUser.userSubscriptionEndDate ?? "").trimmed().isEmpty {
                    /// We've subscription End Date
                    /// Check is End Date less than current Date
                    if Functions.getDateFrom(DateString: clUser.userSubscriptionEndDate!, With: .YYYYMMDD) < Date() {
                        /// End Date is less than Navigate to Subscription End Date
                        let rootViewController = SubscriptionListVC.instantiateFromStoryboard(storyboard: homeStoryBoard)
                        rootViewController.isLoginFlow = true
                        let nav = UINavigationController(rootViewController: rootViewController)
                        nav.setNavigationBarHidden(true, animated: false)
                        self.window?.rootViewController = nav
                        return true
                    } else {
                        /// Woah! it's paid user. let's go to Home screen
                        let rootViewController:BaseHomeVC = BaseHomeVC.instantiateFromStoryboard(storyboard: homeStoryBoard)
                        let nav = UINavigationController(rootViewController: rootViewController)
                        nav.setNavigationBarHidden(true, animated: false)
                        self.window?.rootViewController = nav
                        return true
                    }
                } else {
                    /// We've no subscription Date
                    let rootViewController = SubscriptionListVC.instantiateFromStoryboard(storyboard: homeStoryBoard)
                    rootViewController.isLoginFlow = true
                    let nav = UINavigationController(rootViewController: rootViewController)
                    nav.setNavigationBarHidden(true, animated: false)
                    self.window?.rootViewController = nav
                    return true
                }
            } catch {
                Global.LoggedUser = nil
                print("Error ==> \(error.localizedDescription)")
            }
        } else { print("no Data is saved") }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let gSigner = GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        let fSigner=ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        return gSigner || fSigner
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,sourceApplication: sourceApplication,annotation: annotation)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

