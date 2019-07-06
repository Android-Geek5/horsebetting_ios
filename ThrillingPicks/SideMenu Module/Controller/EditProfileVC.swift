//
//  EditProfileVC.swift
//  ThrillingPicks
//
//  Created by iOSDev on 6/5/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit

class EditProfileVC: UIViewController {
    /// Main ScrollView
    @IBOutlet weak var mainScrollView: UIScrollView!
    /// Name TF
    @IBOutlet weak var nameTF: UITextField!
    /// Email TF
    @IBOutlet weak var emailIDTF: UITextField!
    /// Dob TF
    @IBOutlet weak var dobTF: UITextField!
    
    /// Edit Save Button
    @IBOutlet weak var editSaveBtn: UIButton!
    /// Profile imageView
    @IBOutlet weak var profileImageView: UIImageView!
    /// Full Name Label
    @IBOutlet weak var fullNameLabel: UILabel!
    /// Camera Image BaseView
    @IBOutlet weak var cameraImageBaseView: UIView!
    /// Intro BaseView
    @IBOutlet weak var introBaseView: UIView!
    
    /// ToolBar
    fileprivate var numberToolbar: UIToolbar?
    /// Is Editing in Progress ?
    fileprivate var isEditingInProgress: Bool = false
    /// Screen Tap Gesture
    fileprivate var screenTapGesture: UITapGestureRecognizer?
    /// Date Picker
    fileprivate var myInputDatePicker = UIDatePicker()
    /// Selected DOB
    fileprivate var selectedDob: Date?
    /// Image Uploaded
    fileprivate var imageSelected: UIImage? {
        didSet {
            self.profileImageView.image = self.imageSelected ?? UIImage(named: "user")
        }
    }
    /// Active TF
    fileprivate var activeTF: UITextField?
    
}

//MARK- View Life Cycles
extension EditProfileVC {
    //MARK: Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        myInputDatePicker.datePickerMode = .date
        myInputDatePicker.maximumDate = Date()
        
        dobTF.inputView = myInputDatePicker
        fullNameLabel.text = Global.LoggedUser?.name ?? nil
        emailIDTF.text = Global.LoggedUser?.email ?? nil
        nameTF.text = Global.LoggedUser?.name ?? nil
        dobTF.text = Global.LoggedUser?.dob ?? nil
        !(Global.LoggedUser?.dob ?? "").trimmed().isEmpty ? (selectedDob = Functions.getDateFrom(DateString: Global.LoggedUser!.dob!, With: .YYYYMMDD)) : (selectedDob = nil)
        profileImageView.sd_setImage(with: URL(string: Global.LoggedUser?.userProfileImageURL ?? ""), placeholderImage: UIImage(named: "user"), options: .continueInBackground, context: nil)
        selectedDob != nil ? (myInputDatePicker.date = selectedDob!) : (myInputDatePicker.date = Date())
        myInputDatePicker.addTarget(self, action: #selector(birthDateChanged(Sender:)), for: .valueChanged)
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
    
    //MARK: Did Layout Subviews
    override func viewDidLayoutSubviews() {
        profileImageView.roundWithRadious(Radius: profileImageView.frame.height/2)
        editSaveBtn.roundWithRadious(Radius: 6)
        cameraImageBaseView.roundWithRadious(Radius: cameraImageBaseView.frame.height/2)
        introBaseView.roundWithRadious(Radius: 6)
        introBaseView.addShadowToView(ShadowColor: .black, Opacity: 0.3, Radius: 5, Size: .zero)
    }
}

//MARK:_ Required Functions
extension EditProfileVC {
    //MARK: Date Picker Handler
    @objc func birthDateChanged(Sender sender: UIDatePicker) {
        selectedDob = sender.date
        dobTF.text = sender.date.getDateFormattedInString(of: .YYYYMMDD)
    }
    
    //MARK: Screen Tap Handler
    @objc func screenTapHandler(Sender sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //MARK: ToolBar Done Btn Action
    @objc
    func toolbarDoneBtnAction() {
        self.view.endEditing(true)
    }
    
    //MArk: Add TF Input Accessory View
    private func addInputAccessoryView() {
        /// Active TF
        guard let activeTF = self.activeTF else {
            return
        }
        
        if !isEditingInProgress {
            self.activeTF = nil
            activeTF.resignFirstResponder()
        }
        
        /// Check is TF is DOB TF
        if activeTF == dobTF {
            let numberToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
            numberToolbar.barStyle = .default
            numberToolbar.items = [
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(toolbarDoneBtnAction))
            ]
            numberToolbar.sizeToFit()
            activeTF.inputAccessoryView = numberToolbar
        } else {
            activeTF.inputAccessoryView = nil
        }
    }
    
