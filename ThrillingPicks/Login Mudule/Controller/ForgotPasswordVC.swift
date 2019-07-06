//
//  ForgotPasswordVC.swift
//  ThrillingPicks
//
//  Created by iOSDev on 5/20/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit

class ForgotPasswordVC: UIViewController {

    /// Main ScrollView
    @IBOutlet weak var mainScrollView: UIScrollView!
    /// Email TF
    @IBOutlet weak var emailTF: UITextField!
    /// Submit Details Btn
    @IBOutlet weak var submitDetailBtn: UIButton!
    
    /// Screen Tap Gesture
    fileprivate var screenTapGesture: UITapGestureRecognizer?
}

//MARK:- View Life Cycles
extension ForgotPasswordVC {
    //MARK: Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
        submitDetailBtn.roundWithRadious(Radius: 6)
    }
}

//MARK:- Required Functions
extension ForgotPasswordVC {
    //MARK: Screen Tap Handler
    @objc func screenTapHandler(Sender sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}

//MARK:- Button Actions
extension ForgotPasswordVC {
    //MARK: Back Btn Action
    @IBAction func backBtnAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Submit Detail Action
    @IBAction func submitEmaiBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if emailTF.trimmed().isEmpty {
            self.view.makeToast("Enter Email")
        } else if !(emailTF.trimmed().isValidEmail()) {
            self.view.makeToast("Please enter valid email.")
        } else {
            /// Hit API
            Functions.shared.showActivityIndicator("Loading", view: self)
            WebService.wsUserForgotPassword(For: emailTF.trimmed(), success: { (success, msg) in
                Functions.shared.hideActivityIndicator()
                !msg.trimmed().isEmpty ? (self.showAlert(AlertTitle: TAppName, AlertMessage: msg)) : ()
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                    self.navigationController?.popViewController(animated: true)
                })
                
            }) { (error) in
                Functions.shared.hideActivityIndicator()
                self.showAlert(AlertTitle: TAppName, AlertMessage: error.localizedDescription)
            }
        }
    }
}

//MARK:- Keyboard Handler
extension ForgotPasswordVC {
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



