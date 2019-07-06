//
//  MainHomeVC.swift
//  ThrillingPicks
//
//  Created by iOSDev on 5/28/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit

//MARK:- Side Menu Protocol
protocol HomeVCProtocol {
    //MARK: Side Menu Btn Pressed
    func sideMenuBtnPressed(Status isSelected: Bool)
}

class MainHomeVC: UIViewController {
    /// Main Scroll View
    @IBOutlet weak var mainScrollView: UIScrollView!
    /// Today Tomorrow Header Base View - Add Shadow
    @IBOutlet weak var todayTomBaseView: UIView!
    /// Today Header Label
    @IBOutlet weak var todayHeaderLabel: UILabel!
    /// Tomorrow Header Label
    @IBOutlet weak var tomorrowHeaderLabel: UILabel!
    /// Floating Label
    @IBOutlet weak var floatingLabel: UILabel!
    /// Floating Label Leading Constraint
    @IBOutlet weak var floatingLabelLeadingConstraint: NSLayoutConstraint!
    /// Side Menu
    @IBOutlet weak var sideMenuBtn: UIButton!
    /// Today List TV
    @IBOutlet weak var todayListTV: UITableView!
    /// Tomorrow List TV
    @IBOutlet weak var tomorrowListTV: UITableView!
    
    /// Delegate
    var delegate: HomeVCProtocol?
    /// Swipe To Refresh
    fileprivate var tableRefreshControl: UIRefreshControl?
    /// Is API Loading
    fileprivate var isAPIinProcess: Bool = false
    
    ///Track Record
    fileprivate var trackRecord: Tracks? {
        didSet {
            self.todayListTV.reloadData()
            self.tomorrowListTV.reloadData()
        }
    }
}

//MARK:- View Life Cycles
extension MainHomeVC {
    //MARK: Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        todayListTV.register(UINib(nibName: "TodayTomorrowTableCell", bundle: nil), forCellReuseIdentifier: "TodayTomorrowTableCell")
        tomorrowListTV.register(UINib(nibName: "TodayTomorrowTableCell", bundle: nil), forCellReuseIdentifier: "TodayTomorrowTableCell")
        todayListTV.tableFooterView = UIView()
        tomorrowListTV.tableFooterView = UIView()
        floatingLabel.backgroundColor = trackNameRedColor
    }
    
    //MARK: View Did Appear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkSessionExpiry()
        addRefreshControlToTableView()
    }
    
    //MARK: View Did Disappear
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if tableRefreshControl != nil {
            tableRefreshControl?.removeFromSuperview()
            tableRefreshControl = nil
        }
    }
    
    //MARK: Layout Subviews
    override func viewDidLayoutSubviews() {
        todayTomBaseView.addShadowToView(ShadowColor: .black, Opacity: 0.4, Radius: 3, Size: .zero)
    }
}

//MARK:- Required Functions
extension MainHomeVC {
    //MARK: Add Refresh Control
    private func addRefreshControlToTableView() {
        if tableRefreshControl != nil {
            return
        }
        tableRefreshControl = UIRefreshControl()
        tableRefreshControl?.addTarget(self, action: #selector(self.refreshTVData), for: .touchDragExit)
        todayListTV.addSubview(tableRefreshControl!)
        tomorrowListTV.addSubview(tableRefreshControl!)
        tableRefreshControl?.layoutIfNeeded()
    }
    
    //MARK: Refresh TV Data
    @objc
    private func refreshTVData() {
        checkSessionExpiry()
    }
}

//MARK:- TableView Delegates
extension MainHomeVC: UITableViewDelegate, UITableViewDataSource {
    //MARK: Number of Rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == todayListTV ? (trackRecord?.today?.count ?? 0) : (trackRecord?.tomorrow?.count ?? 0)
    }
    
