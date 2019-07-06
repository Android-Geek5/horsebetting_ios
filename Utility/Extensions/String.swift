//
//  String.swift
//  ThrillingPicks
//
//  Created by iOSDev on 5/8/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit
import CommonCrypto

extension UITextField {
    //MARK: Trimmed UITextField String
    func trimmed() -> String {
        return (self.text ?? "").trimmed()
    }
    
    //MARK: Check only characters
    func hasOnlyCharacters() -> Bool {
        let regex = try! NSRegularExpression(pattern: "[0-9 a-zA-Z\\s]+", options: [])
        let range = regex.rangeOfFirstMatch(in: (self.text ?? "").trimmed(), options: [], range: NSRange(location: 0, length: (self.text ?? "").trimmed().count))
        return range.length == (self.text ?? "").trimmed().count
    }
    
    func checkContainNumber() -> Bool {
        let decimalCharacters = CharacterSet.decimalDigits
        let decimalRange = self.trimmed().rangeOfCharacter(from: decimalCharacters)
        return decimalRange != nil ? (true) : (false)
    }
    
    func setRightAccessoryView(ImageName imgName: UIImage) {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        imageView.image = imgName
        imageView.contentMode = .scaleAspectFit
        self.rightViewMode = .always
        self.rightView = imageView
    }
    
}

extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}


extension String {
    /// HTML To Attributed String
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    
    /// Normal String
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
    
    /// Genrate MD5 From String
    var md5: String! {
        let str = cString(using: String.Encoding.utf8)
        let strLen = CC_LONG(lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        return String(format: hash as String).lowercased()
    }
    
    //MARK: Trimmed String
    func trimmed() -> String {
        return self.trimmingCharacters(in: .whitespaces)
    }
    
    //MARK: Is Valid E-Mail
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    //MARK: Check only characters
    func checkOnlyCharacters() -> Bool {
        let regex = try! NSRegularExpression(pattern: "[a-zA-Z\\s]+", options: [])
        let range = regex.rangeOfFirstMatch(in: self, options: [], range: NSRange(location: 0, length: self.count))
        return range.length == self.count
    }
    
    //MARK: Inser Char after every N Char
    func inserting(separator: String, every n: Int) -> String {
        var result: String = ""
        let characters = Array(self)
        stride(from: 0, to: characters.count, by: n).forEach {
            result += String(characters[$0..<min($0+n, characters.count)])
            if $0+n < characters.count {
                result += separator
            }
        }
        return result
    }
}
