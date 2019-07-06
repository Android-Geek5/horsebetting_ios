//
//  CreditrCardTVCell.swift
//  ThrillingPicks
//
//  Created by iOSDev on 6/7/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit
import Stripe

class CreditCardTVCell: UITableViewCell {
    /// BaseView
    @IBOutlet weak var baseView: UIView!
    /// Card Brand Label
    @IBOutlet weak var cardBrandLabel: UILabel!
    /// Card Holder Name Label
    @IBOutlet weak var cardHolderNameLabel: UILabel!
    /// Card Number Label
    @IBOutlet weak var cardNumberlabel: UILabel!
    /// Expiry Date/Month Label
    @IBOutlet weak var expiryDateMonthLabel: UILabel!
    /// Card CVV Label
    @IBOutlet weak var cardCVVLabel: UILabel!
    /// Card Brand ImageView
    @IBOutlet weak var cardBrandImageView: UIImageView!
    /// Selected Image Base View
    @IBOutlet weak var selectedImageBaseView: UIView!
    /// Selected Image View
    @IBOutlet weak var selectedImageView: UIImageView!
    
    //MARK: Awake From Nib
    override func awakeFromNib() {
        baseView.roundWithRadious(Radius: 12)
        baseView.addShadowToView(ShadowColor: .black, Opacity: 0.2, Radius: 2, Size: .zero)
        selectedImageBaseView.roundWithRadious(Radius: selectedImageBaseView.frame.height/2)
    }
    
    //MARK: Configure Cell With Card
    func congfigureCell(CreditCard card: CreditCard) {
        cardBrandLabel.text = (card.cardPaymentName ?? "").trimmed().uppercased()
        cardHolderNameLabel.text = (card.name ?? "").trimmed()
        cardNumberlabel.text = "XXXX XXXX XXXX \((card.cardLastFourNumber ?? "XXXX").trimmed())"
        expiryDateMonthLabel.text = "\(String(format: "%02d", card.cardExpMonth ?? 12)) / \((card.cardExpYear ?? 2020) % 100)"
        cardCVVLabel.text = "CVV xxx"
        
        if card.isSelected {
            selectedImageBaseView.backgroundColor = .white
            selectedImageView.image = UIImage(named: "tickedGreenCircle")
        } else {
            selectedImageBaseView.backgroundColor = lightGrayBaseColor
            selectedImageView.image = nil
        }
        
        if let cardTypeValue = card.cardPaymentName?.lowercased() {
            switch cardTypeValue {
            case "visa":
                cardBrandImageView.image = STPImageLibrary.brandImage(for: .visa)
            case "mastercard", "master card":
                cardBrandImageView.image = STPImageLibrary.brandImage(for: .masterCard)
            case "americanexpress", "american express", "amex":
                cardBrandImageView.image = STPImageLibrary.brandImage(for: .amex)
            case "dicover":
                cardBrandImageView.image = STPImageLibrary.brandImage(for: .discover)
            case "dinersclub", "diners club":
                cardBrandImageView.image = STPImageLibrary.brandImage(for: .dinersClub)
            case "jcb":
                cardBrandImageView.image = STPImageLibrary.brandImage(for: .JCB)
            case "unionpay", "union pay":
                cardBrandImageView.image = STPImageLibrary.brandImage(for: .unionPay)
            default:
                cardBrandImageView.image = STPImageLibrary.brandImage(for: .unknown)
            }
        }
    }
    
}
