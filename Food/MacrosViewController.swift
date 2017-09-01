//
//  MacrosViewController.swift
//  Food
//
//  Created by Eamon Woods on 8/10/17.
//
//

import UIKit

class MacrosViewController: UIViewController, SearchViewControllerDelegate, TodaysFoodsViewControllerDelegate {
    
    var todaysFoods: [(Food, Double, String)] = []
    var hamburgerButton: UIBarButtonItem!
    var searchButton: UIBarButtonItem!
    var protein: Double!
    var carbs: Double!
    var fat: Double!
    var calories: Double!
    var proteinLabel: UILabel!
    var carbsLabel: UILabel!
    var fatLabel: UILabel!
    var caloriesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Macros"
        view.backgroundColor = .lightGray
        hamburgerButton = UIBarButtonItem()
        hamburgerButton.image = #imageLiteral(resourceName: "menu")
        if revealViewController() != nil {
            navigationItem.leftBarButtonItem = hamburgerButton
            hamburgerButton.target = revealViewController()
            hamburgerButton.action = #selector(revealViewController().revealToggle(_:))
            view.addGestureRecognizer(revealViewController().panGestureRecognizer())
            view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
        }
        searchButton = UIBarButtonItem(title: "Search", style: .plain, target: self, action: #selector(searchButtonWasTapped))
        navigationItem.rightBarButtonItem = searchButton
        
        caloriesLabel = UILabel(frame: CGRect(x: 0, y: (navigationController?.navigationBar.frame.maxY)! + 10, width: 0, height: 0))
        proteinLabel = UILabel(frame: CGRect(x: 0, y: caloriesLabel.frame.maxY + 30, width: 0, height: 0))
        carbsLabel = UILabel(frame: CGRect(x: 0, y: proteinLabel.frame.maxY + 30, width: 0, height: 0))
        fatLabel = UILabel(frame: CGRect(x: 0, y: carbsLabel.frame.maxY + 30, width: 0, height: 0))
        addUpMacros()
        updateMacroLabels()
        
        view.addSubview(caloriesLabel)
        view.addSubview(proteinLabel)
        view.addSubview(carbsLabel)
        view.addSubview(fatLabel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addUpMacros()
        updateMacroLabels()
    }
    
    func updateMacroLabels() {
        caloriesLabel.text = "Calories: \(calories.description)"
        caloriesLabel.sizeToFit()
        proteinLabel.text = "Protein: \(protein.description)"
        proteinLabel.sizeToFit()
        carbsLabel.text = "Carbs: \(carbs.description)"
        carbsLabel.sizeToFit()
        fatLabel.text = "Fat: \(fat.description)"
        fatLabel.sizeToFit()
    }
    
    func addUpMacros() {
        protein = 0
        carbs = 0
        fat = 0
        calories = 0
        for (food, quantity, measurement) in todaysFoods {
            guard let proteinArray = food.nutrients?["Protein"],
            let carbsArray = food.nutrients?["Carbohydrate, by difference"],
            let fatArray = food.nutrients?["Total lipid (fat)"],
                let caloriesArray = food.nutrients?["Energy"] else { print("Couldn't get macros arrays"); return }
            if measurement == "grams" {
                guard let proteinPer100g = proteinArray["100g"],
                let carbsPer100g = carbsArray["100g"],
                let fatPer100g = fatArray["100g"],
                    let caloriesPer100g = caloriesArray["100g"] else { print("Couldn't get macro values (in grams) from arrays"); return }
                protein = protein + (proteinPer100g / 100.0) * quantity
                carbs = carbs + (carbsPer100g / 100.0) * quantity
                fat = fat + (fatPer100g / 100.0) * quantity
                calories = calories + (caloriesPer100g / 100.0) * quantity
            } else {
                guard let proteinPerMeasurement = proteinArray[measurement],
                let carbsPerMeasurement = carbsArray[measurement],
                let fatPerMeasurement = fatArray[measurement],
                    let caloriesPerMeasurement = caloriesArray[measurement] else { print("Couldn't get macro values (not in grams) from arrays"); return }
                protein = protein + proteinPerMeasurement * quantity
                carbs = carbs + carbsPerMeasurement * quantity
                fat = fat + fatPerMeasurement * quantity
                calories = calories + caloriesPerMeasurement * quantity
            }
        }
    }
    
    func addFoodToTodaysFoods(food: Food, quantity: Double, measurement: String) {
        todaysFoods.append(food, quantity, measurement)
    }
    
    func searchButtonWasTapped() {
        let searchViewController = SearchViewController()
        searchViewController.searchViewControllerDelegate = self
        navigationController?.pushViewController(searchViewController, animated: true)
    }
}
