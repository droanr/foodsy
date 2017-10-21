//
//  IngredientTableViewCell.swift
//  foodsy
//
//  Created by drishi on 10/15/17.
//  Copyright © 2017 Foodly. All rights reserved.
//

import UIKit
import SwipeCellKit

@objc protocol IngredientTableViewCellDelegate {
    @objc optional func ingredientAdded(ingredient: Ingredient)
}

class IngredientTableViewCell: SwipeTableViewCell {

    @IBOutlet weak var ingredientImage: UIImageView!
    @IBOutlet weak var ingredientName: UILabel!
    @IBOutlet weak var addButton: UIImageView!
    var ingredientDelegate: IngredientTableViewCellDelegate!
    var ingredient: Ingredient! {
        didSet {
            ingredientImage.setImageWith(ingredient.getImageUrl())
            ingredientName.text = ingredient.name
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let addIngredientRecognizer = UITapGestureRecognizer(target: self, action: #selector(onAddIngredient(tapGestureRecognizer:)))
        addButton.isUserInteractionEnabled = true
        addButton.addGestureRecognizer(addIngredientRecognizer)
    }
    
    @objc func onAddIngredient(tapGestureRecognizer: UITapGestureRecognizer) {
        ingredientDelegate.ingredientAdded!(ingredient: ingredient)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}