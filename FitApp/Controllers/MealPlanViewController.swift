//
//  MealPlanViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 27/11/2020.
//

import UIKit


class MealPlanViewController: UIViewController {
    
    private var date = Date()
    private var mealViewModel: MealViewModel!
    private let userData = UserProfile.shared
    private var selectedCellIndexPath: IndexPath?
    
    @IBOutlet weak var dateTextLabel: UILabel!
    @IBOutlet weak var dateLeftButton: UIButton!
    @IBOutlet weak var dateRightButton: UIButton!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateTextLabel.text = date.dateStringDisplay
        callToViewModelForUIUpdate()
    }
    
    @IBAction func changeDateButtons(_ sender: UIButton) {
        showSpinner()
        switch sender {
        case dateRightButton:
            date = date.add(1.days)
            mealViewModel.fetchMealsBy(date: date)
        case dateLeftButton:
            date = date.subtract(1.days)
            mealViewModel.fetchMealsBy(date: date)
        default:
            break
        }
        dateTextLabel.text = date.dateStringDisplay
        self.mealViewModel!.bindMealViewModelToController = {
            self.stopSpinner()
            self.updateDataSource()
        }
    }
}

extension MealPlanViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let meals = mealViewModel!.meals {
            return meals.count
        } else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mealData = mealViewModel?.meals?[indexPath.row]
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
    func update() {
        mealViewModel.updateMeals(for: date)
    }
}

extension MealPlanViewController {
    
    func updateDataSource() {
        stopSpinner()
        tableView.register(UINib(nibName: K.NibName.mealPlanTableViewCell, bundle: nil), forCellReuseIdentifier: K.CellId.mealCell)
        self.tableView.reloadData()
    }
    func callToViewModelForUIUpdate() {
        showSpinner()
        self.mealViewModel = MealViewModel()
        
        self.mealViewModel!.bindMealViewModelToController = {
            self.updateDataSource()
        }
    }
}
