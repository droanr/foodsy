//
//  RecipeListViewController.swift
//  foodsy
//
//  Created by hsherchan on 10/16/17.
//  Copyright © 2017 Foodly. All rights reserved.
//

import UIKit

class RecipeListViewController: UIViewController {

    @IBOutlet weak var tableView: RecipeTableView!
    @IBOutlet weak var searchBtn: UIBarButtonItem!
    var selectedRecipe: Recipe?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Search", style: .plain, target: self, action: #selector(addTapped))

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchRecipes(params: nil)
    }
    func searchRecipes(params: NSDictionary?) {
        RecipeClient.SharedInstance.fetchRecipes(params: params, success: { (recipes) in
            self.tableView.recipes = recipes
            self.tableView.reloadData()
            Recipe.fetchFavoriteRecipesForUser(name: (User.currentUser?.screenname)!) { (recipes) in
                for recipe in recipes {
                    let recipeID = recipe.id as! Int
                    self.tableView.recipeFavorites[recipeID] = true
                    self.tableView.reloadData()
                }
            }
        }) { (error) in
            print(error)
        }
    }
    
    @objc func addTapped(sender: UIBarButtonItem) {
        let filterStoryboard = UIStoryboard(name: "Filters", bundle: nil)
        let filtersNavigationController = filterStoryboard.instantiateViewController(withIdentifier: "FiltersNavigationController") as! UINavigationController
        let filtersViewController = filtersNavigationController.childViewControllers[0] as! FiltersViewController
        filtersViewController.delegate = self
        self.present(filtersNavigationController, animated: true, completion: nil)
    }
    
    func favoriteTapped(recipe: Recipe) {
        let recipeID = recipe.id as! Int
        if let recipeFavorite = tableView.recipeFavorites[recipeID]{
           tableView.recipeFavorites[recipeID] = !recipeFavorite
        } else {
            tableView.recipeFavorites[recipeID] = true
        }
        
        if tableView.recipeFavorites[recipeID]! {
            recipe.favoriteForUser()
        } else {
            recipe.unfavoriteForUser()
        }
    }
    
    func setRecipeBtnImageState(recipeCell: RecipeCell, recipeID: Int) {
        if tableView.recipeFavorites[recipeID] != nil {
            let image = UIImage(named: "heart-filled") as UIImage!
            recipeCell.favoriteBtn.setBackgroundImage(image, for: UIControlState.normal)
        } else {
            let image = UIImage(named: "heart") as UIImage!
            recipeCell.favoriteBtn.setBackgroundImage(image, for: UIControlState.normal)
        }
        
    }
}

extension RecipeListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let tableView = tableView as! RecipeTableView
        
        if let recipes = tableView.recipes {
            return recipes.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableView = tableView as! RecipeTableView
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as! RecipeCell
        let recipe = tableView.recipes?[indexPath.row]
        let recipeID = recipe?.id as! Int
        cell.recipe = recipe
        cell.backgroundColor = UIColor.clear
        cell.delegate = self
        
        setRecipeBtnImageState(recipeCell: cell, recipeID: recipeID)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tableView = tableView as! RecipeTableView
        selectedRecipe = tableView.recipes?[indexPath.row]
        let storyboard = UIStoryboard(name: "Recipe", bundle: nil)
        let recipeDetailsViewController = storyboard.instantiateViewController(withIdentifier: "RecipeDetailsViewController") as! RecipeDetailsViewController
        recipeDetailsViewController.recipe = selectedRecipe
        recipeDetailsViewController.navigationItem.leftBarButtonItem?.tintColor = .white
        let navController = UINavigationController(rootViewController: recipeDetailsViewController)
        navController.childViewControllers[0].navigationItem.leftBarButtonItem = UIBarButtonItem(title: "< Recipes", style: UIBarButtonItemStyle.plain, target: self, action: #selector(goBack(_:)))
        self.show(navController, sender: self)
    }
    
    @objc func goBack(_ sender: UIBarButtonItem){
        self.dismiss(animated: true, completion: nil)
    }
}

extension RecipeListViewController: FiltersViewControllerDelegate {
    func filtersViewController(filtersViewController: FiltersViewController, dietChoice: String, intoleranceChoices: [String], typeChoice: String, cuisineChoices: [String]) {
        var params = [String:[String]]()
        
        if dietChoice.count > 0 {
           params["diet"] = [dietChoice]
        }
        
        if intoleranceChoices.count > 0 {
            params["intolerances"] = intoleranceChoices
        }
        
        if typeChoice.count > 0 {
            params["type"] = [typeChoice]
        }
        
        if cuisineChoices.count > 0 {
            params["cuisine"] = cuisineChoices
        }
        
        searchRecipes(params:params as NSDictionary)
    }
}

extension RecipeListViewController: FavoriteCellDelegate {
    func favoriteCell(favoriteRecipeCell: RecipeCell) {
        let indexPath = tableView.indexPath(for: favoriteRecipeCell)!
        let recipe = tableView.recipes![indexPath.row]
        let recipeID = recipe.id as! Int
        self.favoriteTapped(recipe: recipe)
        self.setRecipeBtnImageState(recipeCell: favoriteRecipeCell, recipeID: recipeID)
    }
}