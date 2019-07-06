//
//  LoginMakePaymentVC.swift
//  ThrillingPicks
//
//  Created by iOSDev on 6/11/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit

class SignupDiscount: NSObject {
    var actual_price: String = ""
    var percent_off: String = ""
    var price: String = ""
    var isSignupDiscountApplicable: Bool = false
    
    override init() { }
    
    init(WithJSON jsonDict: [String:Any]) {
        actual_price = Functions.getStringValueForNum(jsonDict["actual_price"] as Any)
        percent_off = Functions.getStringValueForNum(jsonDict["percent_off"] as Any)
        price = Functions.getStringValueForNum(jsonDict["price"] as Any)
        price.trimmed().isEmpty ? (isSignupDiscountApplicable = false) : (isSignupDiscountApplicable = true)
    }
}

class LoginMakePaymentVC: UIViewController {

    /// Add New Card Btn
    @IBOutlet weak var addNewCardBtn: UIButton!
    /// Card Listing TV
    @IBOutlet weak var cardListingTV: UITableView!
    /// Select Code TF
    @IBOutlet weak var selectCodeTF: UITextField!
    /// Yes ImageView
    @IBOutlet weak var yesImageView: UIImageView!
    /// No ImageView
    @IBOutlet weak var noImageView: UIImageView!
    /// Yes Image BaseView
    @IBOutlet weak var yesImageBaseView: UIView!
    /// No Image BaseView
    @IBOutlet weak var noImageBaseView: UIView!
    /// PromoCode TF BaseView
    @IBOutlet weak var promocodeTFBaseView: UIView!
    /// Paying Amount Label
    @IBOutlet weak var payingAmountTextLabel: UILabel!
    /// Pay Amount Btn
    @IBOutlet weak var payAmountBtn: UIButton!
    
    
    /// All Cards Added
    fileprivate var addedCards: [CreditCard] = [] {
        didSet {
            self.cardListingTV.reloadData()
            
        }
    }
    
    /// Is Promocode Available
    fileprivate var isPromocodeAvaialble: Bool = false {
        didSet {
            if self.isPromocodeAvaialble {
                /// Available
                yesImageView.image = UIImage(named: "tickedGreenCircle")
                noImageView.image = nil
                noImageBaseView.backgroundColor = lightGrayBaseColor
                yesImageBaseView.backgroundColor = .white
                promocodeTFBaseView.isHidden = false
            } else {
                /// Not Available
                yesImageView.image = nil
                noImageView.image = UIImage(named: "tickedGreenCircle")
                yesImageBaseView.backgroundColor = lightGrayBaseColor
                noImageBaseView.backgroundColor = .white
                promocodeTFBaseView.isHidden = true
                self.selectedCouponCode = nil
                
            }
        }
    }
    
    /// Picker View
    fileprivate var myPickerView = UIPickerView()
    
    /// Picker Code Array
    fileprivate var codeStringArray: [String] = []
    
    /// Coupon Code Array
    fileprivate var couponCodesArray: [CouponCode] = Global.LoggedUser?.codesArray ?? [] {
        didSet {
            myPickerView.reloadAllComponents()
        }
    }
    
    /// Selected Coupon Code
    fileprivate var selectedCouponCode: CouponCode? {
        didSet {
            selectCodeTF.text = self.selectedCouponCode?.inviteCode ?? ""
        }
    }
    
    /// Selected Subscription
    var selectedSubscription: Subscription? {
        didSet {
            
        }
    }
    
    /// Card Selected
    fileprivate var creditCardSelected: CreditCard? {
        didSet {
            self.cardListingTV.reloadData()
        }
    }
    
    /// Dispatch Group
    fileprivate var apiHitGroup = DispatchGroup()
    /// Logout User
    fileprivate var logoutUserFromAPI: Bool = false
    /// Applied Signup Discount
    fileprivate var appliedSignupDiscount: SignupDiscount? {
        didSet {
            self.updateSignupDiscountAmount()
        }
    }
}

