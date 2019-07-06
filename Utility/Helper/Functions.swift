//
//  Functions.swift
//  ThrillingPicks
//
//  Created by iOSDev on 5/20/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

//MARK: Date Formatter Types
/**
  Formats Used in App to show Date as String
 */
enum DateFormatterType: String {
    case HHMMSS = "HH:mm:ss"
    case HHMMA = "HH:mm a"
    case HHMM = "HH:mm"
    case YYYYMMDD = "yyyy-MM-dd"
    case DDMMYYYY = "dd-MM-yyyy"
    case MMDDYYYY = "MM-dd-yyyy"
    case SMMDDYYYY = "MM/dd/yyyy"
    case DDM = "dd/MM"
    case YYYYMMDDHHMMSS = "yyyy-MM-dd HH:mm:ss"
    case DDDDMMDDYY = "EEEE, MMM dd yyyy"
    case EEDDYYYY = "EEEE dd, yyyy"
}

//MARK: Date Extension
/**
 Extending Date
 */
extension Date {
    //MARK: Get Date As String
    /**
     This Function is used to format the date into Defined Format String.
     - parameter format : Desired Format in which date will be converted down.
     - returns:  Return The Date in formatted Desired format.
     */
    func getDateFormattedInString(of format: DateFormatterType) -> String {
        var df : DateFormatter?
        df = DateFormatter()
        df?.dateFormat = format.rawValue
        return df?.string(from: self) ?? ""
    }
}

class Functions: NSObject {
    /// Activity Indicator
    private var indicatorView : UIActivityIndicatorView?
    /// Shared object
    static var shared = Functions()
    /// Activity Indicator
    private var activityIndicator : UIActivityIndicatorView?
    /// Indicator Label Text
    private var strLabel : UILabel?
    /// Base View Blurred
    private var blurView : UIView?
    /// Background View for effectView
    private var baseWhiteView : UIView?
    /// Effect View
    private let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    /// Check if its iPad
    static var iPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    //MARK: Get String Value From JSON Val
    /**
     This Function is used to format the date into Defined Format String.
     - parameter value : Desired Format in which date will be converted down.
     - returns:  Return String Format of JSON Param Value
     */
    class func getStringValueForNum(_ value: Any) -> String {
        if let castedValue = value as? String {
            return castedValue
        } else {
            if let castedValue = value as? Int {
                return String(castedValue)
            } else{
                if let castedValue = value as? NSNumber {
                    return "\(castedValue)"
                } else { return "" }
            }
        }
    }
}

//MARK:- Login Related Functions
extension Functions {
    //MARK: Logout User
    /**
     This Function is used to logout user from any controller
     - parameter navController : Root Navigation Controller Reference.
     */
    class func logoutUser(With navController: UINavigationController?) {
        UserDefaults.standard.removeObject(forKey: loggedUserKey)
        UserDefaults.standard.synchronize()
        for controller in (navController?.viewControllers ?? []) as Array {
            if controller.isKind(of: SignInVC.self) {
                let newVC = NewGuestPassVC.instantiateFromStoryboard(storyboard: mainStoryBoard)
                navController?.setViewControllers([newVC, controller], animated: false)
                break
            } else {
                let vc = mainStoryBoard.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
                let newVC = NewGuestPassVC.instantiateFromStoryboard(storyboard: mainStoryBoard)
                navController?.setViewControllers([newVC, vc], animated: true)
                break
            }
        }
    }
}

//MARK:- Other Funtions
extension Functions {
    //MARK: Remove Social Struct values
    /**
     This Function is used to clear all the values in Struct Used.
     */
    class func removeSocialStruct() {
        SocialUser.socialID = nil
        SocialUser.firstName = nil
        SocialUser.lastName = nil
        SocialUser.fullName = nil
        SocialUser.email = nil
        SocialUser.socialMediaPlatformName = nil
    }
    
