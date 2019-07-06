//
//  CancelSubscriptionVC.swift
//  ThrillingPicks
//
//  Created by iOSDev on 6/14/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit

class CancelSubscriptionVC: UIViewController {
    
    /// Subscription Detail Label
    @IBOutlet weak var subscriptionDetailLabel: UILabel!
    /// Cancel Renewal Req Btn
    @IBOutlet weak var cancelRenewalBtn: UIButton!
    
    //MARK: Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        subscriptionDetailLabel.text = "Your subscription auto-renews\non \(Functions.getDateFrom(DateString: (Global.LoggedUser!.userSubscriptionEndDate ?? "2019-06-14 09:16:58").trimmed(), With: .YYYYMMDDHHMMSS).getDateFormattedInString(of: .SMMDDYYYY))\nfor $\(Global.LoggedUser!.subscriptionPrice ?? "")"
    }
    
    override func viewDidLayoutSubviews() {
        cancelRenewalBtn.roundWithRadious(Radius: cancelRenewalBtn.frame.height/7)
    }

    //MARK: Cancel Request Action
    @IBAction func cancelRequestAction(_ sender: Any) {
        Functions.shared.showActivityIndicator("Loading", view: self)
        WebService.wsCancelAutoRenewalSubscriptionRequest(success: { (success, msg) in
            Functions.shared.hideActivityIndicator()
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
    
    //MARK: Back Btn Action
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
