//
//  SubscriptionListVC.swift
//  ThrillingPicks
//
//  Created by iOSDev on 5/22/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit

class SubscriptionListVC: UIViewController {
    /// Subscription TV
    @IBOutlet weak var subscriptionTV: UITableView!
    /// Next Btn
    @IBOutlet weak var nextBtn: UIButton!
    
    /// Is From Signup Login Flow
    var isLoginFlow: Bool = false
    
    /// Last Index Selected
    fileprivate var lastIndexSelected: IndexPath? {
        didSet {
            self.subscriptionTV.reloadData()
        }
    }
    
    /// All Subscription Array
    fileprivate var allSubscriptions: [Subscription] = [] {
        didSet {
            self.subscriptionTV.reloadData()
        }
    }
    
    /// Hit Session API
    var needSessionAPI: Bool = false
    /// API Dispatch Group
    fileprivate var apiDispatchGroup = DispatchGroup()
    /// Logout User
    fileprivate var apiLogoutUser: Bool = false
}

//MARK:- View Life Cycles
extension SubscriptionListVC {
    //MARK: Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            Functions.shared.showActivityIndicator("Loading", view: self)
        }
        subscriptionTV.tableFooterView = UIView()
        if needSessionAPI {
            self.hitSessionLogin()
        }
        getAllSubscriptionFromServer()
        apiDispatchGroup.notify(queue: .main) {
            DispatchQueue.main.async {
                Functions.shared.hideActivityIndicator()
            }
            if self.apiLogoutUser {
                Functions.logoutUser(With: self.navigationController)
            }
        }
    }
    
    //MARK: Layout Subviews
    override func viewDidLayoutSubviews() {
        nextBtn.roundWithRadious(Radius: 6)
    }
}

