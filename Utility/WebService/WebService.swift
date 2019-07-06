//
//  WebService.swift
//  ThrillingPicks
//
//  Created by iOSDev on 5/20/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit
import Alamofire

enum APIType {
    case Post
    case Get
}

class WebService: NSObject {
    
}

//MARK:- Login Module API
extension WebService {
    //MARK: Login User With E-mail
    class func wsLoginUserWith(Email email: String, Password password: String, success:@escaping (Bool,String) -> Void, failure:@escaping (Error) -> Void) {
        var paramDict:[String:String]?
        paramDict=[
            "email":email,
            "password":password.md5
        ]
        print("HeaderArray: \(apiHeaderArray)")
        print("Login API Param: \(paramDict ?? [:])")
        Functions.requestGetPostURLSession(APIType: .Post, APIURL: appLoginUserWithEmail, HeaderArray: apiHeaderArray, Parameters: Functions.getJSONParamAsString(With: paramDict ?? [:]), success: { (jsonDict, fetchedData) in
            print("Login API Response ==> \(jsonDict)")
            paramDict=nil
            if let codeValue = jsonDict["code"] as? String {
                switch codeValue {
                case "1":
                    do {
                        let loginDataDict = jsonDict["data"] as! [String:Any]
                        let loginDataDictData = try JSONSerialization.data(withJSONObject: loginDataDict, options: [])
                        parseLoginSignupData(FetchedData: loginDataDictData, success: { (pasrsingSuccess) in
                            success(pasrsingSuccess, "")
                        }, failure: { (error) in
                            failure(error)
                        })
                    } catch let error {
                        print("Errr ==> \(error.localizedDescription)")
                        failure(error)
                    }
                default: success(false,jsonDict["message"] as? String ?? "Error while logging in. Please try again.")
                }
            } else { success(false,jsonDict["message"] as? String ?? "Error while logging in. Please try again.") }
        }) { (error) in
            paramDict=nil
            failure(error)
        }
    }
    
    //MARK: Sign Up New User
    class func wsSignupUserWith(Name name: String, Email email: String, Password password: String, DOB dob: String, Promocode promo: String, SocialName mediaName: String, SocialID mediaID: String, success:@escaping (Bool,String) -> Void, failure:@escaping (Error) -> Void) {
        var paramDict:[String:String]?
        paramDict=[
            "name":name,
            "email":email,
            "email_confirmation":email,
            "password":password.md5,
            "dob":dob,
            "promocode":promo,
            "social_media_name":mediaName,
            "social_media_id":mediaID
        ]
        print("HeaderArray: \(apiHeaderArray)")
        print("Signup API Param: \(paramDict ?? [:])")
        
        Functions.requestGetPostURLSession(APIType: .Post, APIURL: appSignupUser, HeaderArray: apiHeaderArray, Parameters: Functions.getJSONParamAsString(With: paramDict ?? [:]), success: { (jsonDict, fetchedData) in
            print("Signup API Response ==> \(jsonDict)")
            paramDict=nil
            if let codeValue = jsonDict["code"] as? String {
                switch codeValue {
                case "1":
                    do {
                        let loginDataDict = jsonDict["data"] as! [String:Any]
                        let loginDataDictData = try JSONSerialization.data(withJSONObject: loginDataDict, options: [])
                        parseLoginSignupData(FetchedData: loginDataDictData, success: { (pasrsingSuccess) in
                            success(pasrsingSuccess, "")
                        }, failure: { (error) in
                            failure(error)
                        })
                    } catch let error {
                        print("Errr ==> \(error.localizedDescription)")
                        failure(error)
                    }
                default: success(false,jsonDict["message"] as? String ?? "Error while logging in. Please try again.")
                }
            } else { success(false,jsonDict["message"] as? String ?? "Error while logging in. Please try again.") }
        }) { (error) in
            paramDict=nil
            failure(error)
        }
    }
    
