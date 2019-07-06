//
//  AddNewCardVC.swift
//  ThrillingPicks
//
//  Created by iOSDev on 5/23/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit
import Stripe

protocol AddNewcardVCProtocol {
    func newCardAdded()
}

class AddNewCardVC: UIViewController {
    /// Main SrollView
    @IBOutlet weak var mainScrollVuew: UIScrollView!
    /// Card Num TF
    @IBOutlet weak var cardNumTF: SkyFloatingLabelTextFieldWithIcon!
    /// Expiry Date TF
    @IBOutlet weak var expiryTF: SkyFloatingLabelTextField!
    /// CVC TF
    @IBOutlet weak var cvcTF: SkyFloatingLabelTextField!
    /// Zip Code TF
    @IBOutlet weak var zipCodeTF: SkyFloatingLabelTextField!
    /// Card Holder Name TF
    @IBOutlet weak var cardHolderNameTF: SkyFloatingLabelTextField!
    /// Add To QuickPay Btn
    @IBOutlet weak var addToQuickPayBtn: UIButton!
    /// Pay Btn
    @IBOutlet weak var payBtn: UIButton!
    
    @IBOutlet weak var screenTitleLabel: UILabel!
    @IBOutlet weak var quickPayCheckBoxHeightContrsaint: NSLayoutConstraint!
    @IBOutlet weak var stackAddToQuickPayLabel: UILabel!
    @IBOutlet weak var stackQuickPayDescTextLabel: UILabel!
    
    /// Card Number Length
    fileprivate var cardNumberLength: Int = 12
    /// Max CVC Code Length
    fileprivate var maxCVVCodeLength: Int = 3
    /// Add To QuickPay
    fileprivate var addToQuickPay: Bool = false
    /// Selected Subscription
    var selectedSubscription: Subscription?
    /// ToolBar
    fileprivate var numberToolbar: UIToolbar?
    /// Active TF
    fileprivate var activeTF: UITextField?
    /// Update Card
    var isUpdateCard: Bool = false
    /// Card To Update
    var selectedCardToUpdate: CreditCard?
    /// Is From Login Flow
    var isFromLoginFlow: Bool = false
    /// Delegate
    var delegate: AddNewcardVCProtocol?
    /// Screen Tap Gesture
    fileprivate var screenTapGesture: UITapGestureRecognizer?
}

