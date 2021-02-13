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
    private var selectedCellIndexPath: IndexPath?
    
    @IBOutlet weak var dateTextLabel: UILabel!
    @IBOutlet weak var dateLeftButton: UIButton!
    @IBOutlet weak var dateRightButton: UIButton!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateTextLabel.text = date.dateStringDisplay
//        tableView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.06)
        callToViewModelForUIUpdate()
		addBarButtonIcon()
    }
	
    @IBAction func changeDateButtons(_ sender: UIButton) {
		Spinner.shared.show(self.view)
		
		switch sender {
        case dateRightButton:
            date = date.add(1.days)
            mealViewModel.fetchMealsBy(date: date) { }
        case dateLeftButton:
            date = date.subtract(1.days)
            mealViewModel.fetchMealsBy(date: date) { }
        default:
            break
        }
        dateTextLabel.text = date.dateStringDisplay
        
        mealViewModel!.bindMealViewModelToController = {
			Spinner.shared.stop()
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
        cell.mealViewModel = self.mealViewModel
        cell.meal = mealData
        cell.delegate = self
        cell.indexPath = indexPath
        cell.selectionStyle = .none
        return cell
    }
}

extension MealPlanViewController {
    
    func updateDataSource() {
		Spinner.shared.stop()
        tableView.register(UINib(nibName: K.NibName.mealPlanTableViewCell, bundle: nil), forCellReuseIdentifier: K.CellId.mealCell)
        tableView.reloadData()
    }
    func callToViewModelForUIUpdate() {
		if let navView = navigationController?.view {
			Spinner.shared.show(navView)
		}
        mealViewModel = MealViewModel.shared
        if mealViewModel.meals == nil {
            mealViewModel.fetchData()
            mealViewModel.bindMealViewModelToController = {
				Spinner.shared.stop()
                self.updateDataSource()
            }
        } else {
			Spinner.shared.stop()
            updateDataSource()
		}
    }
	func addBarButtonIcon() {
		let button = UIButton(type: .system)
		let rightBarButton = UIBarButtonItem(customView: button)
		
		button.setTitle("הערות ", for: .normal)
		button.setImage(UIImage(systemName: "info.circle.fill"), for: .normal)
		button.addTarget(self, action: #selector(barButtonItemTapped), for: .touchUpInside)
		button.sizeToFit()

		self.navigationItem.rightBarButtonItem = rightBarButton
	}
	@objc func barButtonItemTapped(_ sender: UIBarButtonItem) {
		print("doSomething!")
	}
}

extension MealPlanViewController: MealPlanTableViewCellDelegate {
    
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
