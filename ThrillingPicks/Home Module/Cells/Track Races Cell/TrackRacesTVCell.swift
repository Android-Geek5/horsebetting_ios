//
//  TrackRacesTVCell.swift
//  ThrillingPicks
//
//  Created by iOSDev on 5/30/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit

class TrackRaceDateTVCell: UITableViewCell {
    /// Date Label
    @IBOutlet weak var trackRaceDateLabel: UILabel!
    
    //MARK: Awake From Nib
    override func awakeFromNib() {
        trackRaceDateLabel.textColor = trackNameRedColor
    }
    
    //MARK: Configure Cell
    func configureCell(Date date: Date) {
        trackRaceDateLabel.text = date.getDateFormattedInString(of: .DDDDMMDDYY)
    }
}

class TrackRaceDetailPaidTVCell: UITableViewCell {
    /// Race Number Label
    @IBOutlet weak var raceNumberLabel: UILabel!
    /// HTML Base View
    @IBOutlet weak var htmlBaseView: UIView!
    
    //MARK: Awake From Nib
    override func awakeFromNib() {
        htmlBaseView.roundWithRadious(Radius: 6)
    }
    
    //MARK: Configure Cell
    func configureCell(TrackRace race: Race) {
        raceNumberLabel.attributedText = attributredStringForHorseTrackTime(TrackNumber: race.trackRaceNumber ?? "1", Time: Functions.getDateFrom(DateString: (race.trackRaceDateTime ?? "2019-06-04 03:32:00").trimmed(), With: .YYYYMMDDHHMMSS).getDateFormattedInString(of: .HHMM))
    }
    
    func attributredStringForHorseTrackTime(TrackNumber num: String, Time time: String) -> NSAttributedString {
        let attriString = NSMutableAttributedString()
        attriString.append(NSAttributedString(string: "Race #\(num) ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.poppinsMediumWith(Size: 20)]))
        attriString.append(NSAttributedString(string: "\(time) EST", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray, NSAttributedString.Key.font: UIFont.poppinsMediumWith(Size: 20)]))
        return attriString
    }
}

class TrackRaceDetailTVCell: UITableViewCell {
    /// Race Number Label
    @IBOutlet weak var raceNumberLabel: UILabel!
    /// HTML Base View
    @IBOutlet weak var htmlBaseView: UIView!
    /// HTML Text Label - Attributed Text
    @IBOutlet weak var htmlTextLabel: UILabel!
    
    //MARK: Awake From Nib
    override func awakeFromNib() {
        htmlBaseView.roundWithRadious(Radius: 6)
    }
    
    //MARK: Configure Cell
    func configureCell(TrackRace race: Race) {
        raceNumberLabel.attributedText = attributredStringForHorseTrackTime(TrackNumber: race.trackRaceNumber ?? "1", Time: Functions.getDateFrom(DateString: (race.trackRaceDateTime ?? "2019-06-04 03:32:00").trimmed(), With: .YYYYMMDDHHMMSS).getDateFormattedInString(of: .HHMM))
        htmlTextLabel.attributedText = getAttributedTrackDescText(HorseNumber: race.trackRaceHorseNumber ?? "0", Name: race.trackRaceHorseName ?? "", sample: (race.trackRaceDescription ?? "").trimmed())
    }
    
    func attributredStringForHorseTrackTime(TrackNumber num: String, Time time: String) -> NSAttributedString {
        let attriString = NSMutableAttributedString()
        attriString.append(NSAttributedString(string: "Race #\(num) ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.poppinsMediumWith(Size: 20)]))
        attriString.append(NSAttributedString(string: "\(time) EST", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray, NSAttributedString.Key.font: UIFont.poppinsMediumWith(Size: 20)]))
        return attriString
    }
    
    //MARK: Get Attributext Text
    func getAttributedTrackDescText(HorseNumber num: String, Name name: String, sample samp: String) -> NSAttributedString {
        print("Samp: \(samp.trimmingCharacters(in: .whitespacesAndNewlines))")
        let attriString = NSMutableAttributedString()
        attriString.append(NSAttributedString(string: "#\(num) \(name)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray, NSAttributedString.Key.font: UIFont.poppinsRegularWith(Size: 17)]))
        attriString.append(NSAttributedString(string: "\n"))
        attriString.append(htmlAttriButedText(str: samp))
        return attriString
    }
    
    func htmlAttriButedText(str : String) -> NSAttributedString {
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
                        newFont = UIFont.poppinsRegularWith(Size: 20)
                        fontColor = UIColor.lightGray
                    case "bold":
                        newFont = UIFont.poppinsBoldWith(Size: 20)
                        fontColor = UIColor.lightGray
                    case "italic":
                        newFont = UIFont.poppinsItalicWith(Size: 20)
                        fontColor = UIColor.lightGray
                    default:
                        newFont = UIFont.poppinsMediumWith(Size: 20)
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
