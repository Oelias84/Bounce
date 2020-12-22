//
//  MealPlanViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 27/11/2020.
//

import UIKit

class MealPlanViewController: UIViewController {
    
    var mealArray: [Meal] = []
    var selectedCellIndexPath: IndexPath?

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dishes1 = [Dish(name: "כנפיים", type:.carbs, amount: 2), Dish(name: "קבב", type:.fat, amount: 2)]
        let dishes2 = [Dish(name: "חביתה", type:.fat, amount: 3)]
        let dishes3 = [Dish(name: "דגים", type:.protein, amount: 2), Dish(name: "סטייק", type:.protein, amount: 2), Dish(name: "חזה עוף", type:.fat, amount: 3)]
        let dishes4 = [Dish(name: "דגים", type:.protein, amount: 2)]
        let dishes5 = [Dish(name: "ביצה קשה", type:.protein, amount: 5), Dish(name: "סטייק", type:.protein, amount: 4), Dish(name: "חזה עוף", type:.carbs, amount: 1)]

        let meals1 = Meal(name: "ארוחת בוקר", dishes: dishes1)
        let meals3 = Meal(name: "ארוחת ביניים", dishes: dishes2)
        let meals2 = Meal(name: "ארוחת צהריים", dishes: dishes3)
        let meals4 = Meal(name: "ארוחת ביניים", dishes: dishes4)
        let meals5 = Meal(name: "ארוחת ערב", dishes: dishes5)
        
        mealArray = [meals1, meals3, meals2, meals4, meals5]
        
        tableView.register(UINib(nibName: K.NibName.mealPlanTableViewCell, bundle: nil), forCellReuseIdentifier: K.CellId.mealCell)
    }
}

extension MealPlanViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        mealArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mealData = mealArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.mealCell, for: indexPath) as! MealPlanTableViewCell
        
        cell.meal = mealData
        cell.delegate = self
        cell.indexPath = indexPath
        cell.selectionStyle = .none
        return cell
    }
}

extension MealPlanViewController: MealPlanTableViewCellDelegate  {
    
    func detailTapped(cell: IndexPath) {
        let selectedCell = tableView.cellForRow(at: cell) as! MealPlanTableViewCell
        
        tableView.beginUpdates()
        selectedCell.dishesHeadLineStackView.isHidden.toggle()
        selectedCell.dishStackView.isHidden.toggle()
        selectedCellIndexPath = cell
        tableView.endUpdates()
        if selectedCellIndexPath != nil {
            tableView.scrollToRow(at: cell, at: .none, animated: true)
        }
    }
}
