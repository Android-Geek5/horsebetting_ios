//
//  UIView.swift
//  ThrillingPicks
//
//  Created by iOSDev on 5/8/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit

extension UIView {
    //MARK: Add Shadow To View
    func addShadowToView(ShadowColor color:UIColor, Opacity opacity: Float, Radius radii: CGFloat, Size size: CGSize) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.masksToBounds = false
        self.clipsToBounds = false
        self.layer.shadowOffset = size
        self.layer.shadowRadius = radii
    }
    
    //MARK: Add Border To View
    func addBorderToView(Radius radii: CGFloat, Color color: UIColor) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = radii
    }
    
    //MARK: Round Corner Views
    func roundWithRadious(Radius radious: CGFloat) {
        self.layer.cornerRadius = radious
        self.layer.masksToBounds = true
    }
}
