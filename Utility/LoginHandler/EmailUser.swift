//
//  EmailUser.swift
//  ThrillingPicks
//
//  Created by iOSDev on 5/20/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit

class EmailUser: NSObject {
    /// Delegate
    var delegate:SourceLoginProtocol?
    
    //MARK: Initialisation
    /**
     This is called when need to initiate class
     */
    override init() { }
    
    //MARK: Login User on server
    /**
     This function is called when required to sign in a user
     - parameter email : email entered by user
     - parameter password : password Entered by user
     */
    func loginUser(Email email: String, Password password: String) {
        WebService.wsLoginUserWith(Email: email, Password: password, success: { (success, msg) in
            self.delegate?.loginOutput(LoginType: .email, Success: success, Error: nil, Message: msg)
        }) { (error) in
            self.delegate?.loginOutput(LoginType: .email, Success: false, Error: error, Message: nil)
        }
    }
}
