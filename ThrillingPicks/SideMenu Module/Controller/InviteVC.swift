//
//  InviteVC.swift
//  ThrillingPicks
//
//  Created by iOSDev on 6/13/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit

// MARK: - DataClass
struct InviteData: Codable {
    let invitedAccepted, whoSubscribed: Int?
    let referedByAmount, referedToAmount: String?
    
    enum CodingKeys: String, CodingKey {
        case invitedAccepted, whoSubscribed
        case referedByAmount = "refered_by_amount"
        case referedToAmount = "refered_to_amount"
    }
}

class InviteVC: UIViewController {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var inviteFrndBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var acceptedInvitationLabel: UILabel!
    @IBOutlet weak var subscrivedValueLabel: UILabel!
    
    fileprivate var screenInviteData: InviteData? {
        didSet {
            self.updateScreenData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getInviteDetails()
    }
    
    override func viewDidLayoutSubviews() {
        inviteFrndBtn.roundWithRadious(Radius: inviteFrndBtn.frame.height/2)
        backBtn.roundWithRadious(Radius: backBtn.frame.height/2)
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func inviteFriendsBtnAction(_ sender: Any) {
        guard let screeData = screenInviteData else {
            return
        }
        let startText = "Need amazing betting tips?\nUse my code \(Global.LoggedUser?.promocode ?? "")\nto save yourself \(screeData.referedToAmount ?? "") % off signup for \(TAppName)"
        let myWebsite = URL(string:"https://www.google.com")
        let activityViewController = UIActivityViewController(activityItems: [startText , myWebsite!], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
}

extension InviteVC {
    func updateScreenData() {
        guard let screeData = screenInviteData else {
            return
        }
        
        descriptionLabel.text = "Give your friends \(screeData.referedToAmount ?? "")% off with your promocode. You'll get \(screeData.referedByAmount ?? "")% in credits, after they subscribe to a monthly plan. \n\nYour invite code is \(Global.LoggedUser?.promocode ?? "")"
        acceptedInvitationLabel.text = String(screeData.invitedAccepted ?? 0)
        subscrivedValueLabel.text = String(screeData.whoSubscribed ?? 0)
    }
}


extension InviteVC {
    //MARK: Get Invite Details
    private func getInviteDetails() {
        Functions.shared.showActivityIndicator("Loading", view: self)
        WebService.wsGetInviteScreenDetails(success: { (invData) in
            Functions.shared.hideActivityIndicator()
            self.screenInviteData = invData
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
