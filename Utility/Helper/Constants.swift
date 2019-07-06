//
//  Constants.swift
//  ThrillingPicks
//
//  Created by iOSDeveloper on 5/8/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit

/// App Name
let TAppName: String = "Thrilling Picks"
/// Logged user info Key
let loggedUserKey: String = "LoggedUserData"
/// Stripe Test Key
//let STripeTestKet: String = "pk_test_j1x6N6NRcxR8AolRflTBjQnp00Q58NjWYa"
/// Stripe Live Key
let STripeTestKet: String = "pk_live_xFfIYb7MKishcUMq5Nej632b00MCFbAFdK"

/// Colors
let buttonBorderPurpleColor: UIColor = UIColor(red: 46/255, green: 3/255, blue: 84/255, alpha: 1.0)
/// Gray BG Color
let buttonGrayBGColor: UIColor = UIColor(red: 136/255, green: 137/255, blue: 139/255, alpha: 1.0)
/// Yellow Color
let yellowColor: UIColor = UIColor(red: 247/255, green: 215/255, blue: 8/255, alpha: 1.0)
/// Text Red Color
let trackNameRedColor: UIColor = UIColor(red: 241/255, green: 60/255, blue: 3/255, alpha: 1.0)
/// Baby Pink Background Color
let babyPinkBGColor: UIColor = UIColor(red: 255/255, green: 250/255, blue: 250/255, alpha: 1.0)
/// Horse Name Number Color
let horseNameNumberColor: UIColor = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 1.0)
/// Light Gray Base Coloe
let lightGrayBaseColor: UIColor = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1.0)

/// Main StoryBoard
let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
/// Home Stpryboard
let homeStoryBoard: UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
/// Payment StoryBoard
let paymentStoryBoard: UIStoryboard = UIStoryboard(name: "Payment", bundle: nil)
/// Side Menu Storyboard
let sideMenuStoryBoard: UIStoryboard = UIStoryboard(name: "SideMenu", bundle: nil)

/// Base URL --> Live
let baseURL: String = "http://13.59.184.51/api/"
/// Base URL --> Dev
//let baseURL: String = "http://192.168.0.148/horsebetting_web/public/api/"

/// App Auth Key

/// API Header Array
let apiHeaderArray: [String:String] = [
    "Authorization": Functions.getAppAuthKey(),
    "Content-Type":"application/x-www-form-urlencoded"
]

/// Login Module API
let appLoginUserWithEmail: String = "\(baseURL)login"
/// Signup user API
let appSignupUser: String = "\(baseURL)register"
/// Forgot Password API
let appUserForgotPassword: String = "\(baseURL)forgot-password"
/// Social Login API
let appSocialLoginAPI: String = "\(baseURL)social-login"

/// Home Module
/// Get All Subscriptions
let appGetAllSubscriptions: String = "\(baseURL)subscriptions"
/// Cancel Subscription
let appCancelCurrentSubscription: String = "\(baseURL)cancel-subscription"
/// Make Subscription Payment
let appMakeSubscriptionPayment: String = "\(baseURL)make-payment"
/// Session Login API
let appSessionLogin: String = "\(baseURL)session-login"
/// Get All Track Races Done
let appGetAllTrackRaces: String = "\(baseURL)tracks"
/// Get Track Races
let appGetAllRacesForTrack: String = "\(baseURL)track-races"

/// Side Menu
let appGetAllWinnings: String =  "\(baseURL)get-winning"
/// Change Password
let appChangePassword: String = "\(baseURL)change-password"
/// Edit Profile API
let appUpdateUserProfileData: String = "\(baseURL)edit-profile"

/// Payment Flow
let appGetAllCardsAdded: String = "\(baseURL)get-card"
/// Add New Card
let appAddNewCard: String = "\(baseURL)add-card"
/// Delete Card
let appDeleteAddedCard: String = "\(baseURL)delete-card"
/// Verify Coupon
let appVerifyCouponCode: String = "\(baseURL)verify-coupon"
/// Invite Screen API
let appGetUserInviteDetails: String = "\(baseURL)invite"
/// Show Price Details API
let appShowSubsPrice: String = "\(baseURL)show-price"
/// Edit Card API
let appEditCreditCard: String = "\(baseURL)edit-card"
/// Logout API
let appLogoutUser: String = "\(baseURL)logout"

