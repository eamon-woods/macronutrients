//
//  FoodDetailViewController.swift
//  Food
//
//  Created by Eamon Woods on 7/31/17.
//
//

import UIKit

protocol FoodDetailViewControllerDelegate {
    func addFoodToTodaysFoods(food: Food, quantity: Double,measurement: String)
}

class FoodDetailViewController: UIViewController {

    var food: Food!
    let requestService = RequestService()
    var typeLabel: UILabel!
    var measurementLabel: UILabel!
    var measurementPicker: UIPickerView!
    var quantityLabel: UILabel!
    var quantityTextField: UITextField!
    var addFoodToTodaysFoodsButton: UIButton!
    var foodToAddToTodaysFoodsLabel: UILabel? = nil
    var foodDetailViewControllerDelegate: FoodDetailViewControllerDelegate?
    var foodNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .lightGray
        view.autoresizesSubviews = true
        foodNameLabel = UILabel(frame: CGRect(x: 0, y: (navigationController?.navigationBar.frame.maxY)! + 10, width: view.frame.width - 20, height: 0))
        foodNameLabel.text = food.name
        foodNameLabel.numberOfLines = 0
        foodNameLabel.lineBreakMode = .byWordWrapping
        foodNameLabel.sizeToFit()
        foodNameLabel.textAlignment = .center
        foodNameLabel.isHidden = true
        foodNameLabel.center.x = view.center.x
        measurementLabel = UILabel(frame: CGRect(x: 0, y: foodNameLabel.frame.maxY + 10, width: 0, height: 0))
        measurementLabel.center.x = view.frame.width - 175
        measurementLabel.text = "Measurement"
        measurementLabel.sizeToFit()
        measurementPicker = UIPickerView(frame: CGRect(x: 0, y:measurementLabel.frame.maxY, width: 130, height: 100))
        measurementPicker.isHidden = true
        measurementPicker.delegate = self
        measurementPicker.dataSource = self
        measurementPicker.center.x = measurementLabel.center.x
        quantityLabel = UILabel(frame: CGRect(x: view.frame.width - measurementLabel.frame.maxX, y:measurementLabel.frame.minY, width: 0, height: 0))
        quantityLabel.text = "Quantity"
        quantityLabel.sizeToFit()
        quantityTextField = UITextField(frame: CGRect(x: 0, y: quantityLabel.frame.maxY + 10, width: 50, height: 30))
        quantityTextField.center.x = quantityLabel.center.x
        quantityTextField.center.y = measurementPicker.center.y
        quantityTextField.borderStyle = UITextBorderStyle.roundedRect
        quantityTextField.keyboardType = UIKeyboardType.decimalPad
        quantityTextField.becomeFirstResponder()
        quantityTextField.addTarget(self, action: #selector(quantityTextFieldOrMeasurementPickerWasEdited), for: .editingChanged)
        
        measurementLabel.isHidden = true
        quantityLabel.isHidden = true
        quantityTextField.isHidden = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissTextFieldKeyboard)))
        addFoodToTodaysFoodsButton = UIButton()
        addFoodToTodaysFoodsButton.setTitle("Add to today's foods", for: .normal)
        addFoodToTodaysFoodsButton.sizeToFit()
        addFoodToTodaysFoodsButton.center.x = view.center.x
        addFoodToTodaysFoodsButton.setTitleColor(.blue, for: .normal)
        addFoodToTodaysFoodsButton.addTarget(self, action: #selector(addFoodToTodaysFoods), for: .touchUpInside)
        addFoodToTodaysFoodsButton.isHidden = true
        addFoodToTodaysFoodsButton.showsTouchWhenHighlighted = true
        
        getFoodReport()
        
        view.addSubview(measurementPicker)
        view.addSubview(measurementLabel)
        view.addSubview(quantityLabel)
        view.addSubview(quantityTextField)
        view.addSubview(addFoodToTodaysFoodsButton)
        view.addSubview(foodNameLabel)
    }
    
    func quantityTextFieldOrMeasurementPickerWasEdited() {
        if let quantity = quantityTextField.text {
            if quantity != "" {
                if let foodToAddLabel = foodToAddToTodaysFoodsLabel {
                    foodToAddLabel.removeFromSuperview()
                }
                foodToAddToTodaysFoodsLabel = UILabel(frame: CGRect(x: 0, y:measurementPicker.frame.maxY, width: view.frame.width - 20, height: 0))
                foodToAddToTodaysFoodsLabel!.text = "Quantity: \(quantity), measurement: \(String(describing: food.acceptableMeasurements![measurementPicker.selectedRow(inComponent: 0)]))"
                foodToAddToTodaysFoodsLabel!.numberOfLines = 0
                foodToAddToTodaysFoodsLabel!.lineBreakMode = .byWordWrapping
                foodToAddToTodaysFoodsLabel!.sizeToFit()
                foodToAddToTodaysFoodsLabel!.center.x = view.center.x
                view.addSubview(foodToAddToTodaysFoodsLabel!)
                addFoodToTodaysFoodsButton.center.y = foodToAddToTodaysFoodsLabel!.frame.maxY + 20
                addFoodToTodaysFoodsButton.isHidden = false
            } else {
                if let foodToAddLabel = foodToAddToTodaysFoodsLabel {
                    foodToAddLabel.removeFromSuperview()
                }
                addFoodToTodaysFoodsButton.isHidden = true
            }
        }
    }
    
    func addFoodToTodaysFoods() {
        if let quantity = Double(quantityTextField.text!) {
            //we know quantityTextField will have text if this button action is triggered
            foodDetailViewControllerDelegate?.addFoodToTodaysFoods(food: food, quantity: quantity,measurement: food.acceptableMeasurements![measurementPicker.selectedRow(inComponent: 0)])
        }
        navigationController?.popToRootViewController(animated: true)
    }
    
    func dismissTextFieldKeyboard() {
        quantityTextField.resignFirstResponder()
    }

    func getFoodReport() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        requestService.getFoodReport(ndbno: food.ndbno) { (type, nutrients, acceptableMeasurements) in
            self.food.type = type
            self.food.nutrients = nutrients
            self.food.acceptableMeasurements = acceptableMeasurements
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            DispatchQueue.main.async {
                self.measurementPicker.reloadAllComponents()
                self.measurementPicker.isHidden = false
                self.measurementLabel.isHidden = false
                self.quantityLabel.isHidden = false
                self.quantityTextField.isHidden = false
                self.foodNameLabel.isHidden = false
            }
        }
    }
}

extension FoodDetailViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        quantityTextFieldOrMeasurementPickerWasEdited()
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if let acceptableMeasurements = food.acceptableMeasurements {
            let label = UILabel()
            label.text = acceptableMeasurements[row]
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            return label
        }
        return UIView()
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        if let acceptableMeasurements = food.acceptableMeasurements, var longestMeasurement = acceptableMeasurements.first {
            for measurement in acceptableMeasurements {
                if measurement.characters.count > longestMeasurement.characters.count {
                    longestMeasurement = measurement
                }
            }
            let charactersOnALine = 15.0
            let numLines = ceil(Double(longestMeasurement.characters.count) / charactersOnALine)
            let desiredLineHeight = 20.0
            return CGFloat(numLines * desiredLineHeight + 5)
        }
        return 25
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if food.acceptableMeasurements != nil {
            return 1
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let acceptableMeasurements = food.acceptableMeasurements {
            return acceptableMeasurements.count
        }
        return 0 //picker view will be hidden at this point anyway
    }
}