//MARK:- View Life Cycles
extension LoginMakePaymentVC {
    //MARK: Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        cardListingTV.tableFooterView = UIView()
        DispatchQueue.main.async {
            Functions.shared.showActivityIndicator("Loading", view: self)
        }
        getAllAddedCardsFromServer()
        getSignupDiscount()
        apiHitGroup.notify(queue: .main) {
            Functions.shared.hideActivityIndicator()
            if self.logoutUserFromAPI {
                Functions.logoutUser(With: self.navigationController)
            }
        }
        let price = (selectedSubscription?.subscriptionPrice ?? "").trimmed()
        selectedSubscription?.discountedAmount = price
        selectCodeTF.setRightAccessoryView(ImageName: UIImage(named: "dropDown")!.imageWithColor(color1: .darkGray))
        selectCodeTF.inputView = myPickerView
        let newCoupon = CouponCode(id: nil, referedByUserID: nil, referedToUserID: nil, inviteCode: "Select Code", discount: nil, referedByAmount: nil, referedToAmount: nil, userCodeStatus: nil, createdAt: nil, updatedAt: nil)
        couponCodesArray.isEmpty ? (couponCodesArray.append(newCoupon)) : (couponCodesArray.insert(newCoupon, at: 0))
        selectedCouponCode = newCoupon
        addKeyboardToolbar(ForTF: selectCodeTF)
        myPickerView.delegate = self
        myPickerView.dataSource = self
        isPromocodeAvaialble = true
    }
    
    //MARK: Layout Subviews
    override func viewDidLayoutSubviews() {
        payAmountBtn.roundWithRadious(Radius: payAmountBtn.frame.height/2)
        yesImageBaseView.roundWithRadious(Radius: yesImageBaseView.frame.height/2)
        noImageBaseView.roundWithRadious(Radius: noImageBaseView.frame.height/2)
        addNewCardBtn.roundWithRadious(Radius: addNewCardBtn.frame.height/2)
    }
}

//MARK:- Required Functions
extension LoginMakePaymentVC: AddNewcardVCProtocol {
    //MARK: Update Signup Discount Amount
    private func updateSignupDiscountAmount() {
        /// Check Do we have any Signup Discount
        guard let signupDisc = self.appliedSignupDiscount else {
            return
        }
        if signupDisc.isSignupDiscountApplicable {
            /// Discount is Applicable
            signupDisc.percent_off.trimmed().isEmpty ? (payingAmountTextLabel.text = "To Pay: $\(signupDisc.price)") : (payingAmountTextLabel.text = "To Pay: $\(signupDisc.price)\nApplied Discount: \(signupDisc.percent_off)%")
        } else {
            /// Discount isn't applicable
            payingAmountTextLabel.text = "To Pay: $\(selectedSubscription?.discountedAmount ?? "")"
        }
    }
    
    //MARK: Add A Toolbar
    private func addKeyboardToolbar(ForTF textField: UITextField?) {
        guard let textField = textField else {
            return
        }
        let numberToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        numberToolbar.barStyle = .default
        numberToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(toolbarDoneBtnAction))
        ]
        numberToolbar.sizeToFit()
        textField.inputAccessoryView = numberToolbar
    }
    
    //MARK: New Card Added
    func newCardAdded() {
        Functions.shared.showActivityIndicator("Loading", view: self)
        getAllAddedCardsFromServer()
        apiHitGroup.notify(queue: .main) {
            Functions.shared.hideActivityIndicator()
            if self.logoutUserFromAPI {
                Functions.logoutUser(With: self.navigationController)
            }
        }
    }
    
    //MARK: ToolBar Next Btn Action
    @objc
    func toolbarDoneBtnAction() {
        self.view.endEditing(true)
        /// Verify Coupon Code
        guard let selectedSub = selectedSubscription else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.showAlert(AlertTitle: TAppName, AlertMessage: "Please select subscription plan first")
            }
            return
        }
        guard let selectedCoupon = selectedCouponCode else {
            return
        }
        if selectedCoupon.id == nil || selectedCoupon.inviteCode == "Select Code" {
            if let disc = appliedSignupDiscount?.isSignupDiscountApplicable {
                if disc {
                    selectedSubscription?.discountedAmount = appliedSignupDiscount!.price
                    payingAmountTextLabel.text = "To Pay: $\(selectedSubscription?.discountedAmount ?? "")\nApplied Discount: \(appliedSignupDiscount!.percent_off)%"
                    return
                }
            }
            selectedSubscription?.discountedAmount = (selectedSub.subscriptionPrice ?? "").trimmed()
            payingAmountTextLabel.text = "To Pay: $\(selectedSubscription?.discountedAmount ?? "")"
            return
            
        }
        verifyCoupoCode(CouponID: String(selectedCoupon.id ?? 0), SubID: String(selectedSub.id ?? 0), SelectedCoupon: selectedCoupon)
    }
}

