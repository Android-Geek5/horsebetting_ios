//
//  LoginHandler.swift
//  ThrillingPicks
//
//  Created by iOSDev on 5/20/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit

enum LoginType: String {
    case facebook = "facebook"
    case google = "google"
    case email = "email"
}

protocol SourceLoginProtocol {
    //MARK: Login Output
    /**
     This protocol is used to get the output from Social Login Classes
     - parameter loginType : Return Type is Facebook,Google or Email
     - parameter success : Returns true if Login is Successful
     - parameter error : returns Error is there is any Error while logging in
     */
    func loginOutput(LoginType type: LoginType, Success success: Bool, Error error:Error?, Message message: String?)
    
    //MARK: is Login Cancelled ?
    /**
     This protocol is used to check is login was cancelled
     - parameter loginType : Return Type is Facebook,Google or Email
     - parameter isCancelled : Returns true if Login is canceled
     */
    func loginCancelled(LoginType type: LoginType , Cancelled cancelled: Bool)
    
    //MARK: Navigate To Signup screen
    func navigateToSignupScreen()
}

class LoginNetworkManager: NSObject {
    
    /// facebook User class Object
    private var facebookClass : FacebookUser?
    /// Google User Class Object
    private var googleClass : GoogleUser?
    /// Email User
    private var emailClass: EmailUser?
    
    /// Delegate
    var delegate:SourceLoginProtocol?
    
    //MARK: Initialise Class
    /**
     This function is used to Initialise the class
     */
    override init() {}
    
    //MARK: Dienit class
    /**
     This function is used to De-Allocate the class objects
     */
    deinit {
        facebookClass = nil
        googleClass = nil
        emailClass=nil
    }
    
    //MARK: Facebook Login
    /**
     This function is used to login user using Facebook Account
     */
    func loginWithFacebook(_ viewcontroller: UIViewController) {
        facebookClass = FacebookUser()
        facebookClass?.delegate=self
        facebookClass?.configureFacebookLogin(viewcontroller)
    }
    
    //MARK: Google Login
    /**
     This function is used to login user using Google Account
     */
    func loginWithGoogle() {
        googleClass = GoogleUser()
        googleClass?.delegate=self
        googleClass?.configureGmailLogin()
    }
    
    //MARK: Login With Email
    func loginWithEmail(Email email: String, Password password: String) {
        emailClass=EmailUser()
        emailClass?.delegate=self
        emailClass?.loginUser(Email: email, Password: password)
    }
}

//MARK:- Delegate Handler
extension LoginNetworkManager: SourceLoginProtocol {
    func loginOutput(LoginType type: LoginType, Success success: Bool, Error error: Error?, Message message: String?) {
        self.delegate?.loginOutput(LoginType: type, Success: success, Error: error, Message: message)
    }
    
    func loginCancelled(LoginType type: LoginType, Cancelled cancelled: Bool) {
        self.delegate?.loginCancelled(LoginType: type, Cancelled: cancelled)
    }
    
    func navigateToSignupScreen() {
        self.delegate?.navigateToSignupScreen()
    }
}
