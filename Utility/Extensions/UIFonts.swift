//
//  UIFonts.swift
//  ThrillingPicks
//
//  Created by iOSDev on 5/30/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit

extension UIFont {
    // MARK: Poppins Medium
    class func poppinsMediumWith(Size size: CGFloat) -> UIFont {
        return UIFont(name: "Poppins-Medium", size: size)!
    }
    
    // MARK: Poppins Medium
    class func poppinsRegularWith(Size size: CGFloat) -> UIFont {
        return UIFont(name: "Poppins-Regular", size: size)!
    }
    
    // MARK: Poppins Bold
    class func poppinsBoldWith(Size size: CGFloat) -> UIFont {
        return UIFont(name: "Poppins-Bold", size: size)!
    }
    
    // MARK: Poppins Semi Bold
    class func poppinsSemiBoldWith(Size size: CGFloat) -> UIFont {
        return UIFont(name: "Poppins-SemiBold", size: size)!
    }
    
    // MARK: Poppins Italic
    class func poppinsItalicWith(Size size: CGFloat) -> UIFont {
        return UIFont(name: "Poppins-Italic", size: size)!
    }
}