//MARK:- View Life Cycles
extension AddNewCardVC {
    //MARK: Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        if !isFromLoginFlow {
            /// Hide QuickPay
            quickPayCheckBoxHeightContrsaint.constant = 0
            stackAddToQuickPayLabel.isHidden = true
            stackQuickPayDescTextLabel.isHidden = true
            addToQuickPayBtn.setImage(nil, for: .normal)
            payBtn.setTitle("Add", for: .normal)
        }
        
        if !isUpdateCard {
            screenTitleLabel.text = "Add New Card"
            setTFColorsForIconTF(For: cardNumTF)
            setTFColors(For: expiryTF)
            setTFColors(For: cvcTF)
            setTFColors(For: zipCodeTF)
            setTFColors(For: cardHolderNameTF)
        } else {
            guard let selectedCard = selectedCardToUpdate else {
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
                return
            }
            screenTitleLabel.text = "Update Card"
            setTFColorsForIconTFForDisabled(For: cardNumTF)
            setTFColors(For: expiryTF)
            setTFColorsForDisabled(For: cvcTF)
            setTFColorsForDisabled(For: zipCodeTF)
            setTFColors(For: cardHolderNameTF)
            
            /// Put Card Details
            payBtn.setTitle("Update", for: .normal)
            zipCodeTF.text = "XXXXX"
            cvcTF.text = "***"
            cardNumTF.text = (selectedCard.cardLastFourNumber ?? "").trimmed().isEmpty ? ("XXXX XXXX XXXX XXXX") : ("XXXX XXXX XXXX \((selectedCard.cardLastFourNumber ?? "").trimmed())")
            zipCodeTF.isUserInteractionEnabled = false
            cvcTF.isUserInteractionEnabled = false
            cardNumTF.isUserInteractionEnabled = false
            cardHolderNameTF.text = selectedCard.name ?? ""
            expiryTF.text = "\(String(format: "%02d", selectedCard.cardExpMonth ?? 12))/\((selectedCard.cardExpYear ?? 2020) % 100)"
            
            if let cardTypeValue = selectedCard.cardPaymentName?.lowercased() {
                switch cardTypeValue {
                case "visa":
                    cardNumTF.iconImage = STPImageLibrary.brandImage(for: .visa)
                case "mastercard", "master card":
                    cardNumTF.iconImage = STPImageLibrary.brandImage(for: .masterCard)
                case "americanexpress", "american express", "amex":
                    cardNumTF.iconImage = STPImageLibrary.brandImage(for: .amex)
                case "dicover":
                    cardNumTF.iconImage = STPImageLibrary.brandImage(for: .discover)
                case "dinersclub", "diners club":
                    cardNumTF.iconImage = STPImageLibrary.brandImage(for: .dinersClub)
                case "jcb":
                    cardNumTF.iconImage = STPImageLibrary.brandImage(for: .JCB)
                case "unionpay", "union pay":
                    cardNumTF.iconImage = STPImageLibrary.brandImage(for: .unionPay)
                default:
                    cardNumTF.iconImage = STPImageLibrary.brandImage(for: .unknown)
                }
            }
        }
    }
    
    //MARK: View Will Appear
    override func viewWillAppear(_ animated: Bool) {
        screenTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.screenTapHandler(_:)))
        self.mainScrollVuew.addGestureRecognizer(screenTapGesture!)
        self.view.addGestureRecognizer(screenTapGesture!)
    }
    
    //MARK: View Will Disappear
    override func viewWillDisappear(_ animated: Bool) {
        if screenTapGesture != nil {
            self.mainScrollVuew.removeGestureRecognizer(screenTapGesture!)
            self.view.removeGestureRecognizer(screenTapGesture!)
        }
    }
    
    //MARK: Layout Subviews
    override func viewDidLayoutSubviews() {
        payBtn.roundWithRadious(Radius: payBtn.frame.height/2)
    }
}

