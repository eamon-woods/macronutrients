//
//  SearchViewController.swift
//  Food
//
//  Created by Eamon Woods on 7/18/17.
//
//

import UIKit

protocol SearchViewControllerDelegate {
    func addFoodToTodaysFoods(food: Food, quantity: Double, measurement: String)
}

class SearchViewController: UIViewController, FoodDetailViewControllerDelegate {
    
    var food: Food?
    var searchBar: UISearchBar!
    var foodsTableView: UITableView!
    var seeMoreFoodsButton: UIButton!
    let searchService = SearchService()
    var foods: [Food]?
    var numFoodsDisplayed = 0
    var searchViewControllerDelegate: SearchViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Search"
        view.backgroundColor = UIColor.lightGray
        searchBar = UISearchBar(frame: CGRect(x: 0, y: (navigationController?.navigationBar.frame.maxY)!, width: view.frame.width, height: 50))
        searchBar.delegate = self
        foodsTableView = UITableView(frame: CGRect(x: 0, y: searchBar.frame.maxY, width: view.frame.width, height: view.frame.height-(navigationController?.navigationBar.frame.maxY)!-searchBar.frame.height-50))
        foodsTableView.dataSource = self
        foodsTableView.delegate = self
        foodsTableView.tableFooterView = UIView()
        
        seeMoreFoodsButton = UIButton(frame: CGRect(x: 0, y: foodsTableView.frame.maxY, width: 100, height: 50))
        seeMoreFoodsButton.center.x = view.center.x
        seeMoreFoodsButton.setTitle("SEE MORE", for: .normal)
        seeMoreFoodsButton.setTitleColor(.blue, for: .normal)
        seeMoreFoodsButton.addTarget(self, action: #selector(seeMoreButtonWasTapped), for: .touchUpInside)
        seeMoreFoodsButton.isHidden = true
        seeMoreFoodsButton.showsTouchWhenHighlighted = true
        
        view.addSubview(searchBar)
        view.addSubview(foodsTableView)
        view.addSubview(seeMoreFoodsButton)
    }
    
    func addFoodToTodaysFoods(food: Food, quantity: Double, measurement: String) {
        searchViewControllerDelegate?.addFoodToTodaysFoods(food: food, quantity: quantity, measurement: measurement)
    }
    
    func seeMoreButtonWasTapped() {
        numFoodsDisplayed = numFoodsDisplayed + 5
        if (foods?.count)! <= numFoodsDisplayed {
            //force unwrap is okay because it can only be tapped if we fetched foods
            seeMoreFoodsButton.isHidden = true
        }
        foodsTableView.reloadData()
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let searchString = searchBar.text else { return }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        searchService.getFoodsMatchingSearch(search: searchString) { (foods) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if foods.isEmpty {
                print("Could not read food JSON or no foods matched search")
            } else {
                self.foods = foods
                self.numFoodsDisplayed = 5 //initial amount of foods to display
                DispatchQueue.main.async {
                    if foods.count > self.numFoodsDisplayed {
                        self.seeMoreFoodsButton.isHidden = false
                    }
                    self.foodsTableView.reloadData()
                }
            }
        }
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let foodDetailViewController = FoodDetailViewController()
        foodDetailViewController.food = foods![indexPath.row] //force unwrap, if we're clicking on a row, we should always have a foods array with this index
        foodDetailViewController.foodDetailViewControllerDelegate = self
        navigationController?.pushViewController(foodDetailViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if let foods = foods {
            cell.textLabel?.text = foods[indexPath.row].name
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.lineBreakMode = .byWordWrapping
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let foods = foods {
            let name = foods[indexPath.row].name
            return CGFloat(ceil(Double(name.characters.count) / 40.0) * 20 + 20)
            //40 is number of characters on a line
        }
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let foods = foods {
            //because numFoodsDisplayed goes up in jumps and we don't want empty rows
            return min(foods.count, numFoodsDisplayed)
        }
        return numFoodsDisplayed
    }
    
}
