//
//  TodayTomorrowTableCell.swift
//  ThrillingPicks
//
//  Created by iOSDev on 5/30/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit

class TodayTomorrowTableCell: UITableViewCell {
    /// Base View
    @IBOutlet weak var baseView: UIView!
    /// Logo ImageView
    @IBOutlet weak var logoImageView: UIImageView!
    /// Track Name Label
    @IBOutlet weak var trackNameLabel: UILabel!
    /// Arrow ImageView
    @IBOutlet weak var rightArrowImageView: UIImageView!
    
    //MARK: Awake From Nib
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        rightArrowImageView.image = UIImage(named: "RightArrow_Black")!.imageWithColor(color1: .lightGray)
        logoImageView.image = UIImage(named: "horse")
        baseView.roundWithRadious(Radius: 5)
    }
    
    //MARK: Configure Cell
    func configureCellWith(Track todTom: Today) {
        trackNameLabel.text = todTom.trackName ?? ""
    }
}
