//
//  MacrosViewController.swift
//  Food
//
//  Created by Eamon Woods on 8/10/17.
//
//

import UIKit
import Charts

class MacrosViewController: UIViewController, SearchViewControllerDelegate, TodaysFoodsViewControllerDelegate {
    
    var todaysFoods: [(Food, Double, String)] = []
    var hamburgerButton: UIBarButtonItem!
    var searchButton: UIBarButtonItem!
    var protein: Double = 0
    var carbs: Double = 0
    var fat: Double = 0
    var calories: Double = 0
    var pieChartView: PieChartView!
    var pleaseAddFoodsLabel: UILabel!
    
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
    
        pieChartView = PieChartView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height / 2.0))
        pieChartView.center = view.center
        pieChartView.holeColor = .clear
        pieChartView.chartDescription?.text = "Macronutrients"
        pieChartView.chartDescription?.font = UIFont(name: "Helvetica Neue", size: 20)!
        pieChartView.chartDescription?.xOffset = 110
        pieChartView.chartDescription?.yOffset = -20
        pieChartView.centerText = "Total kcal:\n \(0)"
        pieChartView.drawEntryLabelsEnabled = false
        pieChartView.legend.font = UIFont(name: "Helvetica Neue", size: 16)!
        pieChartView.legend.xOffset = 75
        
        pleaseAddFoodsLabel = UILabel(frame: CGRect(x: 0, y: (navigationController?.navigationBar.frame.maxY)! + 20, width: 0, height: 0))
        pleaseAddFoodsLabel.text = "Search for what you ate today"
        pleaseAddFoodsLabel.sizeToFit()
        pleaseAddFoodsLabel.center.x = view.center.x
        
        update()
        
        view.addSubview(pieChartView)
        view.addSubview(pleaseAddFoodsLabel)
    }
    
    func update() {
        addUpMacros()
        updatePieChart()
        if (calories == 0) {
            pleaseAddFoodsLabel.isHidden = false
        } else {
            pleaseAddFoodsLabel.isHidden = true
        }
    }
    
    func updatePieChart() {
        var dataSet = PieChartDataSet()
        dataSet.colors = []
        let proteinEntry = PieChartDataEntry(value: floor(protein), label: "Protein (g)")
        let carbsEntry = PieChartDataEntry(value: floor(carbs), label: "Carbs (g)")
        let fatEntry = PieChartDataEntry(value: floor(fat), label: "Fat (g)")
        if protein * 100 > carbs && protein * 100 > fat && protein > 1 {
            dataSet.values.append(proteinEntry)
            dataSet.colors.append(ChartColorTemplates.joyful()[0])
        }
        if carbs * 100 > protein && carbs * 100 > fat && carbs > 1{
            dataSet.values.append(carbsEntry)
            dataSet.colors.append(ChartColorTemplates.joyful()[1])
        }
        if fat * 100 > protein && fat * 100 > carbs && fat > 1 {
            dataSet.values.append(fatEntry)
            dataSet.colors.append(ChartColorTemplates.joyful()[2])
        }
        let proteinLegend = LegendEntry(label: "Protein (g)", form: .default, formSize: .nan, formLineWidth: .nan, formLineDashPhase: .nan, formLineDashLengths: nil, formColor: ChartColorTemplates.joyful()[0])
        let carbsLegend = LegendEntry(label: "Carbs (g)", form: .default, formSize: .nan, formLineWidth: .nan, formLineDashPhase: .nan, formLineDashLengths: nil, formColor: ChartColorTemplates.joyful()[1])
        let fatLegend = LegendEntry(label: "Fat (g)", form: .default, formSize: .nan, formLineWidth: .nan, formLineDashPhase: .nan, formLineDashLengths: nil, formColor: ChartColorTemplates.joyful()[2])
        pieChartView.legend.setCustom(entries: [proteinLegend, carbsLegend, fatLegend])
        dataSet.valueColors = [.black]
        let data = PieChartData(dataSet: dataSet)
        pieChartView.data = data
        pieChartView.centerText = "Total kcal:\n \(Int(calories))"
        pieChartView.notifyDataSetChanged()
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
        update()
    }
    
    func searchButtonWasTapped() {
        let searchViewController = SearchViewController()
        searchViewController.searchViewControllerDelegate = self
        navigationController?.pushViewController(searchViewController, animated: true)
    }
}