    //MARK: Forgot User Password
    class func wsUserForgotPassword(For email: String, success:@escaping (Bool,String) -> Void, failure:@escaping (Error) -> Void) {
        Functions.requestGetPostURLSession(APIType: .Post, APIURL: appUserForgotPassword, HeaderArray: apiHeaderArray, Parameters: Functions.getJSONParamAsString(With: ["login_email": email]), success: { (jsonDict, fetchedData) in
            print("Forgot Password API Response: \(jsonDict)")
            if let codeValue = jsonDict["code"] as? String {
                switch codeValue {
                case "1": success(true,jsonDict["message"] as? String ?? "An email has been sent to registerd email-id.")
                default: success(false,jsonDict["message"] as? String ?? "Error while logging in. Please try again.")
                }
            } else { success(false,jsonDict["message"] as? String ?? "Error while logging in. Please try again.") }
        }) { (error) in
            failure(error)
        }
    }
    
    //MARK: Social Login API
    /// Success (login Success, Naviaget to Signup, Message)
    class func wsSocialLoginAPI(SocialID socialID: String, SocialPlatform pType: LoginType,success: @escaping(Bool, Bool, String) -> Void, failure:@escaping (Error) -> Void) {
        var paramDict:[String:String]?
        paramDict=[
            "social_media_id":socialID,
            "social_media_name": pType.rawValue
        ]
        Functions.requestGetPostURLSession(APIType: .Post, APIURL: appSocialLoginAPI, HeaderArray: apiHeaderArray, Parameters: Functions.getJSONParamAsString(With: paramDict ?? [:]), success: { (jsonDict, fetchedData) in
            print("Social Login API Response: \(jsonDict)")
            if let codeValue = jsonDict["code"] as? String {
                switch codeValue {
                case "1": /// Success Login
                    do {
                        let loginDataDict = jsonDict["data"] as! [String:Any]
                        let loginDataDictData = try JSONSerialization.data(withJSONObject: loginDataDict, options: [])
                        parseLoginSignupData(FetchedData: loginDataDictData, success: { (pasrsingSuccess) in
                            success(true, false, jsonDict["message"] as? String ?? "")
                        }, failure: { (error) in
                            failure(error)
                        })
                    } catch let error {
                        print("Errr ==> \(error.localizedDescription)")
                        failure(error)
                    }
                case "2": /// Navigate to Signup screen
                    success(true, true, "")
                default: /// Error Case
                    success(false, false, jsonDict["message"] as? String ?? "")
                }
            } else { success(false, false, jsonDict["message"] as? String ?? "") }
        }) { (error) in
            failure(error)
        }
    }
    
    //MARK: Parse Login/Signup Data
    class func parseLoginSignupData(FetchedData fData: Data, success:@escaping (Bool) -> Void, failure:@escaping (Error) -> Void) {
        do {
            let gitData = try JSONDecoder().decode(LoggedUser.self, from: fData)
            Global.LoggedUser=gitData
            UserDefaults.standard.set(fData, forKey: loggedUserKey)
            success(true)
        } catch {
            Global.LoggedUser=nil
            print("Error while decoding JSON == \(error.localizedDescription)")
            failure(error)
        }
    }
}

//MARK:- Home Module
extension WebService {
    //MARK: Logout User
    class func wsLogoutUser(success: @escaping(Bool, String?) -> Void, failure: @escaping(Bool, String?) -> Void) {
        let paramDict:[String:String] = [
            "user_token":Global.LoggedUser?.userToken ?? ""
        ]
        print("Logout User API Response: \(paramDict)")
        
        Functions.requestGetPostURLSession(APIType: .Post, APIURL: appLogoutUser, HeaderArray: apiHeaderArray, Parameters: Functions.getJSONParamAsString(With: paramDict), success: { (jsonDict, fetchedData) in
            print("Logout User API Response: \(jsonDict)")
            if let codeValue = jsonDict["code"] as? String {
                switch codeValue {
                case "1": success(true, jsonDict["message"] as? String ?? "Success")
                case "-1": failure(true, jsonDict["message"] as? String ?? "Session Expired")
                default: failure(false, jsonDict["message"] as? String)
                }
            } else {
                failure(false, "No data Fetched. Please try again")
            }
        }) { (error) in
            failure(false, error.localizedDescription)
        }
    }
    
