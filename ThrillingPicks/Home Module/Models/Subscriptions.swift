//
//  Subscriptions.swift
//  ThrillingPicks
//
//  Created by iOSDev on 5/22/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit

struct Subscription: Codable {
    var id: Int?
    var subscriptionName, subscriptionPrice, subscriptionSlug: String?
    var subscriptionValidity: Int?
    var subscriptionDescription, subscriptionStatus, createdAt, updatedAt, subscriptionInterval: String?
    var subscriptionType: String?
    var discountedAmount: String?
    
    enum CodingKeys: String, CodingKey {
        case id, discountedAmount
        case subscriptionName = "subscription_name"
        case subscriptionPrice = "subscription_price"
        case subscriptionSlug = "subscription_slug"
        case subscriptionValidity = "subscription_validity"
        case subscriptionDescription = "subscription_description"
        case subscriptionStatus = "subscription_status"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case subscriptionInterval = "subscription_interval"
        case subscriptionType = "subscription_type"
    }
}
