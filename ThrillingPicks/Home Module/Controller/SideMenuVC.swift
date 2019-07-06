//
//  SideMenuVC.swift
//  ThrillingPicks
//
//  Created by iOSDev on 5/28/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit
import SDWebImage

protocol SideMenuOptionCellProtocol {
    func clickedSideMenu(SideOption option: SideMenuOption)
}

protocol SideMenuVCProtocol {
    func clickedSideMenuMainOption(Optiuon option: SideMenuOption)
    func clickedMyAccountOption(Option option: MyAccountOptions)
}

class SideMenuVC: UIViewController {

    @IBOutlet weak var mainScrollView: UIScrollView!
   // @IBOutlet weak var loggedUserImageView: UIImageView!
    @IBOutlet weak var loggedUserNameLabel: UILabel!
    //@IBOutlet weak var appNameLabel: UILabel!
    
    @IBOutlet weak var recentWinsTV: UITableView!
    @IBOutlet weak var sideMenTV: UITableView!
    
    @IBOutlet weak var recentWinsTVHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sideMenuOptionTVHeightConstraint: NSLayoutConstraint!
    fileprivate var sideMenuOption: [SideMenuOption] = SideMenuOption.allCases
    fileprivate var myAccountOptions: [MyAccountOptions] = MyAccountOptions.allCases
    fileprivate var expandMyAccount: Bool = false
    var delegate: SideMenuVCProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenTV.sectionHeaderHeight = UITableView.automaticDimension
        sideMenTV.estimatedSectionHeaderHeight = 25
        recentWinsTV.reloadData()
        sideMenTV.reloadData()
        // appNameLabel.text = "Thrilling Picks"
        //appNameLabel.font = appNameLabel.font.italic
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Called")
    }
    
    override func viewDidLayoutSubviews() {
        //loggedUserImageView.roundWithRadious(Radius: loggedUserImageView.frame.height/2)
        sideMenuOptionTVHeightConstraint.constant = sideMenTV.contentSize.height
        recentWinsTVHeightConstraint.constant = recentWinsTV.contentSize.height
    }
    
    func refreshView() {
        //loggedUserImageView.sd_setImage(with: URL(string: Global.LoggedUser?.userProfileImageURL ?? ""), placeholderImage: UIImage(named: "user"), options: .continueInBackground, context: nil)
        loggedUserNameLabel.text = Global.LoggedUser?.name ?? ""
        //loggedUserEmailLabel.text = Global.LoggedUser?.email ?? ""
        recentWinsTV.reloadData()
        sideMenTV.reloadData()
        self.viewDidLayoutSubviews()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.viewDidLayoutSubviews()
        }
    }
}

//MARK:- TableView Delegates
extension SideMenuVC: UITableViewDelegate, UITableViewDataSource, SideMenuOptionCellProtocol {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableView == recentWinsTV ? (1) : (sideMenuOption.count)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == recentWinsTV {
            return Global.recentPicksArray.count
        } else {
            if sideMenuOption[section] != .MyAccount {
                return 0
            } else {
                return expandMyAccount == true ? (myAccountOptions.count) : (0)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == sideMenTV {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuOptionTableCell") as! SideMenuOptionTableCell
            cell.configureCell(Setting: sideMenuOption[section], Expanded: self.expandMyAccount)
            let headerTapAction: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.headerCellTapped(_:)))
            cell.contentView.addGestureRecognizer(headerTapAction)
            cell.contentView.tag = section
            cell.delegate = self
            return cell.contentView
        } else { return nil }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == recentWinsTV {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecentWinsTableCell", for: indexPath) as! RecentWinsTableCell
            cell.configureCell(RecentPick: Global.recentPicksArray[indexPath.row])
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyAccountOptionTableCell", for: indexPath) as! MyAccountOptionTableCell
            cell.configureCell(AccountOption: myAccountOptions[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == sideMenTV {
            if sideMenuOption[indexPath.section] == .MyAccount {
                self.delegate?.clickedMyAccountOption(Option: myAccountOptions[indexPath.row])
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    @objc
    private func headerCellTapped(_ sender: UITapGestureRecognizer) {
        if let index = sender.view?.tag {
            if sideMenuOption[index] == .MyAccount {
                self.expandMyAccount = !self.expandMyAccount
                self.sideMenTV.reloadSections(IndexSet(integer: index), with: .automatic)
            } else {
                self.delegate?.clickedSideMenuMainOption(Optiuon: sideMenuOption[index])
            }
        }
    }
    
    func clickedSideMenu(SideOption option: SideMenuOption) {
        print(option.rawValue)
    }
}
