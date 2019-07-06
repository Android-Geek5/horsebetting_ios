//
//  BaseHomeVC.swift
//  ThrillingPicks
//
//  Created by iOSDev on 5/28/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit

class BaseHomeVC: UIViewController, HomeVCProtocol {
    
    ///BaseView i.e Side Menu View
    fileprivate var baseView = UIView()
    ///Extended View
    fileprivate var exView = UIView()
    ///Blur View
    fileprivate var blurView = UIVisualEffectView()
    ///Maximum y that let Side Menu View to move to maximum position
    fileprivate var maximum_x = CGFloat()
    /// Orignal Frame Ref
    fileprivate var orignalFrameForDraggableView : CGRect!
    /// Main Home Screen Obj Ref
    fileprivate var mainHomeScreenObj: MainHomeVC?
    
    /// Side Menu Object
    private lazy var sideMenuVCObject: SideMenuVC = {
        let vc = homeStoryBoard.instantiateViewController(withIdentifier: "SideMenuVC") as! SideMenuVC
        vc.delegate = self
        self.addChild(vc)
        return vc
    }()
}

//MARK:- View Life Cycles
extension BaseHomeVC {
    //MARK: Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: View Did Appear
    override func viewDidAppear(_ animated: Bool) {
        addExtendedView()
    }
    
    //MARK: Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeScreenView" {
            let embedVC = segue.destination as! UINavigationController
            mainHomeScreenObj = embedVC.viewControllers.first as? MainHomeVC
            mainHomeScreenObj?.delegate = self
        }
    }
    
    //MARK: SIde Menu Expander/Collapsser Handler
    func sideMenuBtnPressed(Status isSelected: Bool) {
        print(isSelected)
        isSelected ? (showSideMenu()) : (hideSideMenu())
    }
}

//MARK:- Side Menu VC Delegate
extension BaseHomeVC: SideMenuVCProtocol {
    //MARK: Clicked Side Menu Account Option
    func clickedMyAccountOption(Option option: MyAccountOptions) {
        self.hideSideMenu()
        switch option {
            case .logout:
                Functions.shared.showActivityIndicator("Loading", view: self)
                WebService.wsLogoutUser(success: { (logout, msg) in
                    Functions.shared.hideActivityIndicator()
                    Functions.logoutUser(With: self.navigationController)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        if !(msg ?? "").trimmed().isEmpty {
                            self.showAlert(AlertTitle: TAppName, AlertMessage: msg!)
                        }
                    })
                }) { (logoutBool, errorMsg) in
                    Functions.shared.hideActivityIndicator()
                    Functions.logoutUser(With: self.navigationController)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        if !(errorMsg ?? "").trimmed().isEmpty {
                            self.showAlert(AlertTitle: TAppName, AlertMessage: errorMsg!)
                        }
                    })
                }
            case .changePassword: self.navigationController?.pushViewController(ChangePasswordVC.instantiateFromStoryboard(storyboard: sideMenuStoryBoard), animated: true)
            case .subPlan:
                let vc = SubscriptionListVC.instantiateFromStoryboard(storyboard: homeStoryBoard)
                vc.isLoginFlow = false
                self.navigationController?.pushViewController(vc, animated: true)
            default: /// Profile Setting
                self.navigationController?.pushViewController(EditProfileVC.instantiateFromStoryboard(storyboard: sideMenuStoryBoard), animated: true)
        }
    }
    
    //MARK: Clicked Side Menu Header Options
    func clickedSideMenuMainOption(Optiuon option: SideMenuOption) {
        self.hideSideMenu()
        switch option {
            case .inviteFriends:
                self.navigationController?.pushViewController(InviteVC.instantiateFromStoryboard(storyboard: sideMenuStoryBoard), animated: true)
            case .cards:
                self.navigationController?.pushViewController(CardListingVC.instantiateFromStoryboard(storyboard: paymentStoryBoard), animated: true)
            default: break
        }
    }
}