    //MARK: Get All Subscriptions
    class func wsGetAllSubscriptions(success: @escaping(Bool, [Subscription]?, String?) -> Void, failure:@escaping (Bool, String?) -> Void) {
        var paramDict:[String:String]?
        paramDict=[
            "user_token":Global.LoggedUser?.userToken ?? ""
        ]
        print("Get All Subscription API Response: \(paramDict!)")
        Functions.requestGetPostURLSession(APIType: .Post, APIURL: appGetAllSubscriptions, HeaderArray: apiHeaderArray, Parameters: Functions.getJSONParamAsString(With: paramDict!), success: { (jsonDict, fetchedData) in
            print("Get All Subscription API Response: \(jsonDict)")
            if let codeValue = jsonDict["code"] as? String {
                switch codeValue {
                case "-2": failure(true, jsonDict["message"] as? String)
                case "1":
                    do {
                        let finalDataDict = jsonDict["data"] as! [[String:Any]]
                        let fData = try JSONSerialization.data(withJSONObject: finalDataDict, options: [])
                        do {
                            let gitData = try JSONDecoder().decode([Subscription].self, from: fData)
                            success(true, gitData, nil)
                        } catch {
                            failure(false, error.localizedDescription)
                        }
                    } catch let error {
                        print("Errr ==> \(error.localizedDescription)")
                        failure(false, error.localizedDescription)
                    }
                default:
                    failure(false, jsonDict["message"] as? String)
                }
            } else {
                failure(false, jsonDict["message"] as? String)
            }
        }) { (error) in
            failure(false, error.localizedDescription)
        }
    }
    
    
    
    //MARK: Session Login API
    class func wsSessionLoginUser(success: @escaping(Bool) -> Void, failure: @escaping(Bool, String?) -> Void) {
        guard let loggedUser = Global.LoggedUser else {
            failure(true, "Session Expired.")
            return
        }
        print("Session Login API Header: \(apiHeaderArray)")
        print("Session Login API Param: \(["user_token": loggedUser.userToken ?? ""])")
        Functions.requestGetPostURLSession(APIType: .Post, APIURL: appSessionLogin, HeaderArray: apiHeaderArray, Parameters: Functions.getJSONParamAsString(With: ["user_token": loggedUser.userToken ?? ""]), success: { (jsonDict, fetchedData) in
            print("Session Login API Response: \(jsonDict)")
            if let codeValue = jsonDict["code"] as? String {
                switch codeValue {
                case "-1": failure(true, jsonDict["message"] as? String ?? "Session Expired")
                case "1": /// Success Login
                    do {
                        let loginDataDict = jsonDict["data"] as! [String:Any]
                        let loginDataDictData = try JSONSerialization.data(withJSONObject: loginDataDict, options: [])
                        parseLoginSignupData(FetchedData: loginDataDictData, success: { (pasrsingSuccess) in
                            success(true)
                        }, failure: { (error) in
                            failure(false, error.localizedDescription)
                        })
                    } catch let error {
                        failure(false, error.localizedDescription)
                    }
                default: failure(false, jsonDict["message"] as? String ?? "Session Expired")
                }
            } else { failure(false, jsonDict["message"] as? String ?? "Session Expired") }
        }) { (error) in
            failure(false, error.localizedDescription)
        }
    }
    
    //MARK: Get All Races
    class func wsGetAllTrackRacesTodayAndTomorrow(success: @escaping(Tracks?) -> Void, failure: @escaping(Bool, String?) -> Void) {
        let params: [String:String] = ["user_token": Global.LoggedUser?.userToken ?? ""]
        print("API Header: \(apiHeaderArray)")
        print("Get All Tracks API Param: \(params)")
        Functions.requestGetPostURLSession(APIType: .Post, APIURL: appGetAllTrackRaces, HeaderArray: apiHeaderArray, Parameters: Functions.getJSONParamAsString(With: params), success: { (jsonDict, fetchedData) in
            print("Get All Track Race API Response: \(jsonDict)")
            if let codeValue = jsonDict["code"] as? String {
                switch codeValue {
                case "1":
                    /// Success Case Get All Tracks
                    do {
                        let finalDataDict = jsonDict["data"] as! [String:Any]
                        let fData = try JSONSerialization.data(withJSONObject: finalDataDict, options: [])
                        do {
                            let gitData = try JSONDecoder().decode(Tracks.self, from: fData)
                            Global.recentPicksArray.removeAll()
                            Global.recentPicksArray = gitData.recentPicks ?? []
                            success(gitData)
                        } catch {
                            failure(false, error.localizedDescription)
                        }
                    } catch let error {
                        print("Errr ==> \(error.localizedDescription)")
                        failure(false, error.localizedDescription)
                    }
                case "-1": failure(true, jsonDict["message"] as? String ?? "Session Expired")
                default: failure(false, jsonDict["message"] as? String)
                }
            } else {
                failure(false, "No data Fetched. Please try again")
            }
        }) { (error) in
            failure(false, error.localizedDescription)
        }
    }
    
