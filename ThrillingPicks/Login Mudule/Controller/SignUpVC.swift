//
//  SignUpVC.swift
//  ThrillingPicks
//
//  Created by iOSDeveloper on 5/8/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit

class SignUpVC: UIViewController {
    /// Full Name TF
    @IBOutlet weak var fullNameTF: UITextField!
    /// EMail TF
    @IBOutlet weak var emailTF: UITextField!
    /// Confirm Email TF
    @IBOutlet weak var confirmEmailTF: UITextField!
    /// Password TF
    @IBOutlet weak var passwordTF: UITextField!
    /// DOB TF
    @IBOutlet weak var dobTF: UITextField!
    /// Promocode TF
    @IBOutlet weak var promocodeTF: UITextField!
    /// Login Btn
    @IBOutlet weak var signupBtn: UIButton!
    /// Main ScrollView
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    /// Date Picker
    fileprivate var myInputDatePicker = UIDatePicker()
    /// Screen Tap Gesture
    fileprivate var screenTapGesture: UITapGestureRecognizer?
    /// Selected DOB
    fileprivate var selectedDob: Date?
    /// is Email Field Editable
    var isEmailFieldEditable: Bool = true
}

//MARK:- View Life Cycles
extension SignUpVC {
    //MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        myInputDatePicker.datePickerMode = .date
        myInputDatePicker.maximumDate = Date()
        myInputDatePicker.date = Date()
        dobTF.inputView = myInputDatePicker
        myInputDatePicker.addTarget(self, action: #selector(birthDateChanged(Sender:)), for: .valueChanged)
    }
    
    //MARK: View Will Appear
    override func viewWillAppear(_ animated: Bool) {
        isEmailFieldEditable ? (emailTF.isUserInteractionEnabled = true) : (emailTF.isUserInteractionEnabled = false)
        fullNameTF.text = SocialUser.fullName ?? nil
        emailTF.text = SocialUser.email ?? nil
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
        if self.isMovingFromParent {
            Functions.removeSocialStruct()
        }
    }
    
    //MARK: View Did Layout Subviews
    override func viewDidLayoutSubviews() {
        signupBtn.roundWithRadious(Radius: 6)
    }
}

//MARK:- Required Functions
extension SignUpVC {
    //MARK: Validate & Signup
    private func validateAndSignUp() {
        self.view.endEditing(true)
        if fullNameTF.trimmed().isEmpty {
            self.view.makeToast("Enter Name")
        } else if !fullNameTF.hasOnlyCharacters() {
            self.view.makeToast("Enter Valid Full Name")
        } else if emailTF.trimmed().isEmpty {
            self.view.makeToast("Enter Email")
        } else if !emailTF.trimmed().isValidEmail() {
            self.view.makeToast("Enter Valid Email")
        } else if confirmEmailTF.trimmed().isEmpty {
            self.view.makeToast("Please Enter confirm Email")
        } else if emailTF.trimmed() != confirmEmailTF.trimmed() {
            self.view.makeToast("Email entered doesn't match with confirm email.")
        } else if passwordTF.trimmed().isEmpty {
            self.view.makeToast("Enter password")
        } else if passwordTF.trimmed().count < 5 || !passwordTF.checkContainNumber() {
            self.view.makeToast("The Password length must be atleast 6 characters & it should contain atleast one number.")
        } else if dobTF.trimmed().isEmpty {
            self.view.makeToast("Select DOB")
        } else {
            /// HIT API
            signupUserWithDetails()
        }
    }
    
    //MARK: Date Picker Handler
    @objc func birthDateChanged(Sender sender: UIDatePicker) {
        selectedDob = sender.date
        dobTF.text = sender.date.getDateFormattedInString(of: .MMDDYYYY)
    }
    
    //MARK: Screen Tap Handler
    @objc func screenTapHandler(Sender sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}

//MARK:- API Handler
extension SignUpVC {
    //MARK: Signup user
    private func signupUserWithDetails() {
        Functions.shared.showActivityIndicator("Loading", view: self)
        WebService.wsSignupUserWith(Name: fullNameTF.trimmed(), Email: emailTF.trimmed(), Password: passwordTF.trimmed(), DOB: selectedDob!.getDateFormattedInString(of: .YYYYMMDD), Promocode: promocodeTF.trimmed(), SocialName: SocialUser.socialMediaPlatformName == nil ? ("") : (SocialUser.socialMediaPlatformName!.rawValue), SocialID: (SocialUser.socialID ?? "").trimmed().isEmpty ? ("") : (SocialUser.socialID!), success: { (success, msg) in
            Functions.shared.hideActivityIndicator()
            if !success {
                if !msg.isEmpty { self.showAlert(AlertTitle: TAppName, AlertMessage: msg) }
            } else {
                print("Signup Success. Proceed to payment screen")
                Functions.removeSocialStruct()
                Functions.homeFlowHanlder(With: self.navigationController)
            }
        }) { (error) in
            Functions.shared.hideActivityIndicator()
            self.showAlert(AlertTitle: TAppName, AlertMessage: error.localizedDescription)
        }
    }
}

//MARK:- UITextField Delegates
extension SignUpVC: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == dobTF {
            let numberToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
            numberToolbar.barStyle = .default
            numberToolbar.items = [
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneWithNumberPad))]
            numberToolbar.sizeToFit()
            textField.inputAccessoryView = numberToolbar
        } else {
            textField.inputAccessoryView = nil
        }
        return true
    }
    
    @objc func doneWithNumberPad() {
        self.view.endEditing(true)
    }
    //MARK: TF Should Return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case fullNameTF: isEmailFieldEditable == true ? (emailTF.becomeFirstResponder()) : (confirmEmailTF.becomeFirstResponder())
            case emailTF: confirmEmailTF.becomeFirstResponder()
            case confirmEmailTF: passwordTF.becomeFirstResponder()
            case passwordTF: dobTF.becomeFirstResponder()
            case dobTF: promocodeTF.becomeFirstResponder()
            default: validateAndSignUp()
        }
        return true
    }
    
    //MARK: Full Name Editing Changed
    @IBAction func fullNameTFEditingChanged(_ sender: UITextField) {
        print(fullNameTF.hasOnlyCharacters())
        if !fullNameTF.hasOnlyCharacters() {
            fullNameTF.deleteBackward()
        }
    }
}

//MARK:- Button Actions
extension SignUpVC {
    //MARK: Switch To Sign In Screen
    @IBAction func switchToSignInBtnAction(_ sender: Any) {
        var controllerFound: Bool=false
        for controller in self.navigationController?.viewControllers ?? [] {
            if controller.isKind(of: SignInVC.self) {
                controllerFound=true
                self.navigationController?.popToViewController(controller, animated: true)
                break
            }
        }
        if !controllerFound {
            let vc = SignInVC.instantiateFromStoryboard(storyboard: mainStoryBoard)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK: Back Action
    @IBAction func backBtnAction(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    //MRK: Sign Up Btn Action
    @IBAction func signupBtnAction(_ sender: UIButton) {
        validateAndSignUp()
    }
}

//MARK:- Keyboard Handler
extension SignUpVC {
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

