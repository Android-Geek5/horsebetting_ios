//
//  CreditCard.swift
//  ThrillingPicks
//
//  Created by iOSDev on 6/7/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit

// MARK: - Credit Card
struct CreditCard: Codable {
    let id, userID: Int?
    let cardID, name, cardPaymentName, cardLastFourNumber: String?
    let cardExpMonth, cardExpYear: Int?
    let createdAt, updatedAt: String?
    var isSelected: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case cardID = "card_id"
        case name
        case cardPaymentName = "card_payment_name"
        case cardLastFourNumber = "card_last_four_number"
        case cardExpMonth = "card_exp_month"
        case cardExpYear = "card_exp_year"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