    //MARK: Get All Races in Track
    class func wsGetRacesOfTrackWith(TrackID id: String, For date: String, success: @escaping([Race]?) -> Void, failure: @escaping(Bool, String?) -> Void) {
        let params: [String:String] = [
            "user_token": Global.LoggedUser?.userToken ?? "",
            "track_id": id,
            "date": date
        ]
        print("Get Race of Tracks API Headers: \(apiHeaderArray)")
        print("Get Race of Tracks API Param: \(params)")
        
        Functions.requestGetPostURLSession(APIType: .Post, APIURL: appGetAllRacesForTrack, HeaderArray: apiHeaderArray, Parameters: Functions.getJSONParamAsString(With: params), success: { (jsonDict, fetchedData) in
            print("Get All Races of Track API Response: \(jsonDict)")
            if let codeValue = jsonDict["code"] as? String {
                switch codeValue {
                case "1":
                    /// Success Case Get All Tracks
                    do {
                        let finalDataDict = jsonDict["data"] as! [[String:Any]]
                        let fData = try JSONSerialization.data(withJSONObject: finalDataDict, options: [])
                        do {
                            let gitData = try JSONDecoder().decode([Race].self, from: fData)
                            success(gitData)
                        } catch {
                            failure(false, error.localizedDescription)
                        }
                    } catch let error {
                        print("Errr ==> \(error.localizedDescription)")
                        failure(false, error.localizedDescription)
                    }
                case "-1": failure(true, jsonDict["message"] as? String ?? "Session Expired")
                default: failure(false, jsonDict["message"] as? String)
                }
            } else {
                failure(false, "No data Fetched. Please try again")
            }
        }) { (error) in
            failure(false, error.localizedDescription)
        }
    }
}

//MARK:- Side Menu API
extension WebService {
    //MARK: Change Password
    class func wsAppChangePassword(OldPassword OP: String, NewPassword NP: String, success: @escaping(Bool, String) -> Void, failure: @escaping(Bool, String?) -> Void) {
        let params: [String:String] = [
            "user_token": Global.LoggedUser?.userToken ?? "",
            "old_password": OP,
            "password": NP,
            "password_confirmation": NP
        ]
        print("Change Password API HeaderArray: \(apiHeaderArray)")
        print("Change Password API Params: \(params)")
        
        Functions.requestGetPostURLSession(APIType: .Post, APIURL: appChangePassword, HeaderArray: apiHeaderArray, Parameters: Functions.getJSONParamAsString(With: params), success: { (jsonDict, fetchedData) in
            print("Change Password API Response: \(jsonDict)")
            if let codeValue = jsonDict["code"] as? String {
                switch codeValue {
                    case "1": success(true, jsonDict["message"] as? String ?? "Password Changed")
                    case "-1": failure(true, jsonDict["message"] as? String ?? "Session Expired")
                    default: failure(false, jsonDict["message"] as? String)
                }
            } else {
                failure(false, "No data Fetched. Please try again")
            }
        }) { (error) in
            failure(false, error.localizedDescription)
        }
    }
    
