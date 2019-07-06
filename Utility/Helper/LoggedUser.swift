//
//  LoggedUser.swift
//  ThrillingPicks
//
//  Created by iOSDev on 5/21/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit

//MARK: Global values
struct Global {
    /// Logged user ref
    static var LoggedUser:LoggedUser?
    /// Recent Win Array
    static var recentPicksArray: [RecentPick] = []
}

// MARK: - Logged User
struct LoggedUser: Codable {
    let id: Int?
    let name, email, userSubscriptionType, subscriptionPrice: String?
    let userGoogleID, userFacebookID: String?
    let stripeCustomerID: String?
    let emailVerifiedAt: String?
    let dob, promocode: String?
    let userProfileImage: String?
    let securityHash, role, userStatus: String?
    let userSubscriptionName: String?
    let createdAt, updatedAt: String?
    let userSubscriptionStartDate: String?
    let userSubscriptionEndDate, userToken: String?
    let userProfileImageURL: String?
    let codesArray: [CouponCode]?
    let referedToAmount: String?
    let referedByAmount: String?
    
    
    enum CodingKeys: String, CodingKey {
        case id, name, email
        case userGoogleID = "user_google_id"
        case userFacebookID = "user_facebook_id"
        case stripeCustomerID = "stripe_customer_id"
        case emailVerifiedAt = "email_verified_at"
        case dob, promocode
        case userProfileImage = "user_profile_image"
        case securityHash = "security_hash"
        case role
        case userStatus = "user_status"
        case userSubscriptionName = "user_subscription_name"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case userSubscriptionStartDate = "user_subscription_start_date"
        case userSubscriptionEndDate = "user_subscription_end_date"
        case userToken = "user_token"
        case userProfileImageURL = "user_profile_image_url"
        case codesArray = "codes_array"
        case userSubscriptionType = "user_subscription_type"
        case subscriptionPrice = "subscription_price"
        case referedToAmount = "refered_to_amount"
        case referedByAmount = "refered_by_amount"
    }
}

// MARK:- Coupon Code
struct CouponCode: Codable {
    var id, referedByUserID, referedToUserID: Int?
    var inviteCode, discount, referedByAmount, referedToAmount: String?
    var userCodeStatus, createdAt, updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case referedByUserID = "refered_by_user_id"
        case referedToUserID = "refered_to_user_id"
        case inviteCode = "invite_code"
        case discount
        case referedByAmount = "refered_by_amount"
        case referedToAmount = "refered_to_amount"
        case userCodeStatus = "user_code_status"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