//MARK:- Required Functions
extension AddNewCardVC: UITextFieldDelegate {
    //MARK: Screen Tap Handler
    @objc func screenTapHandler(_ gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //MARK: Add A Toolbar
    private func addKeyboardToolbar(ForTF textField: UITextField?) {
        if activeTF != nil {
            activeTF?.inputAccessoryView = nil
        }
        guard let textField = textField else {
            return
        }
        activeTF = textField
        let numberToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        numberToolbar.barStyle = .default
        numberToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(doneWithNumberPad))]
        numberToolbar.sizeToFit()
        textField.inputAccessoryView = numberToolbar
    }

    @objc func doneWithNumberPad() {
        //Done with number pad
        switch activeTF ?? cardNumTF {
        case cardNumTF: expiryTF.becomeFirstResponder()
        case expiryTF: cvcTF.becomeFirstResponder()
        case cvcTF: zipCodeTF.becomeFirstResponder()
        case zipCodeTF: cardHolderNameTF.becomeFirstResponder()
        default: self.view.endEditing(true)
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case cardNumTF, expiryTF, cvcTF, zipCodeTF: addKeyboardToolbar(ForTF: textField)
        default: activeTF = cardHolderNameTF
            addKeyboardToolbar(ForTF: nil)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch activeTF ?? cardNumTF {
        case cardNumTF: expiryTF.becomeFirstResponder()
        case expiryTF: cvcTF.becomeFirstResponder()
        case cvcTF: zipCodeTF.becomeFirstResponder()
        case zipCodeTF: cardHolderNameTF.becomeFirstResponder()
        case cardHolderNameTF: cardHolderNameTF.resignFirstResponder()
        default: self.view.endEditing(true)
        }
        return true
    }
    
    //MARK: TF Should Return
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == expiryTF {
            //Range.Lenth will greater than 0 if user is deleting text - Allow it to replce
            if range.length > 0 {
                if range.location == 3 {
                    var originalText = textField.text
                    originalText = originalText?.replacingOccurrences(of: "/", with: "")
                    textField.text = originalText
                }
                return true
            }
            
            //Dont allow empty strings
            if string == " " { return false }
            
            //Check for max length including the spacers we added
            if range.location > 4 {
                handleEnteredExpiryMonthTF(Text: textField.trimmed())
                cvcTF.becomeFirstResponder()
                return false
            }
            
            var originalText = textField.text
            let replacementText = string.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
            
            //Verify entered text is a numeric value
            let digits = NSCharacterSet.decimalDigits
            for char in replacementText.unicodeScalars {
                if !digits.contains(char) {
                    return false
                }
            }
            
            //Put / space after 2 digit
            if range.location == 2 {
                originalText = (originalText ?? "") + "/"
                textField.text = originalText
            }
        }
        
        return true
    }
    
    //MARK: Set UI Functions
    private func setTFColors(For tf: SkyFloatingLabelTextField) {
        tf.lineColor = yellowColor
        tf.titleColor = yellowColor
        tf.selectedTitleColor = yellowColor
        tf.titleLabel.numberOfLines = 0
    }
    
    
    //MARK: Set UI Functions
    private func setTFColorsForDisabled(For tf: SkyFloatingLabelTextField) {
        tf.lineColor = .lightGray
        tf.titleColor = .lightGray
        tf.textColor = .lightGray
        tf.selectedTitleColor = .lightGray
        tf.titleLabel.numberOfLines = 0
    }
    
    //MARK: Set UI Functions
    private func setTFColorsForIconTF(For tf: SkyFloatingLabelTextFieldWithIcon) {
        tf.lineColor = .gray
        tf.titleColor = yellowColor
        tf.selectedLineColor = yellowColor
        tf.iconType = .image
        tf.tintColor = yellowColor
        tf.selectedTitleColor = yellowColor
        tf.iconImage = STPImageLibrary.brandImage(for: .unknown)
        tf.titleLabel.numberOfLines = 0
    }
    
    //MARK: Set UI Functions
    private func setTFColorsForIconTFForDisabled(For tf: SkyFloatingLabelTextFieldWithIcon) {
        tf.lineColor = .lightGray
        tf.textColor = .lightGray
        tf.titleColor = .lightGray
        tf.selectedLineColor = .lightGray
        tf.iconType = .image
        tf.tintColor = .lightGray
        tf.selectedTitleColor = .lightGray
        tf.iconImage = STPImageLibrary.brandImage(for: .unknown)
        tf.titleLabel.numberOfLines = 0
    }
    
    //MARK: Handle Expiry Month TF
    private func handleEnteredExpiryMonthTF(Text tfText: String) {
        let sepratedC = tfText.components(separatedBy: "/")
        if checkExpiryMonth(Month: sepratedC[0]) == .valid {
            if sepratedC.count == 2 {
                if checkExpiry(Year: sepratedC[1], Month: sepratedC[0]) != .valid {
                    expiryTF.errorMessage =  "Invalid"
                } else {
                    expiryTF.errorMessage =  nil
                }
            }
            
        } else {
            expiryTF.errorMessage =  "Invalid"
        }
    }
    
    //MARK: Validat Card Update Detail
    private func validateCardForUpdation() {
        if expiryTF.trimmed().isEmpty {
            self.showAlert(AlertTitle: TAppName, AlertMessage: "Please enter card expiry details")
        } else if checkExpiryMonth(Month: expiryTF.trimmed().components(separatedBy: "/")[0]) != .valid {
            self.showAlert(AlertTitle: TAppName, AlertMessage: "Please enter valid card expiry month.")
        } else if checkExpiry(Year: expiryTF.trimmed().components(separatedBy: "/")[1], Month: expiryTF.trimmed().components(separatedBy: "/")[0]) != .valid {
            self.showAlert(AlertTitle: TAppName, AlertMessage: "Please enter valid card expiry year.")
        } else if cvcTF.trimmed().isEmpty {
            self.showAlert(AlertTitle: TAppName, AlertMessage: "Please enter CVC Code")
        } else if cardHolderNameTF.trimmed().isEmpty {
            self.showAlert(AlertTitle: TAppName, AlertMessage: "Please enter name on your card.")
        } else {
            /// Update Card Detail
            updateCardDetailsOnServer()
        }
    }
    
    //MARK: Make Final Payment
    private func validateCardDetails() {
        if cardNumTF.trimmed().isEmpty {
            self.showAlert(AlertTitle: TAppName, AlertMessage: "Please enter card number")
        } else if !(checkCardValidState(cardNumTF.trimmed().replacingOccurrences(of: "-", with: "", options: String.CompareOptions.literal, range: nil))) {
            self.showAlert(AlertTitle: TAppName, AlertMessage: "Please enter valid card number")
        } else if expiryTF.trimmed().isEmpty {
            self.showAlert(AlertTitle: TAppName, AlertMessage: "Please enter card expiry details")
        } else if checkExpiryMonth(Month: expiryTF.trimmed().components(separatedBy: "/")[0]) != .valid {
            self.showAlert(AlertTitle: TAppName, AlertMessage: "Please enter valid card expiry month.")
        } else if checkExpiry(Year: expiryTF.trimmed().components(separatedBy: "/")[1], Month: expiryTF.trimmed().components(separatedBy: "/")[0]) != .valid {
            self.showAlert(AlertTitle: TAppName, AlertMessage: "Please enter valid card expiry year.")
        } else if cvcTF.trimmed().isEmpty {
            self.showAlert(AlertTitle: TAppName, AlertMessage: "Please enter CVC Code")
        } else if cardHolderNameTF.trimmed().isEmpty {
            self.showAlert(AlertTitle: TAppName, AlertMessage: "Please enter name on your card.")
        } else {
            /// Generate Stripe Token
            generateStripeTokenForCard(Name: cardHolderNameTF.trimmed(), Month: expiryTF.trimmed().components(separatedBy: "/")[0], Year: expiryTF.trimmed().components(separatedBy: "/")[1], CVC: cvcTF.trimmed(), CardNum: cardNumTF.trimmed().replacingOccurrences(of: "-", with: "", options: .literal, range: nil))
        }
    }
    
    //MARK: Get Stripe Token For Entered Card Details
    private func generateStripeTokenForCard(Name name: String, Month month: String, Year year: String, CVC cvc: String, CardNum num: String) {
        Functions.shared.showActivityIndicator("Loading", view: self)
        let newCard = STPCardParams()
        newCard.name = name
        newCard.number = num
        newCard.expMonth = UInt(month)!
        newCard.expYear = UInt(year)!
        newCard.cvc = cvc
        
        STPAPIClient.shared().createToken(withCard: newCard) { (token, error) in
            Functions.shared.hideActivityIndicator()
            if error != nil {
                self.showAlert(AlertTitle: TAppName, AlertMessage: error!.localizedDescription)
            } else {
                /// We've no error.
                guard let token = token else {
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                        self.showAlert(AlertTitle: TAppName, AlertMessage: "Token not reterived from Stripe Server. Please try again.")
                    })
                    return
                }
                print("Stripe Token Created: \(token)")
                if self.isFromLoginFlow {
                    /// We're Paying Directly
                    self.payUserForSubscriptionWith(STToken: "\(token)")
                } else {
                    /// We Need to Add Card
                    self.addNewCardForUser(STToken: "\(token)")
                }
            }
        }
    }
}