    //MARK: Get App Recent Wins
    class func wsAppGetAllWinnings(success: @escaping([Winning]) -> Void, failure: @escaping(Bool, String?) -> Void) {
        Functions.requestGetPostURLSession(APIType: .Get, APIURL: appGetAllWinnings, HeaderArray: apiHeaderArray, Parameters: "", success: { (jsonDict, fetchedData) in
            print("Get Recent Wins API Response: \(jsonDict)")
            if let codeValue = jsonDict["code"] as? String {
                switch codeValue {
                case "1":
                    do {
                        let finalDataDict = jsonDict["data"] as! [[String:Any]]
                        let fData = try JSONSerialization.data(withJSONObject: finalDataDict, options: [])
                        do {
                            let gitData = try JSONDecoder().decode([Winning].self, from: fData)
                            success(gitData)
                        } catch {
                            failure(false, error.localizedDescription)
                        }
                    } catch let error {
                        print("Errr ==> \(error.localizedDescription)")
                        failure(false, error.localizedDescription)
                    }
                case "-1": failure(true, jsonDict["message"] as? String ?? "Session Expired")
                default: failure(false, jsonDict["message"] as? String)
                }
            } else {
                failure(false, "No data Fetched. Please try again")
            }
        }) { (error) in
            failure(false, error.localizedDescription)
        }
    }
    
    //MARK: Edit Profile Image
    class func wsUpdateProfileInfoToServer(Name name: String, Email email: String, DOB dob: String, ImageData imgData: Data?, success: @escaping(Bool, String?, String?) -> Void, failure: @escaping(Bool, String?) -> Void) {
        let params: [String:String] = [
            "user_token": Global.LoggedUser?.userToken ?? "",
            "name": name,
            "email": email,
            "dob": dob
        ]
        print("Edit Profile API HeaderArray: \(apiHeaderArray)")
        print("Edit Profile API Params: \(params)")
        
        let headers: HTTPHeaders = [
            "Authorization": Functions.getAppAuthKey(),
            "Content-Type":"application/x-www-form-urlencoded"
        ]
        
        AF.upload (multipartFormData: { multipartFormData in
            for (key, value) in params {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
            if let imgData = imgData {
                multipartFormData.append(imgData, withName: "user_profile_image", fileName: "\(UUID().uuidString).jpg", mimeType: "image/jpeg")
            }
        }, to: appUpdateUserProfileData, method: .post , headers: headers).responseJSON { (response) in
            print(response)
            if response.error != nil {
                /// We've Error
                failure(false, response.error!.localizedDescription)
            } else {
                /// It's Success
                if let jsonDict = response.value as? [String:Any] {
                    if let codeValue = jsonDict["code"] as? String {
                        switch codeValue {
                            case "1":
                                if let jsonDictData = jsonDict["data"] as? [String:Any] {
                                    success(true, jsonDict["message"] as? String ?? "Password Changed", jsonDictData["user_profile_image_url"] as? String ?? nil)
                                } else { success(true, jsonDict["message"] as? String ?? "Password Changed", nil) }
                            
                            case "-1": failure(true, jsonDict["message"] as? String ?? "Session Expired")
                            default: failure(false, jsonDict["message"] as? String)
                        }
                    } else {
                        failure(false, jsonDict["message"] as? String)
                    }
                } else {
                    failure(false, "Error Getting Data")
                }
            }
        }
    }
    
    //MARK: Get Invite Screen API Details
    class func wsGetInviteScreenDetails(success: @escaping(InviteData) -> Void, failure: @escaping(Bool, String?) -> Void) {
        let params: [String:String] = [
            "user_token": Global.LoggedUser?.userToken ?? ""
        ]
        print("Invite Details API HeaderArray: \(apiHeaderArray)")
        print("Invite Details API Params: \(params)")
        
        Functions.requestGetPostURLSession(APIType: .Post, APIURL: appGetUserInviteDetails, HeaderArray: apiHeaderArray, Parameters: Functions.getJSONParamAsString(With: params), success: { (jsonDict, fetchedData) in
            print("Invite Details API Response: \(jsonDict)")
            if let codeValue = jsonDict["code"] as? String {
                switch codeValue {
                case "1":
                    /// Success Case Get All Tracks
                    do {
                        let finalDataDict = jsonDict["data"] as! [String:Any]
                        let fData = try JSONSerialization.data(withJSONObject: finalDataDict, options: [])
                        do {
                            let gitData = try JSONDecoder().decode(InviteData.self, from: fData)
                            success(gitData)
                        } catch {
                            failure(false, error.localizedDescription)
                        }
                    } catch let error {
                        print("Errr ==> \(error.localizedDescription)")
                        failure(false, error.localizedDescription)
                    }
                case "-1": failure(true, jsonDict["message"] as? String ?? "Session Expired")
                default: failure(false, jsonDict["message"] as? String)
                }
            } else {
                failure(false, "No data Fetched. Please try again")
            }
        }) { (error) in
            failure(false, error.localizedDescription)
        }
    }
    
