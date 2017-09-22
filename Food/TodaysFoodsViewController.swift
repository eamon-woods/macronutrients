//
//  TodaysFoodsViewController.swift
//  Food
//
//  Created by Eamon Woods on 8/8/17.
//
//

import UIKit

protocol TodaysFoodsViewControllerDelegate {
    var todaysFoods: [(Food,Double,String)] { get set } //set b/c user can delete foods in table view
}

class TodaysFoodsViewController: UIViewController {

    var todaysFoodsTableView: UITableView!
    var todaysFoodsViewControllerDelegate: TodaysFoodsViewControllerDelegate!
    var swipeFoodLeftToDeleteLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .lightGray
        title = "Today's Foods"
        swipeFoodLeftToDeleteLabel = UILabel(frame: CGRect(x: 5, y: view.frame.height - 60, width: revealViewController().rearViewRevealWidth - 5, height: 60))
        swipeFoodLeftToDeleteLabel.text = "Accidentally added a food? Swipe it left to delete."
        swipeFoodLeftToDeleteLabel.numberOfLines = 0
        swipeFoodLeftToDeleteLabel.lineBreakMode = .byWordWrapping
        todaysFoodsTableView = UITableView(frame: CGRect(x: 0, y: (navigationController?.navigationBar.frame.maxY)!, width: revealViewController().rearViewRevealWidth, height: view.frame.height - (navigationController?.navigationBar.frame.maxY)! - swipeFoodLeftToDeleteLabel.frame.height))
        todaysFoodsTableView.tableFooterView = UIView()
        todaysFoodsTableView.delegate = self
        todaysFoodsTableView.dataSource = self
        todaysFoodsTableView.allowsSelection = false
        
        view.addSubview(swipeFoodLeftToDeleteLabel)
        view.addSubview(todaysFoodsTableView)
    }

    override func viewWillAppear(_ animated: Bool) {
        todaysFoodsTableView.reloadData()
    }
    /*
    override func viewWillDisappear(_ animated: Bool) {
        let macrosVC = todaysFoodsViewControllerDelegate as! MacrosViewController
        macrosVC.addUpMacros()
        macrosVC.updateMacroLabels()
    }
     */
}

extension TodaysFoodsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let (food, quantity, measurement) = todaysFoodsViewControllerDelegate.todaysFoods[indexPath.row]
        cell.textLabel?.text = "\(food.name), quantity: \(quantity), measurement: \(measurement)"
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let (food, quantity, measurement) = todaysFoodsViewControllerDelegate.todaysFoods[indexPath.row]
        let strToDisplay = "\(food.name), quantity: \(quantity), measurement: \(measurement)"
        let maxCharsOnLine = 20.0 //20 is roughly number of characters on a line
        let numLines = ceil(Double(strToDisplay.characters.count) / maxCharsOnLine)
        return CGFloat(numLines * 20.0 + 20)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todaysFoodsViewControllerDelegate.todaysFoods.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            todaysFoodsViewControllerDelegate.todaysFoods.remove(at: indexPath.row)
            todaysFoodsTableView.deleteRows(at: [indexPath], with: .automatic)
            let macrosVC = todaysFoodsViewControllerDelegate as! MacrosViewController
            macrosVC.update()
        }
    }
}
