//
//  SubscriptionTVTableCell.swift
//  ThrillingPicks
//
//  Created by iOSDev on 5/23/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit

protocol AutoRenewalCellprotocol {
    func requestToCancelSubscription()
}

//MARK: Auto Renewal Cell
class AutoRenewalRequestCancelTVCell: UITableViewCell {
    /// Subscription Detai Label
    @IBOutlet weak var subscriptionDateInfoLabel: UILabel!
    /// Cancel Btn
    @IBOutlet weak var cancelSubBt: UIButton!
    
    /// Delegate
    var delegate: AutoRenewalCellprotocol?
    
    //MARK: Configure Cell
    func configureCell(With date: String) {
        subscriptionDateInfoLabel.text = "Subscription Auto-Renews on \(date)"
        let attributedString = NSMutableAttributedString()
        attributedString.append(NSAttributedString(string: "CANCEL AUTO-RENEWAL", attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]))
        cancelSubBt.setAttributedTitle(attributedString, for: .normal)
    }
    
    //MARK: Cancel Subscription Request
    @IBAction func cancelSubscriptionBtnAction(_ sender: Any) {
        self.delegate?.requestToCancelSubscription()
    }
    
}

//MARK:- Subscription Table Cell
class SubscriptionTVCell: UITableViewCell {
    /// Base View - To Add Border
    @IBOutlet weak var baseView: UIView!
    /// Subscription Name Label
    @IBOutlet weak var subTypeLabel: UILabel!
    /// Subscription Desc Label
    @IBOutlet weak var subDescLabel: UILabel!
    /// Subscription Amount Label
    @IBOutlet weak var subAmountlabel: UILabel!
    
    //MARK: Awake From Nib
    override func awakeFromNib() {
        baseView.roundWithRadious(Radius: 6)
        baseView.addBorderToView(Radius: 2, Color: buttonBorderPurpleColor)
    }
    
    //MARK: Configure Cell
    func configureCell(With subs: Subscription, Selected isSelected: Bool) {
        subTypeLabel.text = subs.subscriptionName ?? ""
        
        if subs.subscriptionSlug ?? "" == "byDeveloper" {
            subDescLabel.text = subs.subscriptionDescription ?? ""
        } else {
            let renewvalue: String = subs.subscriptionType ?? "" == "charge_automatically" ? ("Auto Renew") : ("One Time Payment")
            subDescLabel.text = "\(subs.subscriptionValidity ?? 1) \(subs.subscriptionInterval ?? "") \n\(renewvalue)"
        }
        
        !(subs.subscriptionPrice ?? "").trimmed().isEmpty ? (subAmountlabel.text = "$\(subs.subscriptionPrice ?? "")") : (subAmountlabel.text = nil)
        isSelected == true ? (baseView.backgroundColor = .black) : (baseView.backgroundColor = buttonGrayBGColor)
    }
}