    //MARK: Make Subscription Payment
    class func wsMakeSubscriptionPaymentToServerWithAddedCard(CardID cardID: String, SubscriptionID subsID: String, CouponID couponID: String, success: @escaping(Bool, String?) -> Void, failure: @escaping(Bool, String?) -> Void) {
        var paramDict:[String:String]?
        paramDict = [
            "user_token":Global.LoggedUser?.userToken ?? "",
            "subscription_id":subsID,
            "card_id": cardID,
            "user_code_id": couponID
        ]
        print("Make Payment API Params: \(paramDict ?? [:])")
        Functions.requestGetPostURLSession(APIType: .Post, APIURL: appMakeSubscriptionPayment, HeaderArray: apiHeaderArray, Parameters: Functions.getJSONParamAsString(With: paramDict ?? [:]), success: { (jsonDict, fetchedData) in
            print("Make Payment API Response: \(jsonDict)")
            if let codeValue = jsonDict["code"] as? String {
                switch codeValue {
                case "1": success(true, jsonDict["message"] as? String)
                case "-1": failure(true, jsonDict["message"] as? String ?? "Session Expired")
                default: failure(false, jsonDict["message"] as? String)
                }
            } else {
                failure(false, "No data Fetched. Please try again")
            }
        }) { (error) in
            failure(false, error.localizedDescription)
        }
    }
}

//MARK:- Payment Flow
extension WebService {
    //MARK: Update Card Added
    class func wsUpdateAddedCard(CardID cardID: String, ExpMonth EM: String, ExpYear EY: String, Name name: String, success: @escaping(Bool, String?) -> Void, failure: @escaping(Bool, String?) -> Void) {
        let params: [String:String] = [
            "user_token": Global.LoggedUser?.userToken ?? "",
            "card_id": cardID,
            "card_exp_month": EM,
            "card_exp_year": EY,
            "name": name
        ]
        
        print("Update Added Card API HeaderArray: \(apiHeaderArray)")
        print("Update Added Card API Params: \(params)")
        
        Functions.requestGetPostURLSession(APIType: .Post, APIURL: appEditCreditCard, HeaderArray: apiHeaderArray, Parameters: Functions.getJSONParamAsString(With: params), success: { (jsonDict, fetchedData) in
            print("Update Added Card API Response: \(jsonDict)")
            if let codeValue = jsonDict["code"] as? String {
                switch codeValue {
                case "1": success(true, jsonDict["message"] as? String ?? "Success")
                case "-1": failure(true, jsonDict["message"] as? String ?? "Session Expired")
                default: failure(false, jsonDict["message"] as? String)
                }
            } else {
                failure(false, "No data Fetched. Please try again")
            }
        }) { (error) in
            failure(false, error.localizedDescription)
        }
    }
    
    //MARK: Get Subscription Price With Signup Discount
    class func wsGetSignupCodeDiscountedAmount(SubscriptionID subID: String,success: @escaping(SignupDiscount) -> Void, failure: @escaping(Bool, String?) -> Void) {
        let params: [String:String] = [
            "user_token": Global.LoggedUser?.userToken ?? "",
            "subscription_id": subID
        ]
        
        print("Get Discounted Amount By Signup Screen API HeaderArray: \(apiHeaderArray)")
        print("Get Discounted Amount By Signup Screen API Params: \(params)")
        
        Functions.requestGetPostURLSession(APIType: .Post, APIURL: appShowSubsPrice, HeaderArray: apiHeaderArray, Parameters: Functions.getJSONParamAsString(With: params), success: { (jsonDict, fetchedData) in
            print("Get Discounted Amount By Signup Screen API Response: \(jsonDict)")
            if let codeValue = jsonDict["code"] as? String {
                switch codeValue {
                case "1":
                    if let dataValue = jsonDict["data"] as? [String:Any] {
                        success(SignupDiscount(WithJSON: dataValue))
                    } else {
                        failure(false, jsonDict["message"] as? String)
                    }
                case "-1": failure(true, jsonDict["message"] as? String ?? "Session Expired")
                default: failure(false, jsonDict["message"] as? String)
                }
            } else {
                failure(false, "No data Fetched. Please try again")
            }
        }) { (error) in
            failure(false, error.localizedDescription)
        }
    }
    
