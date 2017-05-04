//
//  ViewController.swift
//  MemeMe
//
//  Created by Yeontae Kim on 4/17/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    let textFieldAttributes: [String:Any] = [
        NSForegroundColorAttributeName: UIColor.white,
        NSFontAttributeName: UIFont(name: "impact", size: 40),
        NSStrokeColorAttributeName: UIColor.black,
        NSStrokeWidthAttributeName: -5,
        ]
    
    var imagePicker: UIImagePickerController!
   
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        topTextField.attributedPlaceholder = NSAttributedString(string: "TOP", attributes: textFieldAttributes)
        topTextField.defaultTextAttributes = textFieldAttributes
        topTextField.textAlignment = .center
        
        bottomTextField.attributedPlaceholder = NSAttributedString(string: "BOTTOM", attributes: textFieldAttributes)
        bottomTextField.defaultTextAttributes = textFieldAttributes
        bottomTextField.textAlignment = .center
        
        topTextField.delegate = self
        bottomTextField.delegate = self

        // The Camera button is disabled when app is run on devices without a camera, such as the simulator
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            cameraButton.isEnabled = true
        } else {
            cameraButton.isEnabled = false
        }
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        
    }
    
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
    
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func takeAPhoto(_ sender: Any) {
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let image = info[UIImagePickerControllerEditedImage] as? UIImage
        imagePickerView.image = image
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
    
        textField.attributedPlaceholder = nil
    
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == topTextField {
            topTextField.attributedPlaceholder = NSAttributedString(string: "TOP", attributes: textFieldAttributes)
        } else { // bottomTextField
            bottomTextField.attributedPlaceholder = NSAttributedString(string: "BOTTOM", attributes: textFieldAttributes)
        }
        
        textField.resignFirstResponder()
        
        return true
    }
    
    func keyboardWillShow(_ notification: Notification) {
        
        if bottomTextField.isFirstResponder {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }

    }
    
    func keyboardWillHide(_ notification: Notification) {
        
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect

        return keyboardSize.cgRectValue.height
    
    }
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    
    }
    
    struct Meme {
        var topText: String
        var bottomText: String
        var originalImage: UIImage?
        var memedImage: UIImage
    }
    
    func generateMemedImage() -> UIImage {
        
        // TODO: Hide toolbar and navbar
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.toolBar.isHidden = true
        UIApplication.shared.isStatusBarHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // TODO: Show toolbar and navbar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.toolBar.isHidden = false
        UIApplication.shared.isStatusBarHidden = false
        
        return memedImage
    }
    
    func save() {
        // Create the meme
        let meme = Meme(topText: topTextField.text!,
                        bottomText: bottomTextField.text!,
                        originalImage: imagePickerView.image!,
                        memedImage: generateMemedImage())
    }
    
    @IBAction func shareImageButton(_ sender: Any) {
        
        if imagePickerView.image != nil {
        
            let memedImage = generateMemedImage()
        
            let activityViewController = UIActivityViewController(activityItems: [ memedImage ], applicationActivities: nil)
            // present the view controller
            present(activityViewController, animated: true, completion: nil)
            
            activityViewController.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) -> Void in
                if (completed) {
                    self.save()
                    self.dismiss(animated: true, completion: nil)
                }
            }
            
        } else {
            
            let alert = UIAlertController(title: "Alert",
                                          message: "Please select an image from photo library or camera",
                                          preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Okay", style: .default, handler: { (action) -> Void in
 
            })
            
            alert.addAction(okayAction)
            present(alert, animated: true, completion: nil)
        }
    
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        
        // go back to placeholder text, no image when cancel button tapped

        topTextField.text = ""
        bottomTextField.text = ""

        imagePickerView.image = nil
        
    }

}
