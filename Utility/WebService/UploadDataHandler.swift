//
//  UploadDataHandler.swift
//  ThrillingPicks
//
//  Created by iOSDev on 6/6/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit
import Alamofire

//MARK:- Upload Status - Protocol
/**
 This Protocol is used to get the required data from Upload Data class
 */
protocol uploadDataProtocol {
    //MARK: Get Uploading progress
    /**
     This Function is used to check how much percent of file is Uploaded to server
     - parameter progress : Progress Status in Double
     */
    func finalProgressStatus(progress:Double)
}

//MARK: Networking Class
class Networking {
    static let sharedInstance = Networking()
    public var sessionManager: Alamofire.Session // most of your web service clients will call through sessionManager
    public var backgroundSessionManager: Alamofire.Session // your web services you intend to keep running when the system backgrounds your app will use this
    
    private init() {
        self.sessionManager = Alamofire.Session(configuration: URLSessionConfiguration.default)
        self.backgroundSessionManager = Alamofire.Session(configuration: URLSessionConfiguration.background(withIdentifier: "com.myApp.backgroundtransfer"))
    }
}

//MARK:- Background Upload Audio
/**
 This Class is used to Upload a type of File to server and Types Supported Are:
 - Video: video/mov
 - PDF: application/pdf
 - Image: image/jpeg
 - Audio Flac: audio/flac
 */
class UploadMultipartClient {
    /// Uploaded Data Protocol
    static var delegate : uploadDataProtocol?
    
    //MARK: Upload File Handler
    /**
     This Function is used to upload a file on server
     - parameter serverURL : This is the URL on which a File is to be uploaded
     - parameter parameters : Parameteres that need to be attached with Data
     - parameter fileData : This is Data format of file to be uploaded
     - parameter filename : Name of File to be uploaded With File type **UUID().uuidString.mp4**
     - parameter mimeType : Mime of File to be Uploaded Check in Class Description
     - parameter success : Success Block returns true if data is successfully uploaded else false
     - parameter failure : failure block returns Error if uploading fails
     */
    class func uploadImage(APIURL serverURL: URL,Parameters parameters: [String : AnyObject]?, Headers header: [String:String] , ConvertedData fileData: Data?, FileName filename: String, Mime mimeType: String, success:@escaping ([String:Any]) -> Void, failure:@escaping (Error) -> Void) {
//        var headers = header
//        var newHeaders : HTTPHeader = []
//        for (key, value) in header {
//            newHeaders[key] =
//        }
//        headers.updateValue("multipart/form-data", forKey: "Content-Type")
//        print(headers)
//        let multidata = MultipartFormData()
//        if fileData != nil {
//            multidata.append(fileData!, withName: "image", fileName: filename, mimeType: mimeType)
//        }
//        if parameters != nil {
//            for (key, value) in parameters! {
//                multidata.append(value.data(using: String.Encoding.utf8.rawValue)!, withName: key)
//            }
//        }
//        Networking.sharedInstance.backgroundSessionManager.upload(multipartFormData: { (multipartFormData) in
//            if fileData != nil {
//                multipartFormData.append(fileData!, withName: "image", fileName: filename, mimeType: mimeType)
//            }
//            if parameters != nil {
//                for (key, value) in parameters! {
//                    multipartFormData.append(value.data(using: String.Encoding.utf8.rawValue)!, withName: key)
//                }
//            }
//        }, to: serverURL, method: .post, headers: nil) { (encodingResult) in
        
//        }
    }
}