    //MARK: Cell For Row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodayTomorrowTableCell", for: indexPath) as! TodayTomorrowTableCell
        cell.configureCellWith(Track: tableView == todayListTV ? (trackRecord!.today![indexPath.row]) : (trackRecord!.tomorrow![indexPath.row]))
        return cell
    }
    
    //MARK: Did Select
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = TrackRacesVC.instantiateFromStoryboard(storyboard: homeStoryBoard)
        if tableView == todayListTV {
            vc.selectedTrack = trackRecord!.today![indexPath.row]
            vc.isTodayDate = true
        } else {
            vc.selectedTrack = trackRecord!.tomorrow![indexPath.row]
            vc.isTodayDate = false
        }
        self.navigationController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: Height For Row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//MARK:- API Handler
extension MainHomeVC {
    //MARK: Session Login API
    private func checkSessionExpiry() {
        isAPIinProcess = true
        Functions.shared.showActivityIndicator("Loading", view: self)
        WebService.wsSessionLoginUser(success: { (success) in
            Functions.shared.hideActivityIndicator()
            self.getAllTrackRecords()
        }) { (logoutBool, errorMsg) in
            self.isAPIinProcess = false
            Functions.shared.hideActivityIndicator()
            if logoutBool {
                Functions.logoutUser(With: self.navigationController?.navigationController)
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                    if !(errorMsg ?? "").trimmed().isEmpty { self.showAlert(AlertTitle: TAppName, AlertMessage: errorMsg!) }
                })
            } else {
                /// Had Error But Session Might or might not have xpired
                /// Check for session Login Again
                self.showAlertWithOneAction(AlertTitle: TAppName, AlertMessage: errorMsg ?? "Issue while getting details. Please try again.", ActionTitle: "Retry", success: { (suc) in
                    if suc {
                        self.checkSessionExpiry()
                    }
                })
            }
        }
    }
    
    //MARK: Get All Track Details
    private func getAllTrackRecords() {
        isAPIinProcess = true
        Functions.shared.showActivityIndicator("Loading", view: self)
        WebService.wsGetAllTrackRacesTodayAndTomorrow(success: { (tracks) in
            self.isAPIinProcess = false
            Functions.shared.hideActivityIndicator()
            guard let tracks = tracks else {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                    self.showAlert(AlertTitle: TAppName, AlertMessage: "Error Getting Tracks. Please Try Again.")
                })
                return
            }
            self.trackRecord = tracks
            /// Refresh Views
        }) { (logoutBool, errorMsg) in
            self.isAPIinProcess = false
            Functions.shared.hideActivityIndicator()
            if logoutBool {
                Functions.logoutUser(With: self.navigationController?.navigationController)
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                if !(errorMsg ?? "").trimmed().isEmpty { self.showAlert(AlertTitle: TAppName, AlertMessage: errorMsg!) }
            })
        }
    }
}

//MARK:- Button Ations
extension MainHomeVC {
    //MARK: Side Menu Btn Action
    @IBAction func sideMenuBtnAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.delegate?.sideMenuBtnPressed(Status: sender.isSelected)
    }
}

//MARK:- UIScrollView Delegates
extension MainHomeVC: UIScrollViewDelegate {
    //MARK: ScrollView Scrolling
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == mainScrollView {
            if scrollView.contentOffset.y < 0 {
                return
            }
            floatingLabelLeadingConstraint.constant = scrollView.contentOffset.x / 2
            switch scrollView.contentOffset.x {
            case let x where x > self.mainScrollView.frame.width/4:
                /// x is > 25% of screen
                /// Make Tomorrow as Red
                tomorrowHeaderLabel.textColor = trackNameRedColor
                todayHeaderLabel.textColor = .darkText
            case let x where x < (self.mainScrollView.frame.width - self.mainScrollView.frame.width/2):
                /// Make Today Red
                todayHeaderLabel.textColor = trackNameRedColor
                tomorrowHeaderLabel.textColor = .darkText
            default: break
            }
        }
        
    }
    
    //MARK: ScrollView Did End Dragging
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == todayListTV || scrollView == tomorrowListTV {
            if scrollView.contentOffset.y < 0 {
                if scrollView.contentOffset.y < -40 {
                    print("Pull To Refresh")
                    if isAPIinProcess { return }
                    tableRefreshControl?.sendActions(for: .touchDragExit)
                }
            }
        }
    }
}