    //MARK: Naviagte To Further screens
    /**
     This Function Handle the Login Flow For App.
     After Login where user should go ? To Subscription Screen or Direct Home Screen
     - parameter navController : Root Navigation Controller Reference.
     */
    class func homeFlowHanlder(With navController: UINavigationController?) {
        guard let clUser = Global.LoggedUser else {
            print("No User is logged in. Control wasn't meant to reach here")
            return
        }
        if !(clUser.userSubscriptionEndDate ?? "").trimmed().isEmpty {
            /// We've subscription End Date
            /// Check is End Date less than current Date
            if Functions.getDateFrom(DateString: clUser.userSubscriptionEndDate!, With: .YYYYMMDD) < Date() {
                /// End Date is less than Navigate to Subscription End Date
                let vc = SubscriptionListVC.instantiateFromStoryboard(storyboard: homeStoryBoard)
                vc.isLoginFlow = true
                navController?.pushViewController(vc, animated: true)
            } else {
                /// Woah! it's paid user. let's go to Home screen
                navController?.pushViewController(BaseHomeVC.instantiateFromStoryboard(storyboard: homeStoryBoard), animated: true)
            }
        } else {
            /// We've no subscription Date
            let vc = SubscriptionListVC.instantiateFromStoryboard(storyboard: homeStoryBoard)
            vc.isLoginFlow = true
            navController?.pushViewController(vc, animated: true)
        }
    }
}

//MARK:- API Functions
extension Functions {
    //MARK: URL Session - Get/Post Method
    /**
     This Function is used to get response from API with GET
     - parameter strURL : URL that is to be Hitted
     - parameter params : Parameters That need to be send along API
     - parameter success : This Block Returns Value if response Received from API
     - parameter failure : This Block Returns Value if no response Received from API
     */
    class func requestGetPostURLSession (APIType type: APIType, APIURL strURL : String, HeaderArray headers: [String:String], Parameters params : String, success:@escaping ([String:Any], Data) -> Void, failure:@escaping (Error) -> Void) {
        let urlwithPercentEscapes = strURL.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let postData = NSMutableData(data: params.data(using: String.Encoding.utf8)!)
        let request = NSMutableURLRequest(url: NSURL(string: urlwithPercentEscapes!)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 60.0)
        type == .Post ? (request.httpMethod = "POST") : (request.httpMethod = "GET")
        if headers.count > 0 {
            for (key,value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        request.httpBody = postData as Data
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard let data = data, error == nil else {
                OperationQueue.main.addOperation() {
                    failure(error! as Error)
                }
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                OperationQueue.main.addOperation() {
                    if error == nil {
                        failure(NSError(domain:"", code:httpStatus.statusCode, userInfo:nil) as Error)
                    } else { failure(error! as Error) }
                }
            }
            
            /// Data Successfully Fetched
            do {
                var jsonDict : [String:Any]?
                jsonDict = [String:Any]()
                jsonDict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]
                OperationQueue.main.addOperation() {
                    success(jsonDict!, data)
                }
            }
            catch let error {
                OperationQueue.main.addOperation() {
                    failure(error)
                }
            }
        })
        task.resume()
    }
    
    // MARK: Get JSON Param String Format
    /**
     This Function is used to combine the dictionary param as String
     - parameter paramDict : Dictionary which need to be comb4ined
     - returns: String Repersentation of JSON API Params
     */
    class func getJSONParamAsString(With paramDict: [String: String]) -> String {
        var finalParamString: String=""
        for (key,value) in paramDict {
            if finalParamString.trimmed().count == 0 {
                finalParamString="&\(key)=\(value)"
            } else {
                finalParamString=finalParamString+"&\(key)=\(value)"
            }
        }
        return finalParamString
    }
    
    // MARK: Get JSON Param String Format
    /**
     This Function is used to get the Auth Key For Logged in USER. which
     is MD5 Security Encryption Repersentation of AppKey & Date()
     - returns: App Authorization Key
     */
    class func getAppAuthKey() -> String {
        return "0742c4383c7226f51a68c255e628367a\(self.getDateFormatted(Date: Date(), In: .YYYYMMDD).md5 ?? "")".md5
    }
}

//MARK:- Permission Handlers
extension Functions {
    //MARK: Check For Camera Permission
    /**
     This Function is used to check the permission for Camera Access - Video Type
     - Parameter success: The callback called after retrieval.
     - Parameter Bool: Returns Permission Granted or not.
     */
    class func checkForCameraPermission(success:@escaping (Bool) -> Void){
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized { success(true) }
        else if AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined {
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                success(response)
            }
        } else { success(false) }
    }
    
    //MARK: Check for photos App Permission
    /**
     This Function is used to check and ask permission for Photos App Access
     - Parameter success: The callback called after retrieval.
     - Parameter Bool: Returns Permission Granted or not.
     */
    class func checkForGalleryPermission(success:@escaping (Bool) -> Void) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            success(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({status in
                status == .authorized ? (success(true)) : (success(false))
            })
        default: success(false)
        }
    }
}

