//
//  MealPlanViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 27/11/2020.
//

import UIKit

class MealPlanViewController: UIViewController {
        
    private var mealViewModel: MealViewModel!
    private var manager = ConsumptionManager()
    private let userData = UserProfile.shared
    private let date = Date()
    private var selectedCellIndexPath: IndexPath?
    
    @IBOutlet weak var dateRightButton: UIButton!
    @IBOutlet weak var dateTextLabel: UILabel!
    @IBOutlet weak var dateLeftButton: UIButton!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: K.NibName.mealPlanTableViewCell, bundle: nil), forCellReuseIdentifier: K.CellId.mealCell)
        mealViewModel = MealViewModel(Prefer: .breakfast, numberOfMeals: 3,
                                      protein: manager.getDayProtein,   carbs: manager.getDayCarbs, fat: manager.getDayFat)
    }
    @IBAction func changeDateButtons(_ sender: UIButton) {
        
        switch sender {
        case dateRightButton:
            ""
        case dateLeftButton:
            ""
        default:
            break
        }
    }
}

extension MealPlanViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        mealViewModel.meals.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mealData = mealViewModel.meals[indexPath.row]
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
            tableView.scrollToRow(at: cell, at: .bottom, animated: true)
        }
    }
}