//MARK:- Side Menu Handler
extension BaseHomeVC {
    //MARK: Add Extended View
    private func addExtendedView() {
        exView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width*0.03, height: self.view.frame.size.height)
        exView.backgroundColor = UIColor.clear
        let gestureForExView : UIPanGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(self.exPanHandler(panGesture:)))
        exView.addGestureRecognizer(gestureForExView)
        self.view.addSubview(exView)
        let DraggableView = self.AddSideMenuBaseView()
        UIView.performWithoutAnimation {
            self.view.addSubview(DraggableView)
        }
    }
    
    //MARK: Add Side Menu
    private func AddSideMenuBaseView() -> UIView {
        baseView.backgroundColor = UIColor.clear
        baseView.frame = CGRect(x: -self.view.frame.size.width*0.7, y: 0 , width: self.view.frame.size.width*0.7, height: self.view.frame.size.height)
        self.orignalFrameForDraggableView = baseView.frame
        self.maximum_x = baseView.frame.maxX
        let gesture : UIPanGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(self.draggableViewPanHandle(panGesture:)))
        self.baseView.addGestureRecognizer(gesture)
        self.add(asChildViewController: sideMenuVCObject, baseView: baseView)
        return baseView
    }
    
    //MARK: Blur Existence method
    private func getBlurViewDisplayed() {
        let blurredView = self.addBlurEffectView()
        self.view.addSubview(blurredView)
        self.view.bringSubviewToFront(baseView)
        self.view.bringSubviewToFront(exView)
    }
    
    //MARK: Add Blur Effect
    private func addBlurEffectView() -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        blurView.alpha = 0.3
        let gesture : UIPanGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(self.blurViewPanhandle(panGesture:)))
        self.blurView.addGestureRecognizer(gesture)
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return blurView
    }
    
    //MARK: Hide SLiding Menu
    private func hideSideMenu() {
        UIView.animate(withDuration: 0.4 , animations: {
            self.exView.frame.origin.x = 0
            self.baseView.frame.origin.x = -self.view.frame.size.width*0.7
        }, completion: { (success) in
            if success {
                self.blurView.removeFromSuperview()
            }
            guard let mainVC = self.mainHomeScreenObj else {
                return
            }
            mainVC.sideMenuBtn.isSelected = false
        })
    }
    
    //MARK: Show Side Menu
    private func showSideMenu() {
        baseView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width*0.7, height: baseView.frame.height)
        getBlurViewDisplayed()
        setAlphaOfBlurView(origin: (self.baseView.frame.maxX))
        exView.frame = CGRect(x: self.baseView.frame.maxX, y: 0, width: exView.frame.width, height: exView.frame.height)
        sideMenuVCObject.refreshView()
    }
    
    //MARK: Set Blur Effect Alpha
    private func setAlphaOfBlurView(origin : CGFloat) {
        if origin <= maximum_x {
            UIView.animate(withDuration: 0.5) {
                self.blurView.alpha = 0.2
            }
        } else if origin > self.view.frame.size.width*0.5 {
            UIView.animate(withDuration: 0.5) {
                self.blurView.alpha = 0.5
            }
        } else if origin > self.view.frame.size.width*0.3 {
            UIView.animate(withDuration: 0.5) {
                self.blurView.alpha = 0.3
            }
        }
        blurView.setNeedsDisplay()
    }
    
    //MARK: EXView Pan Handler
    @objc func exPanHandler(panGesture: UIPanGestureRecognizer) {
        ///Get the changes
        let translation = panGesture.translation(in: self.view)
        ///Make Ex View To be allowed Draggingin Right Direction
        if CGFloat(round(Double((panGesture.view?.frame.origin.x)!))) >= 0 {
            ///Set ExView Frame
            panGesture.view!.center = CGPoint(x: panGesture.view!.center.x + translation.x, y: panGesture.view!.center.y)
            ///Set BaseView Frame
            self.baseView.center = CGPoint(x: self.baseView.center.x + translation.x, y: self.baseView.center.y)
            ///Set Translation
            panGesture.setTranslation(CGPoint.zero, in: self.view)
        }
        ///Set Maximum Dragging Limit
        if CGFloat(round(Double((panGesture.view?.frame.origin.x)!))) >= self.baseView.frame.size.width {
            ///Set BaseView Frame
            self.baseView.frame.origin.x = 0
            ///Set ExView Frame
            panGesture.view?.frame.origin.x = self.baseView.frame.maxX
            ///Set Translation
            panGesture.setTranslation(CGPoint.zero, in: self.view)
        }
        ///Check if user had Mistaken Moved ExView Beyond 0
        if CGFloat(round(Double((panGesture.view?.frame.origin.x)!))) < 0 {
            ///If Yes ///Set ExView Frame
            panGesture.view?.frame.origin.x = 0
            ///Set Modal base View to Orignal Frame i.e Negative Side
            self.baseView.frame.origin.x = self.orignalFrameForDraggableView.origin.x
            ///Set Translation
            panGesture.setTranslation(CGPoint.zero, in: self.view)
        }
        switch panGesture.state {
        case .began: sideMenuVCObject.refreshView()
        case .changed:
            if (!self.blurView.isDescendant(of: self.view)) {
                self.getBlurViewDisplayed()
            }
            self.setAlphaOfBlurView(origin: (panGesture.view?.frame.maxX)!)
        case .ended:
            ///Check That Ex is Dragged to Specific Position ?
            if CGFloat(round(Double((panGesture.view?.frame.maxX)!))) >= self.view.frame.size.width*0.25 {
                ///If Yes
                ///Need to load Views Here
                UIView.animate(withDuration: 0.7, animations: {
                    self.baseView.frame.origin.x = 0
                    panGesture.view?.frame.origin.x = self.baseView.frame.maxX
                    panGesture.setTranslation(CGPoint.zero, in: self.view)
                })
            } else {
                ///If no
                ///Need to Hide views here
                UIView.animate(withDuration: 0.7, animations: {
                    panGesture.view?.frame.origin.x = 0
                    self.baseView.frame.origin.x = self.orignalFrameForDraggableView.origin.x
                    panGesture.setTranslation(CGPoint.zero, in: self.view)
                    if (self.blurView.isDescendant(of: self.view)) {
                        self.blurView.removeFromSuperview()
                    }
                })
                guard let mainVC = self.mainHomeScreenObj else {
                    return
                }
                mainVC.sideMenuBtn.isSelected = false
            }
        default: break
        }
    }
    
    //MARK: Draggable View Pan Handler
    @objc func draggableViewPanHandle(panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translation(in: self.view)
        ///Make View move to left side of Frame
        if CGFloat(round(Double((panGesture.view?.frame.origin.x)!))) <= 0 {
            panGesture.view!.center = CGPoint(x: panGesture.view!.center.x + translation.x, y: panGesture.view!.center.y)
            self.exView.center = CGPoint(x: self.exView.center.x + translation.x, y: self.exView.center.y)
            panGesture.setTranslation(CGPoint.zero, in: self.view)
        }
        ///Do not let View go beyond origin as 0
        if CGFloat(round(Double((panGesture.view?.frame.origin.x)!))) > 0 {
            panGesture.view?.frame.origin.x = 0
            self.exView.frame.origin.x = (panGesture.view?.frame.maxX)!
            panGesture.setTranslation(CGPoint.zero, in: self.view)
        }
        switch panGesture.state {
        case .began: sideMenuVCObject.refreshView()
        case .changed: self.setAlphaOfBlurView(origin: (self.baseView.frame.maxX))
        case .ended:
            ///Check Do view is Dragged to minimum X ?
            if CGFloat(round(Double((panGesture.view?.frame.maxX)!))) >= self.view.frame.size.width*0.35 {
                ///If No ///Keep Showing All Views
                UIView.animate(withDuration: 0.7, animations: {
                    panGesture.view?.frame.origin.x = 0
                    self.exView.frame.origin.x = (panGesture.view?.frame.maxX)!
                    panGesture.setTranslation(CGPoint.zero, in: self.view)
                })
            } else {
                ///If Yes ///Hide All Views Displayed
                UIView.animate(withDuration: 0.7, animations: {
                    self.exView.frame.origin.x = 0
                    panGesture.view?.frame.origin.x = self.orignalFrameForDraggableView.origin.x
                    panGesture.setTranslation(CGPoint.zero, in: self.view)
                    if (self.blurView.isDescendant(of: self.view)) {
                        self.blurView.removeFromSuperview()
                    }
                })
                guard let mainVC = self.mainHomeScreenObj else {
                    return
                }
                mainVC.sideMenuBtn.isSelected = false
            }
        default: break
        }
    }
    
    //MARK: Blur Effect Pan Handler
    @objc func blurViewPanhandle(panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translation(in: self.view)
        ///Make View move to left side of Frame
        if CGFloat(round(Double((panGesture.view?.frame.origin.x)!))) <= 0 {
            self.baseView.center = CGPoint(x: self.baseView.center.x + translation.x, y: self.baseView.center.y)
            self.exView.center = CGPoint(x: self.exView.center.x + translation.x, y: self.exView.center.y)
            panGesture.setTranslation(CGPoint.zero, in: self.view)
        }
        ///Do not let View go beyond origin as 0
        if CGFloat(round(Double((self.baseView.frame.origin.x)))) > 0 {
            panGesture.view?.frame.origin.x = 0
            self.baseView.frame.origin.x = 0
            self.exView.frame.origin.x = self.baseView.frame.maxX
            panGesture.setTranslation(CGPoint.zero, in: self.view)
        }
        switch panGesture.state {
        case .began: sideMenuVCObject.refreshView()
        case .changed: self.setAlphaOfBlurView(origin: (self.baseView.frame.maxX))
        case .ended:
            ///Check Do view is Dragged to minimum X ?
            if self.baseView.frame.maxX >= self.view.frame.size.width*0.35 {
                ///Keep Showing All Views
                UIView.animate(withDuration: 0.7, animations: {
                    self.baseView.frame.origin.x = 0
                    self.exView.frame.origin.x = self.baseView.frame.maxX
                    panGesture.setTranslation(CGPoint.zero, in: self.view)
                })
            } else {
                ///Hide All Views Displayed
                UIView.animate(withDuration: 0.7, animations: {
                    self.exView.frame.origin.x = 0
                    self.baseView.frame.origin.x = self.orignalFrameForDraggableView.origin.x
                    panGesture.setTranslation(CGPoint.zero, in: self.view)
                    if (self.blurView.isDescendant(of: self.view)) {
                        self.blurView.removeFromSuperview()
                    }
                })
                guard let mainVC = self.mainHomeScreenObj else {
                    return
                }
                mainVC.sideMenuBtn.isSelected = false
            }
        default: break
        }
    }
}