//MARK:- Date Functions
extension Functions {
    //MARK: Get DateString Formatted From Date
    class func getDateFormatted(Date date: Date, In format: DateFormatterType) -> String {
        var df : DateFormatter?
        df = DateFormatter()
        df?.dateFormat = format.rawValue
        return df?.string(from: date) ?? ""
    }
    
    //MARK: Get Date From DateString
    class func getDateFrom(DateString date: String, With format: DateFormatterType) -> Date {
        var df : DateFormatter?
        df = DateFormatter()
        df?.dateFormat = format.rawValue
        return df!.date(from: date) ?? Date()
    }
}

//MARK:- Spinner Functions
extension Functions {
    //MARK: Show Spinner
    /**
     This Function is used to Show Spinner
     - parameter title : Title for the label to be Displayed
     - parameter view : ViewController in which Spinner is to be added
     */
    func showActivityIndicator(_ title: String,view:UIViewController) {
        strLabel?.removeFromSuperview()
        strLabel = UILabel()
        activityIndicator?.removeFromSuperview()
        activityIndicator = UIActivityIndicatorView()
        blurView?.removeFromSuperview()
        blurView = UIView()
        baseWhiteView?.removeFromSuperview()
        baseWhiteView = UIView()
        effectView.removeFromSuperview()
        
        blurView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        blurView?.backgroundColor = .black
        blurView?.alpha = 0.4
        view.view.addSubview(blurView!)
        let width = self.getLabelWidth(title)
        strLabel = UILabel(frame: CGRect(x: 40, y: 0, width: width+20, height: 46))
        strLabel?.text = ""
        strLabel?.text = title
        strLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        strLabel?.textColor = UIColor.black
        
        effectView.frame = CGRect(x: view.view.frame.midX - ((width+50)/2), y: view.view.frame.midY - (strLabel?.frame.height)!/2 , width: width+50, height: 46)
        effectView.layer.cornerRadius = 15
        effectView.layer.masksToBounds = true
        
        baseWhiteView?.frame = effectView.frame
        baseWhiteView?.backgroundColor = UIColor.white
        baseWhiteView?.layer.shadowColor = UIColor.white.cgColor
        baseWhiteView?.layer.shadowOpacity = 1
        baseWhiteView?.layer.masksToBounds = false
        baseWhiteView?.clipsToBounds = false
        baseWhiteView?.layer.shadowOffset = CGSize(width: 0, height: 0)
        baseWhiteView?.layer.shadowRadius = 3
        baseWhiteView?.layer.cornerRadius = 15
        
        activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator?.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
        activityIndicator?.startAnimating()
        
        effectView.contentView.addSubview(activityIndicator!)
        effectView.contentView.addSubview(strLabel!)
        view.view.addSubview(baseWhiteView!)
        view.view.addSubview(effectView)
        view.view.bringSubviewToFront(effectView)
        
        if let topMostController = UIApplication.shared.windows[0].rootViewController {
            topMostController.view.isUserInteractionEnabled = false
        }
    }
    
    //MARK: Hide Spinner
    /**
     This Function is used to Hide Running Spinner and remove the Added Views
     */
    func hideActivityIndicator() {
        strLabel?.removeFromSuperview()
        activityIndicator?.removeFromSuperview()
        effectView.removeFromSuperview()
        blurView?.removeFromSuperview()
        baseWhiteView?.removeFromSuperview()
        strLabel = nil
        activityIndicator = nil
        blurView = nil
        baseWhiteView = nil
        
        if let topMostController = UIApplication.shared.windows[0].rootViewController {
            topMostController.view.isUserInteractionEnabled = true
        }
    }
    
    //MARK: Get Label Width
    /**
     This Function is used to get the maximum possible width a label can have with
     input text
     */
    func getLabelWidth(_ message: String) -> CGFloat{
        let label : UILabel = UILabel()
        label.text = message
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label.intrinsicContentSize.width
    }
    
    //MARK: Change LoaderView Text
    /**
     This Function is used to change the Loader text being Displayed
     - parameter message: Text to be displayed in Label
     - parameter view: Controller in which Loader is Being currently Dispalyed
     */
    func changeLoaderLabelText(_ message: String,_ view:UIViewController){
        let width = getLabelWidth(message)
        strLabel?.frame.size.width = width+20
        strLabel?.text = message
        effectView.frame = CGRect(x: view.view.frame.midX - ((width+50)/2), y: view.view.frame.midY - (strLabel?.frame.height)!/2 , width: width+50, height: 46)
        baseWhiteView?.frame = effectView.frame
        baseWhiteView?.setNeedsDisplay()
        effectView.setNeedsDisplay()
    }
}