    //MARK: Get All Cards Added
    class func wsGetAllCardsAdded(success: @escaping([CreditCard]) -> Void, failure: @escaping(Bool, String?) -> Void) {
        let params: [String:String] = [
            "user_token": Global.LoggedUser?.userToken ?? ""
        ]
        print("Get All Cards API HeaderArray: \(apiHeaderArray)")
        print("Get All Cards API Params: \(params)")
        
        Functions.requestGetPostURLSession(APIType: .Post, APIURL: appGetAllCardsAdded, HeaderArray: apiHeaderArray, Parameters: Functions.getJSONParamAsString(With: params), success: { (jsonDict, fetchedData) in
            print("Get All Cards API Response: \(jsonDict)")
            if let codeValue = jsonDict["code"] as? String {
                switch codeValue {
                case "1":
                    do {
                        let finalDataDict = jsonDict["data"] as! [[String:Any]]
                        let fData = try JSONSerialization.data(withJSONObject: finalDataDict, options: [])
                        do {
                            let gitData = try JSONDecoder().decode([CreditCard].self, from: fData)
                            success(gitData)
                        } catch {
                            failure(false, error.localizedDescription)
                        }
                    } catch let error {
                        print("Errr ==> \(error.localizedDescription)")
                        failure(false, error.localizedDescription)
                    }
                case "-1": failure(true, jsonDict["message"] as? String ?? "Session Expired")
                default: failure(false, jsonDict["message"] as? String)
                }
            } else {
                failure(false, "No data Fetched. Please try again")
            }
        }) { (error) in
            failure(false, error.localizedDescription)
        }
    }
    
    //MARK: Cancel Subscription Request
    class func wsCancelAutoRenewalSubscriptionRequest(success: @escaping(Bool, String) -> Void, failure: @escaping(Bool, String?) -> Void) {
        let params: [String:String] = [
            "user_token": Global.LoggedUser?.userToken ?? ""
        ]
        print("Cancel Subscription API HeaderArray: \(apiHeaderArray)")
        print("Cancel Subscription API Params: \(params)")
        
        Functions.requestGetPostURLSession(APIType: .Post, APIURL: appCancelCurrentSubscription, HeaderArray: apiHeaderArray, Parameters: Functions.getJSONParamAsString(With: params), success: { (jsonDict, fetchedData) in
            print("Cancel Subscription API Response: \(jsonDict)")
            if let codeValue = jsonDict["code"] as? String {
                switch codeValue {
                case "1": success(true, jsonDict["message"] as? String ?? "")
                case "-1": failure(true, jsonDict["message"] as? String ?? "Session Expired")
                default: failure(false, jsonDict["message"] as? String)
                }
            } else {
                failure(false, "No data Fetched. Please try again")
            }
        }) { (error) in
            failure(false, error.localizedDescription)
        }
    }
    
    //MARK: Make Subscription Payment
    class func wsMakeSubscriptionPaymentToServer(STPToken stToken: String?, SaveCard saveCard: Bool, SubscriptionID subsID: String, CardID cardID: String?, success: @escaping(Bool, String?) -> Void, failure: @escaping(Bool, String?) -> Void) {
        var paramDict:[String:String]?
        paramDict = [
            "user_token":Global.LoggedUser?.userToken ?? "",
            "save_card":saveCard == true ? ("1") : ("0"),
            "stripe_token":stToken == nil ? ("") : (stToken!),
            "subscription_id":subsID,
            "card_id":cardID == nil ? ("") : (cardID!)
        ]
        print("Make Payment API Params: \(paramDict ?? [:])")
        Functions.requestGetPostURLSession(APIType: .Post, APIURL: appMakeSubscriptionPayment, HeaderArray: apiHeaderArray, Parameters: Functions.getJSONParamAsString(With: paramDict ?? [:]), success: { (jsonDict, fetchedData) in
            print("Make Payment API Response: \(jsonDict)")
            if let codeValue = jsonDict["code"] as? String {
                switch codeValue {
                case "1": success(true, jsonDict["message"] as? String)
                case "-1": failure(true, jsonDict["message"] as? String ?? "Session Expired")
                default: failure(false, jsonDict["message"] as? String)
                }
            } else {
                failure(false, "No data Fetched. Please try again")
            }
        }) { (error) in
            failure(false, error.localizedDescription)
        }
    }
    
