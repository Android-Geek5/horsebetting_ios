//
//  NewGuestPassVC.swift
//  ThrillingPicks
//
//  Created by iOSDev on 7/6/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit

protocol MainScreenTableCellProtocol {
    func guestPassClicked()
    func loginScreenClicked()
}

class MainScreenTableCell: UITableViewCell {
    
    @IBOutlet weak var loginBaseView: UIView!
    @IBOutlet weak var appDescriptionLabel: UILabel!
    @IBOutlet weak var guestPassBaseView: UIView!
    
    var delegate: MainScreenTableCellProtocol?
    
    override func awakeFromNib() {
        guestPassBaseView.roundWithRadious(Radius: 6)
        guestPassBaseView.addBorderToView(Radius: 2, Color: buttonBorderPurpleColor)
        loginBaseView.roundWithRadious(Radius: 6)
        loginBaseView.addBorderToView(Radius: 2, Color: buttonBorderPurpleColor)
    }
    
    func configureCell(DescText desc: String) {
        appDescriptionLabel.text = desc
    }
    
    @IBAction func guestPassAction(_ sender: UIButton) {
        self.delegate?.guestPassClicked()
    }
    @IBAction func loginUserBtnAction(_ sender: Any) {
        self.delegate?.loginScreenClicked()
    }
}

class NewGuestPassVC: UIViewController {

    @IBOutlet weak var table_View: UITableView!
    
    /// All Winnings
    fileprivate var allWinnings: [Winning] = [] {
        didSet {
            self.viewDidLayoutSubviews()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        table_View.tableFooterView = UIView()
        table_View.register(UINib(nibName: "WinningTableCell", bundle: nil), forCellReuseIdentifier: "WinningTableCell")
        self.viewDidLayoutSubviews()
        getAllWinnings()
    }
    
    //MARK: View Will Appear
    override func viewWillAppear(_ animated: Bool) {
        
    }
}

//MARK:- TableView Delegates
extension NewGuestPassVC: UITableViewDelegate, UITableViewDataSource, MainScreenTableCellProtocol {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allWinnings.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MainScreenTableCell", for: indexPath) as! MainScreenTableCell
            cell.configureCell(DescText: "Clever handicapping tips\n\nWe reveal the longshots with strongest\nadvantages for today\'s specific race type.\n\nAs our mission is to protect your bankroll, we only publish picks once distinct signals are identified")
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WinningTableCell", for: indexPath) as! WinningTableCell
            cell.configureCell(Winnig: allWinnings[indexPath.row-1])
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func guestPassClicked() {
        let vc = SignUpVC.instantiateFromStoryboard(storyboard: mainStoryBoard)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func loginScreenClicked() {
        let vc = SignInVC.instantiateFromStoryboard(storyboard: mainStoryBoard)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK:- API Handler
extension NewGuestPassVC {
    //MARK: Get All Winnings
    private func getAllWinnings() {
        WebService.wsAppGetAllWinnings(success: { (winning) in
            self.allWinnings = winning
            self.table_View.reloadData()
        }) { (logoutBool, errorMsg) in
            
        }
    }
}