    //MARK: Update Data On Server
    private func validateDataOnServer() {
        guard let _ = selectedDob else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.showAlert(AlertTitle: TAppName, AlertMessage: "Please select DOB")
            }
            editSaveBtn.setTitle("Save", for: .normal)
            return
        }
        
        if nameTF.trimmed().isEmpty {
            editSaveBtn.setTitle("Save", for: .normal)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.showAlert(AlertTitle: TAppName, AlertMessage: "Enter Full Name")
            }
            return
        }
        
        /// Hit Server API
        self.view.endEditing(true)

        Functions.shared.showActivityIndicator("Loading", view: self)
        
        var imgData: Data?
        if imageSelected != nil {
            imgData = imageSelected!.jpegData(compressionQuality: 0.5)
        }
        WebService.wsUpdateProfileInfoToServer(Name: nameTF.trimmed(), Email: emailIDTF.trimmed(), DOB: dobTF.trimmed(), ImageData: imgData, success: { (success, msg, imgURL) in
            Functions.shared.hideActivityIndicator()
            print("Updation Success: \(success)")
            if !(msg ?? "").trimmed().isEmpty { self.showAlert(AlertTitle: TAppName, AlertMessage: msg!) }
            /// Check do we rx imageURL
            if let imgURL = imgURL {
                /// Remove local image ref to avoid re-Uploading of image selected
                self.imageSelected = nil
                self.profileImageView.sd_setImage(with: URL(string: imgURL), placeholderImage: UIImage(named: "user"), options: .continueInBackground, context: nil)
            }
        }) { (logoutBool, errorMsg) in
            Functions.shared.hideActivityIndicator()
            if logoutBool {
                Functions.logoutUser(With: self.navigationController!)
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                if !(errorMsg ?? "").trimmed().isEmpty { self.showAlert(AlertTitle: TAppName, AlertMessage: errorMsg!) }
            })
        }
    }
}

//MARK:- Button Actions
extension EditProfileVC {
    //MARK: Update New Profile Image Actiom
    @IBAction func updateProfilePicBtnAction(_ sender: Any) {
        if !isEditingInProgress { return }
        let vc = UploadImagePopupVC.instantiateFromStoryboard(storyboard: sideMenuStoryBoard)
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
    }
    
    //MARK: Edit Save Image Btn Action
    @IBAction func editSaveBtnaction(_ sender: UIButton) {
        isEditingInProgress = !isEditingInProgress
        if isEditingInProgress {
            /// We need to Edit Data
            sender.setTitle("Save", for: .normal)
        } else {
            /// Save Editing Made
            sender.setTitle("Edit", for: .normal)
            validateDataOnServer()
        }
    }
    
    //MARK: Back Button Action
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: Upload Image Protocol
extension EditProfileVC: UploadImageVCProtocol {
    //MARK: Image Selected
    func showSelectedImageFromPickerWith(Image img: UIImage?, URL imgURL: URL?) {
        guard let img = img else {
            return
        }
        imageSelected = img
        profileImageView.image = img
    }
}

//MARK:- TextField Delagtes
extension EditProfileVC: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeTF = textField
        if textField == dobTF {
            addInputAccessoryView()
        } else {
            textField.inputAccessoryView = nil
        }
        return true
    }
    //MARK: TF Should Begin Editing
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !isEditingInProgress {
            textField.resignFirstResponder()
        }
        activeTF = dobTF
        if textField == dobTF {
            selectedDob != nil ? (myInputDatePicker.date = selectedDob!) : (myInputDatePicker.date = Date())
        }
    }
    //MARK: TF Should Return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !isEditingInProgress {
            textField.resignFirstResponder()
        }
        switch textField {
            case nameTF: dobTF.becomeFirstResponder()
            case dobTF: break
            default: textField.resignFirstResponder()
        }
        return true
    }
    
    //MARK: Full Name TF Editing Changed
    @IBAction func fullNameTFEditingChanged(_ sender: UITextField) {
        if !nameTF.hasOnlyCharacters() {
            nameTF.deleteBackward()
        }
    }
}

//MARK:- Keyboard Handler
extension EditProfileVC {
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

