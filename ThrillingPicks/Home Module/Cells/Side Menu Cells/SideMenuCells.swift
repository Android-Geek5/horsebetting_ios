//
//  SideMenuCells.swift
//  ThrillingPicks
//
//  Created by iOSDev on 6/3/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit

enum SideMenuOption: String, CaseIterable {
    case inviteFriends = "Invite Friends"
    case cards = "Cards"
    case MyAccount = "My Account"
}

enum MyAccountOptions: String, CaseIterable {
    case profileSetting = "Profile Settings"
    case subPlan = "Subscription Plan"
    case changePassword = "Change Password"
    case logout = "Logout"
}

class RecentWinsTableCell: UITableViewCell {
    /// Race Name Label
    @IBOutlet weak var raceNameLabel: UILabel!
    /// Race Status Label
    @IBOutlet weak var raceStatusLabel: UILabel!
    
    //MARK: Configure Cell
    func configureCell(RecentPick pick: RecentPick) {
        raceNameLabel.text = pick.trackName ?? ""
        raceStatusLabel.text = "\(pick.trackRaceBetType ?? "") $\(pick.trackRacePaidAmount ?? "")"
    }
}

class SideMenuOptionTableCell: UITableViewCell {
    /// Menu Title Label
    @IBOutlet weak var menuTitleLabel: UILabel!
    /// Menu Image View
    @IBOutlet weak var menuImageView: UIImageView!
    /// Drop ImageView
    @IBOutlet weak var dropImageView: UIImageView!
    /// Drop ImageView Heght Constraint
    @IBOutlet weak var dropImageViewHeightConstraint: NSLayoutConstraint!
    
    /// Delegate
    var delegate: SideMenuOptionCellProtocol?
    /// Selected Option
    fileprivate var selectedOption: SideMenuOption = .MyAccount
    
    //MARK: Configure Cell
    func configureCell(Setting option: SideMenuOption, Expanded expanded: Bool) {
        dropImageViewHeightConstraint.constant = 0
        dropImageView.image = nil
        menuTitleLabel.text = option.rawValue
        selectedOption = option
        switch option {
            case .inviteFriends:
                (Global.LoggedUser!.referedByAmount ?? "").trimmed().isEmpty ? (menuTitleLabel.text = option.rawValue) : (menuTitleLabel.text = "\(option.rawValue), Get \(Global.LoggedUser!.referedByAmount ?? "")%")
                
                menuImageView.image = UIImage(named: "inviteFriends")
            case .cards: menuImageView.image = UIImage(named: "cards")
            default:
                menuImageView.image = UIImage(named: "myAccount")
                dropImageViewHeightConstraint.constant = 15
                expanded == true ? (dropImageView.image = UIImage(named: "dropDown")) : (dropImageView.image = UIImage(named: "openMenu"))
        }
    }
    
    @IBAction func headerBtnAction(_ sender: UIButton) {
        self.delegate?.clickedSideMenu(SideOption: selectedOption)
    }
}

class MyAccountOptionTableCell: UITableViewCell {
    /// Account Title Label
    @IBOutlet weak var accountTitleLabel: UILabel!
    
    //MARK: Configure Cell
    func configureCell(AccountOption option: MyAccountOptions) {
        accountTitleLabel.text = option.rawValue
    }
}