//MARK:- API Validation
extension AddNewCardVC {
    //MARK: Pay User Amount
    private func payUserForSubscriptionWith(STToken stToken: String?) {
        Functions.shared.showActivityIndicator("Loading", view: self)
        WebService.wsMakeSubscriptionPaymentToServer(STPToken: stToken ?? "", SaveCard: addToQuickPay, SubscriptionID: selectedSubscription == nil ? ("") : ("\(selectedSubscription!.id ?? 0)"), CardID: nil, success: { (paymentSuccess, msg) in
            Functions.shared.hideActivityIndicator()
            if paymentSuccess {
                /// Navigate To Home Screen
                var isConttrollerFound: Bool = false
                for controller in (self.navigationController?.viewControllers ?? []) as Array {
                    if controller.isKind(of: BaseHomeVC.self) {
                        isConttrollerFound = true
                        self.navigationController?.setViewControllers([controller], animated: true)
                        break
                    }
                }
                
                if !isConttrollerFound {
                    let vc = homeStoryBoard.instantiateViewController(withIdentifier: "BaseHomeVC") as! BaseHomeVC
                    self.navigationController?.setViewControllers([vc], animated: true)
                }
            }
            
            DispatchQueue.main.async {
                if !(msg ?? "").trimmed().isEmpty {
                    self.showAlert(AlertTitle: TAppName, AlertMessage: msg!)
                }
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
    
    //MARK: Add New Card
    private func addNewCardForUser(STToken stToken: String?) {
        guard let stToken = stToken else {
            return
        }
        Functions.shared.showActivityIndicator("Loading", view: self)
        WebService.wsAddNewStripeCard(STPToken: stToken, success: { (addedSuccess, msg) in
            Functions.shared.hideActivityIndicator()
            if addedSuccess {
                self.navigationController?.popViewController(animated: true)
                self.delegate?.newCardAdded()
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                if !(msg ?? "").trimmed().isEmpty { self.showAlert(AlertTitle: TAppName, AlertMessage: msg!) }
            })
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
    
    //MARK: Update Card Details
    private func updateCardDetailsOnServer() {
        guard let selectedCard = selectedCardToUpdate else {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                self.showAlert(AlertTitle: TAppName, AlertMessage: "Please try selecting card again.")
            }
            return
        }
        Functions.shared.showActivityIndicator("Loading", view: self)
        WebService.wsUpdateAddedCard(CardID: selectedCard.cardID ?? "0", ExpMonth: expiryTF.trimmed().components(separatedBy: "/")[0], ExpYear: expiryTF.trimmed().components(separatedBy: "/")[1], Name: cardHolderNameTF.trimmed(), success: { (updated, msg) in
            Functions.shared.hideActivityIndicator()
            self.navigationController?.popViewController(animated: true)
            self.delegate?.newCardAdded()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                if !(msg ?? "").trimmed().isEmpty {
                    self.showAlert(AlertTitle: TAppName, AlertMessage: msg!)
                }
            })
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

//MARK:- TF Validations
extension AddNewCardVC {
    //MARK: Card Num Editing Changed
    @IBAction func cardNumTFEditingChanged(_ sender: UITextField) {
        let cardNumberStr : String = sender.text!.replacingOccurrences(of: "-", with: "", options: String.CompareOptions.literal, range: nil)
        validateCardNumber(CardNumber: cardNumberStr)
        cardNumTF.errorMessage = nil
        sender.text = cardNumberStr.inserting(separator: "-", every: 4)
        checkMaxLengthForCard(textField: sender , maxLength: cardNumberLength)
    }
    
    //MARK: Card Num Editing End
    @IBAction func cardNumTFEditingDidEnd(_ sender: UITextField) {
        let cardNumberStr : String = sender.text!.replacingOccurrences(of: "-", with: "", options: String.CompareOptions.literal, range: nil)
        !checkCardValidState(cardNumberStr) ? (cardNumTF.errorMessage = "Please enter valid card number.") : (cardNumTF.errorMessage = nil)
    }
    
    //MARK: Card Expiry Editing Changed
    @IBAction func expiryTFEditingChanged(_ sender: UITextField) {
        if sender.trimmed().count > 4  {
            cvcTF.becomeFirstResponder()
        }
    }
    
    //MARK: Card Expiry Editing End
    @IBAction func expiryTFEndEditing(_ sender: UITextField) {
        handleEnteredExpiryMonthTF(Text: sender.trimmed())
    }
    
    //MARK: Card CVC Editing Changed
    @IBAction func cvcTFEditingChanged(_ sender: UITextField) {
        if sender.trimmed().count == maxCVVCodeLength {
            zipCodeTF.becomeFirstResponder()
        }
        checkMaxLength(textField: sender , maxLength: maxCVVCodeLength)
    }
}

//MARK:- Button Actions
extension AddNewCardVC {
    //MARK: Quick Pay Action
    @IBAction func addToQuickPayAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        addToQuickPay = sender.isSelected
        sender.isSelected == true ? (sender.setImage(UIImage(named: "fillCheckSquare"), for: .normal)) : (sender.setImage(UIImage(named: "emptyCheckSquare"), for: .normal))
    }
    
    //MARK: Back Btn Action
    @IBAction func backBtnAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Pay Amount Action
    @IBAction func payAmountBtn(_ sender: UIButton) {
        if isUpdateCard {
            validateCardForUpdation()
        } else {
            validateCardDetails()
        }
    }
}

//MARK:- Stripe Validations
extension AddNewCardVC {
    //MARK: Validate Card Number
    private func validateCardNumber(CardNumber cardStr: String) {
        let cardType: STPCardBrand = self.checkTypeOfCard(cardStr)
        cardNumberLength = STPCardValidator.maxLength(for: cardType)
        if cardType == STPCardBrand.visa{
            maxCVVCodeLength = Int(STPCardValidator.maxCVCLength(for: STPCardBrand.visa))
            cardNumTF.iconImage = STPImageLibrary.brandImage(for: cardType)
        } else if cardType == STPCardBrand.amex {
            maxCVVCodeLength = Int(STPCardValidator.maxCVCLength(for: STPCardBrand.amex))
            cardNumTF.iconImage = STPImageLibrary.brandImage(for: cardType)
        } else if cardType == STPCardBrand.masterCard {
            maxCVVCodeLength = Int(STPCardValidator.maxCVCLength(for: STPCardBrand.masterCard))
            cardNumTF.iconImage = STPImageLibrary.brandImage(for: cardType)
        } else if cardType == STPCardBrand.discover {
            maxCVVCodeLength = Int(STPCardValidator.maxCVCLength(for: STPCardBrand.discover))
            cardNumTF.iconImage = STPImageLibrary.brandImage(for: cardType)
        } else if cardType == STPCardBrand.JCB {
            maxCVVCodeLength = Int(STPCardValidator.maxCVCLength(for: STPCardBrand.JCB))
            cardNumTF.iconImage = STPImageLibrary.brandImage(for: cardType)
        } else if cardType == STPCardBrand.dinersClub {
            maxCVVCodeLength = Int(STPCardValidator.maxCVCLength(for: STPCardBrand.dinersClub))
            cardNumTF.iconImage = STPImageLibrary.brandImage(for: cardType)
        } else if cardType == STPCardBrand.unionPay {
            maxCVVCodeLength = Int(STPCardValidator.maxCVCLength(for: STPCardBrand.unionPay))
            cardNumTF.iconImage = STPImageLibrary.brandImage(for: cardType)
        } else {
            cardNumberLength = 16
            maxCVVCodeLength = 3
            cardNumTF.iconImage = STPImageLibrary.brandImage(for: STPCardBrand.unknown)
        }
    }
    
    //MARK: Type of card
    /**
     This is used to type of Card
     - parameter cardNumber : Card Number which is required to be verified
     */
    private func checkTypeOfCard(_ cardNumber: String) -> STPCardBrand {
        return STPCardValidator.brand(forNumber: cardNumber)
    }
    
    //MARK: Set Card Number With "-" and Maximum length
    /**
     This is used to check maximum allowable digit a card can have
     - parameter textField : Card Number TF Reference
     - parameter maxLength : Maximum length a Card have
     */
    private func checkMaxLengthForCard(textField: UITextField!, maxLength: Int) {
        let cardNumberStr : String = textField.text!.replacingOccurrences(of: "-", with: "", options: String.CompareOptions.literal, range: nil)
        if (cardNumberStr.count > maxLength) {
            textField.deleteBackward()
        }
    }
    
    //MARK: Check is card Valid
    /**
     This is used to check is card Valid
     - parameter cardNumber : Card Number which is required to be verified
     */
    private func checkCardValidState(_ cardNumber: String) -> Bool {
        return STPCardValidator.validationState(forNumber: cardNumber, validatingCardBrand: false) == .valid ? (true) : (false)
    }
    
    //MARK: Validate Expiry Month
    private func checkExpiryMonth(Month month: String) -> STPCardValidationState {
        return STPCardValidator.validationState(forExpirationMonth: month)
    }
    
    //MARK: Validate Expiry Date Year
    private func checkExpiry(Year year: String, Month month: String) -> STPCardValidationState {
        return STPCardValidator.validationState(forExpirationYear: year, inMonth: month)
    }
    
    //MARK: Check Maximum Length in TF
    /**
     funcion check do TF have characters Limit required
     - parameter sender : UITextField Instance
     - parameter maxLength : Character Maximum Length
     */
    private func checkMaxLength(textField: UITextField!, maxLength: Int) {
        if textField.trimmed().count > maxLength {
            textField.deleteBackward()
        }
    }
}
