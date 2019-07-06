//
//  GoogleUser.swift
//  ThrillingPicks
//
//  Created by iOSDev on 5/20/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit
import GoogleSignIn

class GoogleUser: NSObject, GIDSignInDelegate, GIDSignInUIDelegate {
    /// Delegate
    var delegate:SourceLoginProtocol?
    
    //MARK: Initialisation
    /**
     This is called when need to initiate class
     */
    override init() { }
    
    //MARK: Dienit class
    /**
     This function is used to De-Allocate the class objects
     */
    deinit { }
    
    //MARK: Sign in delegate
    /**
     Delegate called when required to Sign in a user using gmail Logging
     - parameter signIn : Google Sign In Reference
     - parameter user : Google User which have all the required Details for logging user in App
     - parameter signIn : Error if while logging occurs
     */
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            print("Error while Login Google ==> \(error.localizedDescription)")
            self.delegate?.loginOutput(LoginType: .google, Success: false, Error: error, Message: nil)
        } else {
            /// Fetch Data]
            SocialUser.fullName = user.profile.name
            SocialUser.email = user.profile.email
            SocialUser.socialID = user.userID
            SocialUser.socialMediaPlatformName = .google
            
            WebService.wsSocialLoginAPI(SocialID: SocialUser.socialID!, SocialPlatform: .facebook, success: { (success, signupScreenBool, msg) in
                if success {
                    /// When Login is Succeeded
                    if signupScreenBool {
                        /// When we want to navigate to signup Screen
                        self.delegate?.navigateToSignupScreen()
                    } else {
                        self.delegate?.loginOutput(LoginType: .google, Success: success, Error: nil, Message: msg)
                    }
                } else {
                    self.delegate?.loginOutput(LoginType: .google, Success: success, Error: nil, Message: msg)
                }
            }, failure: { (error) in
                self.delegate?.loginOutput(LoginType: .google, Success: false, Error: error, Message: nil)
            })
        }
    }
    
    //MARK: Delegate Required Method //Crash Cause
    /**
     Function called Presenting Screen for Login
     - parameter signIn : Google Sign In Reference
     - parameter viewController : viewController to be presented
     */
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) { }
    
    //MARK: Delegate Required Method //Crash Cause
    /**
     Function called Dismissing screen of Login
     - parameter signIn : Google Sign In Reference
     - parameter viewController : viewController to be presented
     */
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) { }
    
    //MARK: Configure Gmail User Delegates
    /**
     Function Configures Google Login With ID and Delegate
     - returns: Configuration For Gmail
     */
    func configureGmailLogin() {
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().clientID = "495990264763-qicu1af082emegtfpeoq7fflqddauf2r.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().signIn()
    }
}
