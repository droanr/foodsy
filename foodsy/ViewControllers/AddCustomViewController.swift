//
//  AddCustomViewController.swift
//  foodsy
//
//  Created by drishi on 10/20/17.
//  Copyright © 2017 Foodly. All rights reserved.
//

import UIKit

protocol AddCustomViewControllerDelegate {
    func onAddIngredient(ingredient: Ingredient)
}

protocol EditCustomViewControllerDelegate {
    func onEditIngredient(ingredient: Ingredient, index: Int)
}

class AddCustomViewController: UIViewController {

    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var ingredientImage: UIImageView!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var quantity: UITextField!
    @IBOutlet weak var remindIn: UITextField!
    @IBOutlet weak var addIngredientItem: UIBarButtonItem!
    @IBOutlet weak var searchAmazon: UIButton!
    @IBOutlet var imageTapRecognizer: UITapGestureRecognizer!
    var delegate: AddCustomViewControllerDelegate!
    var editDelegate: EditCustomViewControllerDelegate!
    var mode = "create"
    var ingredient: Ingredient?
    var index: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        addIngredientItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor:UIColor.gray], for: UIControlState.disabled)
        footerView.backgroundColor = Utils.getSecondaryColor()
        searchAmazon.backgroundColor = Utils.getPrimaryColor()
        if let ingredient = self.ingredient {
            if self.mode == "create" {
                addIngredientItem.title = "ADD"
            } else if self.mode == "edit" {
                addIngredientItem.title = "SAVE"
            }
            name.text = ingredient.name
            if let quant = ingredient.quantity {
                quantity.text = quant.description
            }
            if let remind = ingredient.reminderDays {
                remindIn.text = remind.description
            }
            addPhotoButton.isHidden = true            
            ingredient.getImage(success: { (image) in
                if image != nil {
                    self.ingredientImage.image = image
                } else if self.ingredient?.image != nil {
                    self.ingredientImage.setImageWith((self.ingredient?.getBigImageUrl()!)!)
                }
            }) { (error) in
                print("Error: \(error.localizedDescription)")
            }
            searchAmazon.isHidden = false
        } else {
            ingredientImage.backgroundColor = Utils.getSecondaryColor()
            searchAmazon.isHidden = true
            addIngredientItem.isEnabled = false
        }
        ingredientImage.isUserInteractionEnabled = true
        name.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        self.navigationController?.view.backgroundColor = Utils.getPrimaryColor()
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        if textField.text?.isEmpty == false {
            self.addIngredientItem.isEnabled = true
        } else {
            self.addIngredientItem.isEnabled = false
        }
    }
    
    @IBAction func onAddPhoto(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("Camera is available 📸")
            vc.sourceType = .camera
        } else {
            print("Camera 🚫 available so we will use photo library instead")
            vc.sourceType = .photoLibrary
        }
        self.present(vc, animated: true, completion: nil)
    }

    @IBAction func onSearchAmazon(_ sender: UIButton) {
        let escapedString = ingredient?.name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let urlString = "https://www.amazon.com/s/ref=nb_sb_noss_1?url=search-alias%3Damazonfresh&field-keywords=" + escapedString!
        let url = URL(string: urlString)
        
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
    
    
    @IBAction func onTapIngredientImage(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "showPhotoDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhotoDetail" {
            let navVc = segue.destination as! UINavigationController
            let vc = navVc.topViewController as! PhotoDetailViewController
            vc.delegate = self
            vc.ingredient = self.ingredient
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onAddIngredient(_ sender: Any) {
        if ingredient == nil {
            ingredient = Ingredient()
        }
        if !(name.text?.isEmpty)! {
            ingredient?.name = name.text?.capitalized
        }
        if !(quantity.text?.isEmpty)! {
            ingredient?.quantity = NSNumber(value: Int(quantity.text!)!)
        }
        if !(remindIn.text?.isEmpty)! {
            ingredient?.reminderDays = NSNumber(value: Int(remindIn.text!)!)
        }
        if self.mode == "create" {
            self.delegate.onAddIngredient(ingredient: ingredient!)
        } else if self.mode == "edit" {
            self.editDelegate.onEditIngredient(ingredient: ingredient!, index: self.index!)
        }
    }
}

extension AddCustomViewController: PhotoDetailViewControllerDelegate {
    func onAddedNewPhoto(ingredient: Ingredient, changed: Bool, image: UIImage) {
        if changed == true {
            self.ingredientImage.image = image
            self.addIngredientItem.isEnabled = true
        }
    }
}

extension AddCustomViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        // Get the image captured by the UIImagePickerController
        //let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        // Do something with the images (based on your use case)
        self.ingredientImage.image = editedImage
        if self.ingredient == nil {
            self.ingredient = Ingredient()
        }
        self.ingredient?.setImage(image: editedImage)
        addPhotoButton.isHidden = true
        // Dismiss UIImagePickerController to go back to your original view controller
        dismiss(animated: true, completion: nil)
    }
}
