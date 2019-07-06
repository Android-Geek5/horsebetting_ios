//
//  FacebookUser.swift
//  ThrillingPicks
//
//  Created by iOSDev on 5/20/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class FacebookUser: NSObject, LoginButtonDelegate {
    /// FBSDKLoginManager class object
    private var fbLoginManager : LoginManager?
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
    deinit {
        fbLoginManager = nil
    }
    
    //MARK: Configure Facebook
    /**
     This function is called when required to login Facebook
     - parameter viewcontroller : Controller in which Facebook login is initiated
     */
    func configureFacebookLogin(_ viewcontroller: UIViewController) {
        /// Set Current Profile as Nil
        Profile.current = nil
        fbLoginManager = LoginManager()
        fbLoginManager?.logOut()
        fbLoginManager?.logIn(permissions: ["public_profile","email"], from: viewcontroller, handler: { (result, error) in
            if error == nil {
                if result?.isCancelled ?? false {
                    print("Login is Cancelled")
                    self.delegate?.loginCancelled(LoginType: .facebook, Cancelled: true)
                    return
                }
                
                let fbloginresult : LoginManagerLoginResult = result!
                if fbloginresult.grantedPermissions.contains("email") {
                    self.getFBUserData(success: { (facebookData) in
                        print("Facebook Login Response:\(facebookData)")                        
                        SocialUser.fullName = Functions.getStringValueForNum(facebookData["name"] as Any)
                        SocialUser.socialMediaPlatformName = .facebook
                        /* ---> Not Needed For Now
                        let fullNameSplittedArray:[String] = SocialUser.fullName!.components(separatedBy: " ")
                        switch fullNameSplittedArray.count {
                            case 0: SocialUser.firstName = ""; SocialUser.lastName=""
                            case 1: SocialUser.firstName = fullNameSplittedArray[0]; SocialUser.lastName=""
                            case 2: SocialUser.firstName = fullNameSplittedArray[0]; SocialUser.lastName = fullNameSplittedArray[1]
                            case 3: SocialUser.firstName = fullNameSplittedArray[0]; SocialUser.lastName = fullNameSplittedArray[2]
                            default: SocialUser.firstName = ""; SocialUser.lastName = ""
                        } */
                        
                        if let emailValue = facebookData["email"] as? String {
                            SocialUser.email = emailValue
                        } else {
                            SocialUser.email = nil
                        }
                        
                        SocialUser.socialID = Functions.getStringValueForNum(facebookData["id"] as Any)
                        
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
                    }, failure: { (error) in
                        print("Error Logging ==> \(error.localizedDescription)")
                        self.delegate?.loginOutput(LoginType: .facebook, Success: false, Error: error, Message: nil)
                    })
                } else {
                    /// Didn't Have Email Entered
                    self.delegate?.loginOutput(LoginType: .facebook, Success: true, Error: nil, Message: nil)
                }
            } else {
                print(error?.localizedDescription ?? "")
            }
        })
    }
    
    //MARK: Facebook Graph API
    /**
     This function handle the response from Facebook Graph API
     - parameter success : Returns [String:AnyObject] if login is Successfull
     - parameter failure : Returns Error if login is failed
     */
    func getFBUserData(success:@escaping ([String:AnyObject]) -> Void, failure:@escaping (Error) -> Void) {
        if AccessToken.current != nil {
            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, email,first_name, last_name"]).start(completionHandler: { (connection, result, error) -> Void in
                if error == nil { /// Dismiss Indicator Running
                    return success((result as? [String:AnyObject])!)
                } else { /// Error case
                    failure(error!)
                }
            })
        }
    }
    
    //MARK: Default delegate Method for Login
    /**
     Button Delegate for Facebook
     - parameter loginButton: FBLogin Button Instance
     */
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) { }
    
    //MARK: Default delegate Method for Logout
    /**
     Button Delegate for Facebook when Logout
     - parameter loginButton: FBLogin Button Instance
     */
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) { }
}
