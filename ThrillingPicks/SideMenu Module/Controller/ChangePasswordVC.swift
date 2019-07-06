//
//  ChangePasswordVC.swift
//  ThrillingPicks
//
//  Created by iOSDev on 6/5/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit

class ChangePasswordVC: UIViewController {
    /// Main ScrollView
    @IBOutlet weak var mainScrollView: UIScrollView!
    /// Old Password TF
    @IBOutlet weak var oldPasswordTF: UITextField!
    /// New Password TF
    @IBOutlet weak var newPasswordTF: UITextField!
    /// Confirm Password TF
    @IBOutlet weak var confirmPasswordTF: UITextField!
    /// Submit Button
    @IBOutlet weak var submitBtn: UIButton!
    
    /// Screen Tap Gesture
    fileprivate var screenTapGesture: UITapGestureRecognizer?
}

//MARK:- View Life Cycles
extension ChangePasswordVC {
    //MARK: Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK: View Will Appear
    override func viewWillAppear(_ animated: Bool) {
        screenTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.screenTapHandler(Sender:)))
        self.mainScrollView.addGestureRecognizer(screenTapGesture!)
        self.view.addGestureRecognizer(screenTapGesture!)
        registerForKeyboardNotifications()
    }
    
    //MARK: View Will DisAppear
    override func viewWillDisappear(_ animated: Bool) {
        if screenTapGesture != nil {
            self.mainScrollView.removeGestureRecognizer(screenTapGesture!)
            self.view.removeGestureRecognizer(screenTapGesture!)
        }
        deregisterFromKeyboardNotifications()
    }
    
    //MARK: View Did Layout Subviews
    override func viewDidLayoutSubviews() {
        submitBtn.roundWithRadious(Radius: 6)
    }
}

//MARK:- Required Functions
extension ChangePasswordVC {
    //MARK: Screen Tap Handler
    @objc func screenTapHandler(Sender sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //MARK: Validate Fileds
    private func validateResetPassword() {
        if oldPasswordTF.trimmed().isEmpty {
            self.showAlert(AlertTitle: TAppName, AlertMessage: "Enter Old Password")
        } else if newPasswordTF.trimmed().isEmpty {
            self.showAlert(AlertTitle: TAppName, AlertMessage: "Enter New Password")
        } else if newPasswordTF.trimmed().count < 5 || !newPasswordTF.checkContainNumber() {
            self.view.makeToast("The Password length must be atleast 6 characters & it should contain atleast one number.")
        } else if confirmPasswordTF.trimmed().isEmpty {
            self.showAlert(AlertTitle: TAppName, AlertMessage: "Enter Confirm Password")
        } else if confirmPasswordTF.trimmed().count < 5 || !confirmPasswordTF.checkContainNumber() {
            self.view.makeToast("The Confirm Password length must be atleast 6 characters & it should contain atleast one number.")
        } else if newPasswordTF.trimmed() != confirmPasswordTF.trimmed() {
            self.showAlert(AlertTitle: TAppName, AlertMessage: "New Password & Confirm Password doesn't match.")
        } else {
            /// Hit Change Password API
            changePassword(OldPassword: oldPasswordTF.trimmed().md5, NewPassword: newPasswordTF.trimmed().md5)
        }
    }
}

//MARK:- API Handler
extension ChangePasswordVC {
    //MARK: Change Password API
    private func changePassword(OldPassword OP: String, NewPassword NP: String) {
        Functions.shared.showActivityIndicator("Loading", view: self)
        WebService.wsAppChangePassword(OldPassword: OP, NewPassword: NP, success: { (changes, msg) in
            Functions.shared.hideActivityIndicator()
            if changes {
               Functions.logoutUser(With: self.navigationController)
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                self.showAlert(AlertTitle: TAppName, AlertMessage: msg)
            })
        }) { (logoutBool, errorMsg) in
            Functions.shared.hideActivityIndicator()
            if logoutBool {
                Functions.logoutUser(With: self.navigationController)
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                if !(errorMsg ?? "").trimmed().isEmpty { self.showAlert(AlertTitle: TAppName, AlertMessage: errorMsg!) }
            })
        }
    }
}

//MARK:- Button Actions
extension ChangePasswordVC {
    //MARK: Submit Btn Action
    @IBAction func rsetPasswordBtnAction(_ sender: Any) {
        self.view.endEditing(true)
        validateResetPassword()
    }
    
    //MARK: Back Button Action
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK:- TextField Delegates
extension ChangePasswordVC: UITextFieldDelegate {
    //MARK: TF Should Return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
            case oldPasswordTF: newPasswordTF.becomeFirstResponder()
            case newPasswordTF: confirmPasswordTF.becomeFirstResponder()
            case confirmPasswordTF: validateResetPassword()
            default: break
        }
        return true
    }
}

//MARK:- Keyboard Handler
extension ChangePasswordVC {
    //MARK: Add Observer - Keyboard
    /**
     This function is used to Add All observers required for Keyboard
     */
    private func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK: Remove Observer - Keyboard
    /**
     This function is used to Remove All observers added
     */
    private func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK: Keyboard Show
    /**
     This is used to add the Keyboard Height to ScrollView for scrolling Effect
     - parameter notification : notification instance
     */
    @objc private func keyboardWasShown(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var contentInset:UIEdgeInsets = self.mainScrollView.contentInset
            contentInset.bottom = keyboardSize.height
            mainScrollView.contentInset = contentInset
        }
    }
    
    //MARK: Keyboard Hide
    /**
     This is used to retain the orignal Height of View
     - parameter notification : notification instance
     */
    @objc private func keyboardWillBeHidden(_ notification: Notification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        mainScrollView.contentInset = contentInset
    }
}

