//
//  WinningTableCell.swift
//  ThrillingPicks
//
//  Created by iOSDev on 6/12/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit

class WinningTableCell: UITableViewCell {
    /// Recent Result Date Label
    @IBOutlet weak var recentResultLabel: UILabel!
    /// Recent Result Track ID and Name Label
    @IBOutlet weak var trackIDNamebel: UILabel!
    /// Track Bet Type Label
    @IBOutlet weak var trackBetTypeLabel: UILabel!
    /// Track Bt Selection Output Label
    @IBOutlet weak var trackBetSelectionLabel: UILabel!
    /// Track Bet Total Amount Label
    @IBOutlet weak var trackBetTotalAmountLabel: UILabel!
    /// Track Win Amount Label
    @IBOutlet weak var trackBetTotalWinLabel: UILabel!
    /// Track TML Desc Label
    @IBOutlet weak var htmlLabel: UILabel!
    
    //MARK: Awake From Nib
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //MARK: Configure Cell
    func configureCell(Winnig win: Winning) {
        let resultDate: Date = Functions.getDateFrom(DateString: win.dateOfResult ?? "2019-10-06", With: .YYYYMMDD)
        recentResultLabel.text = "Recent Result: \(resultDate.getDateFormattedInString(of: .EEDDYYYY))"
        trackIDNamebel.text = "\(win.trackName ?? "") \(win.trackID ?? 0)"
        trackBetTypeLabel.text = win.betType ?? ""
        trackBetSelectionLabel.attributedText = htmlAttriButedTextForTrackSelection(str: win.selection ?? "")
        trackBetTotalAmountLabel.text = "$\(win.betTotal ?? "0")"
        trackBetTotalWinLabel.text = "$\(win.amountWon ?? "0")"
        htmlLabel.attributedText = htmlAttriButedTextForTrackDesc(str: win.raceConditions ?? "")
    }
    
    func htmlAttriButedTextForTrackSelection(str : String) -> NSAttributedString {
        let attrStr = try! NSMutableAttributedString(
            data: str.data(using: String.Encoding.utf8, allowLossyConversion: true)!,
            options: [ .documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue],documentAttributes: nil)
        attrStr.enumerateAttribute(.font, in: NSMakeRange(0, attrStr.length), options: .longestEffectiveRangeNotRequired) { (value, range, stop) in
            var newFont = UIFont()
            var fontColor: UIColor = UIColor.gray
            newFont = UIFont.poppinsMediumWith(Size: 15)
            fontColor = UIColor.black
            attrStr.removeAttribute(.font, range: range)
            attrStr.removeAttribute(.foregroundColor, range: range)
            attrStr.addAttribute(.font, value: newFont, range: range)
            attrStr.addAttribute(.foregroundColor, value: fontColor, range: range)
        }
        return attrStr
    }
    
    func htmlAttriButedTextForTrackDesc(str : String) -> NSAttributedString {
        let attrStr = try! NSMutableAttributedString(
            data: str.data(using: String.Encoding.utf8, allowLossyConversion: true)!,
            options: [ .documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue],documentAttributes: nil)
        attrStr.enumerateAttribute(.font, in: NSMakeRange(0, attrStr.length), options: .longestEffectiveRangeNotRequired) { (value, range, stop) in
            if let f = value as? UIFont {
                
                if let fontFace = f.fontDescriptor.object(forKey: .face) as? String {
                    /* Require While checking Font Family --->      print("Font Face: \(fontFace)") */
                    var newFont = UIFont()
                    var fontColor: UIColor = UIColor.gray
                    switch fontFace.lowercased() {
                    case "regular":
                        newFont = UIFont.poppinsRegularWith(Size: 15)
                        fontColor = UIColor.lightGray
                    case "bold":
                        newFont = UIFont.poppinsBoldWith(Size: 15)
                        fontColor = UIColor.lightGray
                    case "italic":
                        newFont = UIFont.poppinsItalicWith(Size: 15)
                        fontColor = UIColor.lightGray
                    case "semibold", "semo bold", "semi-bold":
                        newFont = UIFont.poppinsSemiBoldWith(Size: 15)
                        fontColor = UIColor.lightGray
                    default:
                        newFont = UIFont.poppinsMediumWith(Size: 15)
                        fontColor = UIColor.darkGray
                    }
                    attrStr.removeAttribute(.font, range: range)
                    attrStr.removeAttribute(.foregroundColor, range: range)
                    attrStr.addAttribute(.font, value: newFont, range: range)
                    attrStr.addAttribute(.foregroundColor, value: fontColor, range: range)
                }
            }
        }
        return attrStr
    }
}