//MARK:- TableView Delegates
extension LoginMakePaymentVC: UITableViewDelegate, UITableViewDataSource {
    //MARK: Number of Rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addedCards.count
    }
    
    //MARK: Cell For Row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreditCardTVCell", for: indexPath) as! CreditCardTVCell
        cell.congfigureCell(CreditCard: addedCards[indexPath.row])
        return cell
    }
    
    //MARK: Did Select Row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let index = self.addedCards.firstIndex(where: { $0.cardID ?? "" == self.creditCardSelected?.cardID ?? "" }) {
            var newCard = self.addedCards[index]
            newCard.isSelected = false
            self.addedCards[index] = newCard
        }
        var newCard = self.addedCards[indexPath.row]
        newCard.isSelected = true
        self.creditCardSelected = newCard
        self.addedCards[indexPath.row] = newCard
    }
    
    //MARK: Height For Row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//MARK:- API Handler
extension LoginMakePaymentVC {
    //MARK: Get Signup Dicsount
    private func getSignupDiscount() {
        guard let selectedSub = self.selectedSubscription else {
            return
        }
        //self.apiHitGroup.enter()
        WebService.wsGetSignupCodeDiscountedAmount(SubscriptionID: String(selectedSub.id ?? 0), success: { (discountApplied) in
            self.appliedSignupDiscount = discountApplied
            //self.apiHitGroup.leave()
        }) { (logoutBool, errorMsg) in
            self.appliedSignupDiscount = nil
            self.logoutUserFromAPI = logoutBool
            //self.apiHitGroup.leave()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                if !(errorMsg ?? "").trimmed().isEmpty { self.showAlert(AlertTitle: TAppName, AlertMessage: errorMsg!) }
            })
            
        }
    }
    
    //MARK: Get All Cards
    private func getAllAddedCardsFromServer() {
        self.apiHitGroup.enter()
        WebService.wsGetAllCardsAdded(success: { (allcards) in
            self.addedCards = allcards
            if !self.addedCards.isEmpty {
                /// Make First Card Selected by Default
                if self.creditCardSelected == nil {
                    var newCard = self.addedCards[0]
                    newCard.isSelected = true
                    self.creditCardSelected = newCard
                    self.addedCards[0] = newCard
                } else {
                    if let index = self.addedCards.firstIndex(where: { $0.cardID ?? "" == self.creditCardSelected?.cardID ?? "" }) {
                        var newCard = self.addedCards[index]
                        newCard.isSelected = true
                        self.creditCardSelected = newCard
                        self.addedCards[index] = newCard
                    }
                }
            }
            self.apiHitGroup.leave()
        }) { (logoutBool, errorMsg) in
            self.logoutUserFromAPI = logoutBool
            self.apiHitGroup.leave()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                if !(errorMsg ?? "").trimmed().isEmpty { self.showAlert(AlertTitle: TAppName, AlertMessage: errorMsg!) }
            })
            
        }
    }
    
    //MARK: Verify Coupon Code
    private func verifyCoupoCode(CouponID codeID: String, SubID subID: String, SelectedCoupon coupon: CouponCode) {
        Functions.shared.showActivityIndicator("Loading", view: self)
        WebService.wsVerifyAppCouponCode(CouponID: codeID, SubscriptionID: subID, success: { (success, msg, amount) in
            Functions.shared.hideActivityIndicator()
            if !success {
                if !(msg ?? "").trimmed().isEmpty { self.showAlert(AlertTitle: TAppName, AlertMessage: msg!) }
            } else {
                if !amount.trimmed().isEmpty {
                    self.selectedSubscription?.discountedAmount = amount.trimmed()
                } else {
                    let price = (self.selectedSubscription?.subscriptionPrice ?? "").trimmed()
                    self.selectedSubscription?.discountedAmount = price
                }
                (coupon.referedByAmount ?? "").trimmed().isEmpty ? (self.payingAmountTextLabel.text = "To Pay: $\(self.selectedSubscription?.discountedAmount ?? "")") : (self.payingAmountTextLabel.text = "To Pay: $\(self.selectedSubscription?.discountedAmount ?? "")\nApplied Discount: \(coupon.referedByAmount ?? "")%")
                
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
extension LoginMakePaymentVC {
    //MARK: Add New Card Action
    @IBAction func addNewCardAction(_ sender: Any) {
        let vc = AddNewCardVC.instantiateFromStoryboard(storyboard: paymentStoryBoard)
        vc.isFromLoginFlow = false
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: Back Btn Action
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Have Procode Button Action
    @IBAction func havePromocodeBtnAction(_ sender: UIButton) {
        sender.tag == 1 ? (isPromocodeAvaialble = true) : (isPromocodeAvaialble = false)
        if !isPromocodeAvaialble {
            self.view.endEditing(true)
            let oldPrice = self.selectedSubscription?.subscriptionPrice ?? ""
            self.selectedSubscription?.discountedAmount = oldPrice
            if let disc = self.appliedSignupDiscount?.isSignupDiscountApplicable {
                if disc {
                    self.selectedSubscription?.discountedAmount = self.appliedSignupDiscount!.price
                    self.payingAmountTextLabel.text = "To Pay: $\(self.selectedSubscription?.discountedAmount ?? "")\nApplied Discount: \(self.appliedSignupDiscount!.percent_off)%"
                    return
                }
            }
            self.selectedCouponCode = couponCodesArray[0]
            self.selectedCouponCode?.referedByAmount = (self.selectedSubscription?.subscriptionPrice ?? "").trimmed()
            self.payingAmountTextLabel.text = "To Pay: $\(self.selectedSubscription?.discountedAmount ?? "")"
            
        }
    }
    
    //MARK: Pay Required Amount
    @IBAction func payRequiredAmountBtnAction(_ sender: UIButton) {
        guard let selectedCreditCard = creditCardSelected else {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                self.showAlert(AlertTitle: TAppName, AlertMessage: "Choose card")
            })
            return
        }
        
        guard let selectedSub = selectedSubscription else {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                self.showAlert(AlertTitle: TAppName, AlertMessage: "Choose Subscription")
            })
            return
        }
        
        /// We've our selected card
        Functions.shared.showActivityIndicator("Loading", view: self)
        var cID: String = ""
        selectedCouponCode?.id != nil ? (cID = String(selectedCouponCode!.id!)) : (cID = "")
        WebService.wsMakeSubscriptionPaymentToServerWithAddedCard(CardID: selectedCreditCard.cardID ?? "", SubscriptionID: String(selectedSub.id ?? 0), CouponID: cID, success: { (success, msg) in
            if success {
                for controller in (self.navigationController?.viewControllers ?? []) as Array {
                    if controller.isKind(of: SignInVC.self) {
                        let newVC = BaseHomeVC.instantiateFromStoryboard(storyboard: homeStoryBoard)
                        self.navigationController?.setViewControllers([newVC, controller], animated: false)
                        break
                    } else {
                        let vc = homeStoryBoard.instantiateViewController(withIdentifier: "BaseHomeVC") as! BaseHomeVC
                        self.navigationController?.setViewControllers([vc], animated: true)
                        break
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
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
}

//MARK:- TextField Delegates
extension LoginMakePaymentVC: UITextFieldDelegate {
    //MARK: Begin Editing
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == selectCodeTF {
            if let selectedCoupon = selectedCouponCode {
                if selectedCoupon.id != nil {
                    /// It's Other ID
                    if let index = couponCodesArray.firstIndex(where: { $0.id ?? 0 == selectedCoupon.id ?? 0 }) {
                        myPickerView.selectRow(index, inComponent: 0, animated: false)
                    }
                } else {
                    myPickerView.selectRow(0, inComponent: 0, animated: false)
                }
            }
            myPickerView.reloadAllComponents()
        }
        return true
    }
}

//MARK:- PickerView Delegates
extension LoginMakePaymentVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return couponCodesArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if couponCodesArray[row].id == nil || couponCodesArray[row].inviteCode == "Select Code" {
            return (couponCodesArray[row].inviteCode ?? "").trimmed()
        } else {
            return (couponCodesArray[row].referedByAmount ?? "").trimmed().isEmpty ? ("\(couponCodesArray[row].inviteCode ?? "")") : ("\(couponCodesArray[row].inviteCode ?? "")(\(couponCodesArray[row].referedByAmount ?? "")%)")
        }        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCouponCode = couponCodesArray[row]
    }
}
