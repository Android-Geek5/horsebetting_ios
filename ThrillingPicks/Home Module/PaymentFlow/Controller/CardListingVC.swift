//
//  CardListingVC.swift
//  ThrillingPicks
//
//  Created by iOSDev on 6/7/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit
import CoreGraphics

class CardListingVC: UIViewController {
    /// Add New Card Btn
    @IBOutlet weak var addNewCardBtn: UIButton!
    /// Card Listing TV
    @IBOutlet weak var cardListingTV: UITableView!
    
    /// All Cards Added
    fileprivate var addedCards: [CreditCard] = [] {
        didSet {
            self.cardListingTV.reloadData()
        }
    }
    
    //MARK: Add New Card Action
    @IBAction func addNewCardAction(_ sender: Any) {
        let vc = AddNewCardVC.instantiateFromStoryboard(storyboard: paymentStoryBoard)
        vc.isFromLoginFlow = false
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK:- View Life Cycles
extension CardListingVC {
    //MARK: Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        cardListingTV.tableFooterView = UIView()
        getAllAddedCardsFromServer()
    }
    
    //MARK: Layout Subviews
    override func viewDidLayoutSubviews() {
        addNewCardBtn.roundWithRadious(Radius: addNewCardBtn.frame.height/2)
    }
}

extension CardListingVC: AddNewcardVCProtocol {
    //MARK: New Card Added
    func newCardAdded() {
       getAllAddedCardsFromServer()
    }
}

//MARK:- TableView Delegates
extension CardListingVC: UITableViewDelegate, UITableViewDataSource {
    //MARK: Number of Rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addedCards.count
    }
    
    //MARK: Cell For Row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreditCardTVCell", for: indexPath) as! CreditCardTVCell
        cell.congfigureCell(CreditCard: addedCards[indexPath.row])
        return cell
    }
    
    //MARK: Height For Row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    //MARK: Did Select Row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = AddNewCardVC.instantiateFromStoryboard(storyboard: paymentStoryBoard)
        vc.isFromLoginFlow = false
        vc.isUpdateCard = true
        vc.selectedCardToUpdate = addedCards[indexPath.row]
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: Can Edit Row
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //MARK: Commit Editing Style
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: tableView.frame.size.height))
        backView.backgroundColor = .clear
        
        let frame = tableView.rectForRow(at: indexPath)
        let myImage = UIImageView(frame: CGRect(x: 20, y: frame.size.height/2-20, width: 35, height: 35))
        myImage.image = UIImage(named: "delete")!
        myImage.backgroundColor = .clear
        backView.addSubview(myImage)
        
        let imgSize: CGSize = tableView.frame.size
        UIGraphicsBeginImageContextWithOptions(imgSize, false, UIScreen.main.scale)
        
        let context = UIGraphicsGetCurrentContext()
        UIColor.clear.setFill()
        context?.fill(tableView.frame)
        backView.layer.render(in: context!)
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: nil) { (action, index) in
            self.delete(AddedCard: self.addedCards[index.row])
        }
        deleteAction.backgroundColor = UIColor(patternImage: newImage)
        return [deleteAction]
    }
    
    /* --> Customize Swipe Action
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action =  UIContextualAction(style: .normal, title: nil, handler: { (action,view,completionHandler ) in
            //do stuff
            completionHandler(true)
        })
        action.image = UIImage(named: "delete")
        action.backgroundColor = .clear
        let confrigation = UISwipeActionsConfiguration(actions: [action])

        return confrigation
    } */
}

//MARK:- API Handler
extension CardListingVC {
    //MARK: Get All Cards
    private func getAllAddedCardsFromServer() {
        Functions.shared.showActivityIndicator("Loading", view: self)
        WebService.wsGetAllCardsAdded(success: { (allcards) in
            Functions.shared.hideActivityIndicator()
            self.addedCards = allcards
        }) { (logoutBool, errorMsg) in
            Functions.shared.hideActivityIndicator()
            if logoutBool {
                Functions.logoutUser(With: self.navigationController!)
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                if !(errorMsg ?? "").trimmed().isEmpty { self.showAlert(AlertTitle: TAppName, AlertMessage: errorMsg!) }
            })
        }
    }
    
    //MARK: Delete Added Card
    private func delete(AddedCard card: CreditCard) {
        Functions.shared.showActivityIndicator("Loading", view: self)
        WebService.wsDeleteAddedCard(CardID: card.cardID ?? "", success: { (success, msg) in
            Functions.shared.hideActivityIndicator()
            if success {
                if let index = self.addedCards.firstIndex(where: { $0.cardID ?? "" == card.cardID ?? "" }) {
                    self.addedCards.remove(at: index)
                }
            }
        }) { (logoutBool, errorMsg) in
            Functions.shared.hideActivityIndicator()
            if logoutBool {
                Functions.logoutUser(With: self.navigationController!)
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                if !(errorMsg ?? "").trimmed().isEmpty { self.showAlert(AlertTitle: TAppName, AlertMessage: errorMsg!) }
            })
        }
    }
}

//MARK:- Button Actions
extension CardListingVC {
    //MARK: Back Btn Action
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
