//
//  SignInVC.swift
//  ThrillingPicks
//
//  Created by iOSDeveloper on 5/8/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit

class SignInVC: UIViewController {
    /// Email TF
    @IBOutlet weak var emailTF: UITextField!
    /// Password TF
    @IBOutlet weak var passwordTF: UITextField!
    /// Login Btn
    @IBOutlet weak var loginBtn: UIButton!
    /// FB Login Btn
    @IBOutlet weak var fbLoginBtn: UIButton!
    /// Google Login Btn
    @IBOutlet weak var googleLoginBtn: UIButton!
    /// Main ScrollView
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    /// Social Network Class Object
    fileprivate var loginNetManager : LoginNetworkManager?
    /// Screen Tap Gesture
    fileprivate var screenTapGesture: UITapGestureRecognizer?
}

//MARK:- View Life Cycles
extension SignInVC {
    //MARK: Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.enablePopNavGesture()
    }
    
    //MARK: View Will Appear
    override func viewWillAppear(_ animated: Bool) {
//        emailTF.text = "test1@test.com"
//        passwordTF.text = "qqqqqq1"
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
    
    //MARK: Layout Subviews
    override func viewDidLayoutSubviews() {
        loginBtn.roundWithRadious(Radius: 6)
        fbLoginBtn.roundWithRadious(Radius: 6)
        googleLoginBtn.roundWithRadious(Radius: 6)
    }
}

//MARK:- Required Functions
extension SignInVC {
    //MARK: Validate & Login
    private func validateAndLoginUser() {
        self.view.endEditing(true)
        if emailTF.trimmed().isEmpty {
            self.view.makeToast("Enter Email")
        } else if !emailTF.trimmed().isValidEmail() {
            self.view.makeToast("Please enter valid email.")
        } else if passwordTF.trimmed().isEmpty {
            self.view.makeToast("Enter Password")
        } else if passwordTF.trimmed().count < 6 {
            self.view.makeToast("The Password must be atleast 6 characters.")
        } else {
            /// Hit API
            Functions.shared.showActivityIndicator("Loading", view: self)
            loginNetManager = LoginNetworkManager()
            loginNetManager?.delegate=self
            loginNetManager?.loginWithEmail(Email: emailTF.trimmed(), Password: passwordTF.trimmed())
        }
    }
    
    //MARK: Screen Tap Handler
    @objc func screenTapHandler(Sender sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}

//MARK:- UITextField Delegates
extension SignInVC: UITextFieldDelegate {
    //MARK: TF Should Return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
            case emailTF: passwordTF.becomeFirstResponder()
            case passwordTF: validateAndLoginUser()
            default: break
        }
        return true
    }
}


//MARK:- Button Actions
extension SignInVC {
    //MARK: Switch To Signup screen
    @IBAction func switchToSIgnUpScreen(_ sender: Any) {
        var controllerFound: Bool=false
        for controller in self.navigationController?.viewControllers ?? [] {
            if controller.isKind(of: SignUpVC.self) {
                controllerFound=true
                self.navigationController?.popToViewController(controller, animated: true)
                break
            }
        }
        if !controllerFound {
            let vc = SignUpVC.instantiateFromStoryboard(storyboard: mainStoryBoard)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK: Back Action
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Social Login
    @IBAction func socialLoginAction(_ sender: UIButton) {
        loginNetManager = LoginNetworkManager()
        loginNetManager?.delegate=self
        Functions.shared.showActivityIndicator("Loading", view: self)
        switch sender.tag {
            case 1: loginNetManager?.loginWithFacebook(self)
            default: loginNetManager?.loginWithGoogle()
        }
    }
    
    //MARK: Email Login
    @IBAction func normalLoginAction(_ sender: Any) {
        validateAndLoginUser()
    }
    
    //MARK: Forgot Password
    @IBAction func forgotPasswordAction(_ sender: Any) {
        let vc = ForgotPasswordVC.instantiateFromStoryboard(storyboard: mainStoryBoard)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK:- Login Delegate
extension SignInVC: SourceLoginProtocol {
    func loginOutput(LoginType type: LoginType, Success success: Bool, Error error: Error?, Message message: String?) {
        Functions.shared.hideActivityIndicator()
        Functions.removeSocialStruct()
        if error != nil {
            self.showAlert(AlertTitle: TAppName, AlertMessage: error?.localizedDescription ?? "Error while logging in")
            return
        }
        if success {
            /// Login Succedded Navigate to Home Screen/Payment Screen
            print("Login Succedded")
            Functions.homeFlowHanlder(With: self.navigationController)
        } else {
            if !(message ?? "").trimmed().isEmpty { self.showAlert(AlertTitle: TAppName, AlertMessage: message!) }
        }
    }
    
    func loginCancelled(LoginType type: LoginType, Cancelled cancelled: Bool) {
        Functions.shared.hideActivityIndicator()
    }
    
    func navigateToSignupScreen() {
        Functions.shared.hideActivityIndicator()
        var controllerFound: Bool=false
        for controller in self.navigationController?.viewControllers ?? [] {
            if controller.isKind(of: SignUpVC.self) {
                controllerFound=true
                (controller as! SignUpVC).isEmailFieldEditable = false
                self.navigationController?.popToViewController(controller, animated: true)
                break
            }
        }
        if !controllerFound {
            let vc = SignUpVC.instantiateFromStoryboard(storyboard: mainStoryBoard)
            vc.isEmailFieldEditable = false
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//MARK:- Keyboard Handler
extension SignInVC {
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