    //MARK: Add New Card
    class func wsAddNewStripeCard(STPToken stToken: String?, success: @escaping(Bool, String?) -> Void, failure: @escaping(Bool, String?) -> Void) {
        var paramDict:[String:String]?
        paramDict = [
            "user_token":Global.LoggedUser?.userToken ?? "",
            "stripe_token":stToken == nil ? ("") : (stToken!)
        ]
        print("Add New Card API Params: \(paramDict ?? [:])")
        Functions.requestGetPostURLSession(APIType: .Post, APIURL: appAddNewCard, HeaderArray: apiHeaderArray, Parameters: Functions.getJSONParamAsString(With: paramDict ?? [:]), success: { (jsonDict, fetchedData) in
            print("Add New Card API Response: \(jsonDict)")
            if let codeValue = jsonDict["code"] as? String {
                switch codeValue {
                case "1": success(true, jsonDict["message"] as? String)
                case "-1": failure(true, jsonDict["message"] as? String ?? "Session Expired")
                default: failure(false, jsonDict["message"] as? String)
                }
            } else {
                failure(false, "No data Fetched. Please try again")
            }
        }) { (error) in
            failure(false, error.localizedDescription)
        }
    }
    
    //MARK: Delete Added Card
    class func wsDeleteAddedCard(CardID cardID: String, success: @escaping(Bool, String?) -> Void, failure: @escaping(Bool, String?) -> Void) {
        var paramDict:[String:String]?
        paramDict = [
            "user_token":Global.LoggedUser?.userToken ?? "",
            "card_id": cardID
        ]
        print("Delete New Card API Params: \(paramDict ?? [:])")
        Functions.requestGetPostURLSession(APIType: .Post, APIURL: appDeleteAddedCard, HeaderArray: apiHeaderArray, Parameters: Functions.getJSONParamAsString(With: paramDict ?? [:]), success: { (jsonDict, fetchedData) in
            print("Delete New Card API Response: \(jsonDict)")
            if let codeValue = jsonDict["code"] as? String {
                switch codeValue {
                case "1": success(true, jsonDict["message"] as? String)
                case "-1": failure(true, jsonDict["message"] as? String ?? "Session Expired")
                default: failure(false, jsonDict["message"] as? String)
                }
            } else {
                failure(false, "No data Fetched. Please try again")
            }
        }) { (error) in
            failure(false, error.localizedDescription)
        }
    }
    
    //MARK: Verify Coupon Code
    class func wsVerifyAppCouponCode(CouponID couponID: String, SubscriptionID subID: String, success: @escaping(Bool, String?, String) -> Void, failure: @escaping(Bool, String?) -> Void) {
        var paramDict:[String:String]?
        paramDict = [
            "user_token":Global.LoggedUser?.userToken ?? "",
            "code_id": couponID,
            "subscription_id": subID
        ]
        print("Verify Coupon Code API Params: \(paramDict ?? [:])")
        Functions.requestGetPostURLSession(APIType: .Post, APIURL: appVerifyCouponCode, HeaderArray: apiHeaderArray, Parameters: Functions.getJSONParamAsString(With: paramDict ?? [:]), success: { (jsonDict, fetchedData) in
            print("Verify Coupon Code API Response: \(jsonDict)")
            if let codeValue = jsonDict["code"] as? String {
                switch codeValue {
                case "1":
                    if let dataDict = jsonDict["data"] as? [String:Any] {
                        success(true, jsonDict["message"] as? String, Functions.getStringValueForNum(dataDict["amount"] as Any))
                    } else {
                        success(false, jsonDict["message"] as? String, "")
                    }
                case "-1": failure(true, jsonDict["message"] as? String ?? "Session Expired")
                default: failure(false, jsonDict["message"] as? String)
                }
            } else {
                failure(false, "No data Fetched. Please try again")
            }
        }) { (error) in
            failure(false, error.localizedDescription)
        }
    }
}