//MARK:- Button Actions
extension SubscriptionListVC {
    //MARK: Back Btn Action
    @IBAction func backBtnAction(_ sender: Any) {
        if isLoginFlow {
            var isControllerFound: Bool = false
            for controller in self.navigationController!.viewControllers {
                if controller.isKind(of: NewGuestPassVC.self) {
                    isControllerFound = true
                    self.navigationController?.setViewControllers([controller], animated: true)
                    break
                }
            }
            if !isControllerFound {
                /// Controller isn't found
                let vc = NewGuestPassVC.instantiateFromStoryboard(storyboard: mainStoryBoard)
                self.navigationController?.setViewControllers([vc], animated: true)
            }
        } else {
            /// We're From Side Menu Table
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK: Next Btn Action
    @IBAction func nextBtnAction(_ sender: UIButton) {
        guard let selIndex = lastIndexSelected else {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                self.showAlert(AlertTitle: TAppName, AlertMessage: "Please select Subscription Plan.")
            }
            return
        }
        /// We've Selected Our Plan
        /// Check is user clicked Free Plan by it's slug
        let selectedPlan = allSubscriptions[selIndex.row]
        if selectedPlan.subscriptionSlug ?? "" == "byDeveloper" {
            /// User Selected Free Plan
            self.navigationController?.pushViewController(BaseHomeVC.instantiateFromStoryboard(storyboard: homeStoryBoard), animated: true)
        } else {
            /* ---> Commented To Make Common Flow For payment
            /// Paid Plan is Opted
            if !isLoginFlow {
                let vc = LoginMakePaymentVC.instantiateFromStoryboard(storyboard: paymentStoryBoard)
                vc.selectedSubscription = allSubscriptions[selIndex.row]
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                print("Paid Plan selected with Amount: \(selectedPlan.subscriptionPrice ?? "")")
                let vc = AddNewCardVC.instantiateFromStoryboard(storyboard: paymentStoryBoard)
                vc.selectedSubscription = allSubscriptions[selIndex.row]
                vc.isFromLoginFlow = self.isLoginFlow
                self.navigationController?.pushViewController(vc, animated: true)
            } */
            
            let vc = LoginMakePaymentVC.instantiateFromStoryboard(storyboard: paymentStoryBoard)
            vc.selectedSubscription = allSubscriptions[selIndex.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//MARK:- API Handler
extension SubscriptionListVC {
    /// Session Login API
    private func hitSessionLogin() {
        self.apiDispatchGroup.enter()
        WebService.wsSessionLoginUser(success: { (success) in
            self.apiDispatchGroup.leave()
        }) { (logoutBool, errorMsg) in
            self.apiLogoutUser = logoutBool
            self.apiDispatchGroup.leave()
        }
    }
    
    //MARK: Get All Subscription
    private func getAllSubscriptionFromServer() {
        apiDispatchGroup.enter()
        WebService.wsGetAllSubscriptions(success: { (success, allSub, msg) in
            self.apiDispatchGroup.leave()
            if !success {
                if !(msg ?? "").trimmed().isEmpty { self.showAlert(AlertTitle: TAppName, AlertMessage: msg!) }
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                    self.navigationController?.popViewController(animated: true)
                })
            } else {
                self.lastIndexSelected = nil
                self.allSubscriptions = allSub ?? []
                /// Check is This From Login Flow
                if self.isLoginFlow {
                    /// Add Guest Pass
                    self.allSubscriptions.append(Subscription(id: 0, subscriptionName: "Guest Pass", subscriptionPrice: "", subscriptionSlug: "byDeveloper", subscriptionValidity: 0, subscriptionDescription: "Try before you pay w/limited access. Less picks.", subscriptionStatus: nil, createdAt: nil, updatedAt: nil, subscriptionInterval: nil, subscriptionType: nil, discountedAmount: nil))
                }
            }
        }) { (logoutBool, errorMsg) in
            self.apiDispatchGroup.leave()
            self.apiLogoutUser = logoutBool
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                if !(errorMsg ?? "").trimmed().isEmpty { self.showAlert(AlertTitle: TAppName, AlertMessage: errorMsg!) }
            })
        }
    }
}

//MARK:- TableView Delegates
extension SubscriptionListVC: UITableViewDelegate, UITableViewDataSource, AutoRenewalCellprotocol {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let globalUser = Global.LoggedUser {
            return (globalUser.userSubscriptionType ?? "").trimmed().lowercased() == "autorenewal" ? (allSubscriptions.count+1) : (allSubscriptions.count)
        }
        return allSubscriptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (Global.LoggedUser?.userSubscriptionType ?? "").trimmed().lowercased() == "autorenewal" {
            /// It's Auto Renewal Case
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AutoRenewalRequestCancelTVCell", for: indexPath) as! AutoRenewalRequestCancelTVCell
                cell.configureCell(With: Functions.getDateFrom(DateString: (Global.LoggedUser!.userSubscriptionEndDate ?? "2019-06-14 09:16:58").trimmed(), With: .YYYYMMDDHHMMSS).getDateFormattedInString(of: .SMMDDYYYY))
                cell.delegate = self
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionTVCell", for: indexPath) as! SubscriptionTVCell
                let newIndex = IndexPath(row: indexPath.row - 1, section: indexPath.section)
                if lastIndexSelected != nil {
                    lastIndexSelected! == newIndex ? (cell.configureCell(With: allSubscriptions[newIndex.row], Selected: true)) : (cell.configureCell(With: allSubscriptions[newIndex.row], Selected: false))
                } else {
                    cell.configureCell(With: allSubscriptions[newIndex.row], Selected: false)
                }
                return cell
            }
        } else {
            /// Normal Case
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionTVCell", for: indexPath) as! SubscriptionTVCell
            if lastIndexSelected != nil {
                lastIndexSelected! == indexPath ? (cell.configureCell(With: allSubscriptions[indexPath.row], Selected: true)) : (cell.configureCell(With: allSubscriptions[indexPath.row], Selected: false))
            } else {
                cell.configureCell(With: allSubscriptions[indexPath.row], Selected: false)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (Global.LoggedUser?.userSubscriptionType ?? "").trimmed().lowercased() == "autorenewal" {
            if indexPath.row != 0 {
                let newIndex = IndexPath(row: indexPath.row - 1, section: indexPath.section)
                if lastIndexSelected != nil {
                    lastIndexSelected! == newIndex ? (lastIndexSelected = nil) : (lastIndexSelected = newIndex)
                } else { lastIndexSelected = newIndex }
            }
        } else {
            if lastIndexSelected != nil {
                lastIndexSelected! == indexPath ? (lastIndexSelected = nil) : (lastIndexSelected = indexPath)
            } else { lastIndexSelected = indexPath }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func requestToCancelSubscription() {
        self.navigationController?.pushViewController(CancelSubscriptionVC.instantiateFromStoryboard(storyboard: homeStoryBoard), animated: true)
    }
}
