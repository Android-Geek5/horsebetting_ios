//
//  TrackRacesVC.swift
//  ThrillingPicks
//
//  Created by iOSDev on 5/30/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit

class TrackRacesVC: UIViewController {
    /// Track Name Label
    @IBOutlet weak var trackNameLabel: UILabel!
    /// Tracks TV
    @IBOutlet weak var tracksTV: UITableView!
    /// Secondary Back Btn
    @IBOutlet weak var secondaryBackBtn: UIButton!
    
    /// Selected Track
    var selectedTrack: Today?
    /// Is For Today
    var isTodayDate: Bool = true
    /// Raced
    fileprivate var trackRaces: [Race] = [] {
        didSet {
            tracksTV.reloadData()
        }
    }
}

//MARK: View Life Cycles
extension TrackRacesVC {
    //MARK: Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let track = selectedTrack else {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        trackNameLabel.text = track.trackName ?? ""
        getAllRacesFor(TrackID: String(track.id ?? 0))
    }
    
    //MARK: Layout Subviews
    override func viewDidLayoutSubviews() {
        secondaryBackBtn.roundWithRadious(Radius: secondaryBackBtn.frame.height*0.5)
    }
}

//MARK:- TableView Delegates
extension TrackRacesVC: UITableViewDelegate, UITableViewDataSource {
    //MARK: Number of Rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackRaces.count + 1
    }
    
    //MARK: Cell For Row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TrackRaceDateTVCell", for: indexPath) as! TrackRaceDateTVCell
            var dComp: DateComponents = DateComponents()
            dComp.day = 1
            cell.configureCell(Date: isTodayDate ? (Date()) :
                (Calendar.current.date(byAdding: dComp, to: Date()))!)
            return cell
        } else {
            if (trackRaces[indexPath.row - 1].trackRaceIsGuestAvailable ?? "").trimmed() == "yes" {
                /// Paid
                let cell = tableView.dequeueReusableCell(withIdentifier: "TrackRaceDetailPaidTVCell", for: indexPath) as! TrackRaceDetailPaidTVCell
                cell.configureCell(TrackRace: trackRaces[indexPath.row-1])
                return cell
            } else {
                /// Free
                let cell = tableView.dequeueReusableCell(withIdentifier: "TrackRaceDetailTVCell", for: indexPath) as! TrackRaceDetailTVCell
                cell.configureCell(TrackRace: trackRaces[indexPath.row-1])
                return cell
            }
        }
    }
    
    //MARK: Height For Row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//MARK: API Handler
extension TrackRacesVC {
    //MARK: Get All Races For Track
    private func getAllRacesFor(TrackID trackID: String) {
        /// Get Date Value
        var dateStr: String = ""
        if isTodayDate {
            dateStr = Date().getDateFormattedInString(of: .YYYYMMDD)
        } else {
            var oneDateCom: DateComponents = DateComponents()
            oneDateCom.day = 1
            let newDate = Calendar.current.date(byAdding: oneDateCom, to: Date())
            dateStr = newDate!.getDateFormattedInString(of: .YYYYMMDD)
        }
        Functions.shared.showActivityIndicator("Loading", view: self)
        /// Get Track Record
        WebService.wsGetRacesOfTrackWith(TrackID: trackID, For: dateStr, success: { (races) in
            Functions.shared.hideActivityIndicator()
            guard let races = races else {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                    self.navigationController?.popViewController(animated: true)
                })
                return
            }
            self.trackRaces = races
        }) { (logoutBool, errorMsg) in
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

//MARK:- Button Actions
extension TrackRacesVC {
    //MARK: Back Btn Action
    @IBAction func backBtnAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
