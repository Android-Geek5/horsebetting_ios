//
//  UploadImagePopupVC.swift
//  ThrillingPicks
//
//  Created by iOSDev on 6/6/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit
import MobileCoreServices

protocol UploadImageVCProtocol {
    //MARK: Pass Image Data
    func showSelectedImageFromPickerWith(Image img: UIImage?, URL imgURL: URL?)
}

class UploadImagePopupVC: UIViewController {
    /// Delegate
    var delegate: UploadImageVCProtocol?

    /// Image Picker
    fileprivate var imagePicker:UIImagePickerController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
    }
    
    @IBAction func chooseImageAction(_ sender: UIButton) {
        sender.tag == 1 ? (openGallery()) : (openCamera())
    }
    
    @IBAction func cancelBtnAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK:- Required Functions
extension UploadImagePopupVC {
    //MARK: Open Gallery
    private func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            Functions.checkForGalleryPermission { (permission) in
                if permission {
                    self.imagePicker = UIImagePickerController()
                    self.imagePicker?.delegate = self
                    self.imagePicker?.mediaTypes = [kUTTypeImage as String]
                    self.imagePicker?.sourceType = UIImagePickerController.SourceType.photoLibrary
                    self.imagePicker?.allowsEditing = true
                    self.present(self.imagePicker!, animated: true, completion: nil)
                } else {
                    self.showAlertWithOneAction(AlertTitle: TAppName, AlertMessage: "Permission is not granted to access Photo Library. Press Ok to navigate to \(TAppName) Settings.", ActionTitle: "Ok") { (success) in
                        self.dismiss(animated: true, completion: {
                            self.imagePicker = nil
                            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                return
                            }
                            
                            if UIApplication.shared.canOpenURL(settingsUrl) {
                                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                    print("Settings opened: \(success)") // Prints true
                                })
                            }
                        })
                    }
                }
            }
        } else {
            self.showAlertWithOneAction(AlertTitle: TAppName, AlertMessage: "Photo Library is not available", ActionTitle: "Ok") { (success) in
                self.dismiss(animated: true, completion: {
                    self.imagePicker = nil
                })
            }
        }
    }
    
    //MARK: Open Camera
    private func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            Functions.checkForCameraPermission { (permission) in
                if permission {
                    self.imagePicker = UIImagePickerController()
                    self.imagePicker?.delegate = self
                    self.imagePicker?.mediaTypes = [kUTTypeImage as String]
                    self.imagePicker?.sourceType = UIImagePickerController.SourceType.camera
                    self.imagePicker?.allowsEditing = true
                    self.present(self.imagePicker!, animated: true, completion: nil)
                } else {
                    self.showAlertWithOneAction(AlertTitle: TAppName, AlertMessage: "Permission is not granted to access camera. Press Ok to navigate to \(TAppName) Settings.", ActionTitle: "Ok") { (success) in
                        self.dismiss(animated: true, completion: {
                            self.imagePicker = nil
                            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                return
                            }
                            
                            if UIApplication.shared.canOpenURL(settingsUrl) {
                                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                    print("Settings opened: \(success)") // Prints true
                                })
                            }
                        })
                    }
                }
            }
        } else {
            self.showAlertWithOneAction(AlertTitle: TAppName, AlertMessage: "Camera is not available", ActionTitle: "Ok") { (success) in
                self.dismiss(animated: true, completion: {
                    self.imagePicker = nil
                })
            }
        }
    }
}

//MARK:- ImagePicker Delegates
extension UploadImagePopupVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //MARK: UIImagePicker Controller Result Delegate
    /**
     Called when user selected a Image or a Movie from Gallery
     - parameter picker : The controller object managing the image picker interface
     - parameter info : A dictionary containing the original image and the edited image,
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.dismiss(animated: true) {
                if #available(iOS 11.0, *) {
                    self.delegate?.showSelectedImageFromPickerWith(Image: img, URL: info[UIImagePickerController.InfoKey.imageURL] as? URL)
                } else {
                    self.delegate?.showSelectedImageFromPickerWith(Image: img, URL: info[UIImagePickerController.InfoKey.referenceURL] as? URL)
                }
                self.imagePicker=nil
            }
        } else {
            /// Issue Getting Image
            self.dismiss(animated: true) {
                self.showAlert(AlertTitle: TAppName, AlertMessage: "Error Getting Image. Please try again.")
                self.imagePicker=nil
            }
        }
    }
    
    //MARK: Picker did Cancel
    /**
     Called when user Cancel the picker
     - parameter picker : The controller object managing the image picker interface
     */
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true) {
            self.imagePicker=nil
        }
    }
}
