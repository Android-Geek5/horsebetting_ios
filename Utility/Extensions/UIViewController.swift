//
//  UIViewController.swift
//  ThrillingPicks
//
//  Created by iOSDeveloper on 5/8/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit

protocol StoryboardInstantiable: class {
    /// Storyboard Identifier
    static var storyboardIdentifier: String {get}
    /// Initiate Controller
    static func instantiateFromStoryboard(storyboard: UIStoryboard) -> Self
}

extension UIViewController: StoryboardInstantiable {
    //MARK: Add Subview in Side Menu view
    func add(asChildViewController viewController: UIViewController, baseView: UIView) {
        viewController.view.frame = CGRect(x: 0, y: 0, width: baseView.frame.size.width, height: baseView.frame.size.height)
        addChild(viewController)
        viewController.view.translatesAutoresizingMaskIntoConstraints = true
        baseView.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
    
    //MARK: Remove Subview from Side Menu view
    func remove(asChildViewController viewController: UIViewController, baseView: UIView) {
        viewController.willMove(toParent: nil)
        baseView.willRemoveSubview(viewController.view)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
    
    /// Get Storyboard Identifier
    static var storyboardIdentifier: String {
        // Get the name of current class
        let classString = NSStringFromClass(self)
        let components = classString.components(separatedBy: ".")
        assert(components.count > 0, "Failed extract class name from \(classString)")
        return components.last!
    }
    
    //MARK: Initiate From Storyboard
    class func instantiateFromStoryboard(storyboard: UIStoryboard) -> Self {
        return instantiateFromStoryboard(storyboard: storyboard, type: self)
    }
    
    //MARK: Get Controller From StoryBoard
    private class func instantiateFromStoryboard<T: UIViewController>(storyboard: UIStoryboard, type: T.Type) -> T {
        return storyboard.instantiateViewController(withIdentifier: self.storyboardIdentifier) as! T
    }
    
    //MARK: Show Common Alert
    func showAlert(AlertTitle title: String, AlertMessage message: String) {
        let alert = UIAlertController(title:title, message:  message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: Show Common Alert
    func showAlertWithCompletion(AlertTitle title: String, AlertMessage message: String, completed: @escaping(Bool) -> Void) {
        let alert = UIAlertController(title:title, message:  message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true) {
            completed(true)
        }
    }
    
    //MARK: Alert with One Action 
    func showAlertWithOneAction(AlertTitle title: String, AlertMessage message: String, ActionTitle actionTitle: String, success: @escaping(Bool) -> Void) {
        let alert = UIAlertController(title:title, message:  message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action) in
            success(true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: Enable Swipe Pop Gesture
    func enablePopNavGesture() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled=true
        self.navigationController?.interactivePopGestureRecognizer?.delegate=nil
    }
    
    //MARK: Disable Swipe Pop Gesture
    func disablePopNavGesture() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled=false
    }
}
