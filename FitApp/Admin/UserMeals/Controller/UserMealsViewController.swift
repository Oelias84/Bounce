//
//  UserMealsViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 04/06/2022.
//

import UIKit

class UserMealsViewController: UIViewController {
	
	var viewModel: UserMealsViewModel!

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var changeDateView: ChangeDateView!

    override func viewDidLoad() {
        super.viewDidLoad()

		setupView()
		setupBinders()
    }
	
	@IBAction func todayButtonAction(_ sender: UIBarButtonItem) {
		viewModel.fetchMealsBy(date: Date())
		changeDateView.changeToCurrentDate()
	}
}

//MARK: - Functions
extension UserMealsViewController {
	
	fileprivate func setupBinders() {
		viewModel.meals.bind {
			meals in
			
			if let meals = meals {
				Spinner.shared.stop()
				self.tableView.reloadData()
				self.tableView.backgroundView = meals.isEmpty ? self.presentEmptyTableViewBackground() : nil
			}
		}
	}
	fileprivate func setupView() {
		Spinner.shared.show(view)
		changeDateView.delegate = self
		tableView.register(UINib(nibName: K.NibName.userMealTableViewCell, bundle: nil), forCellReuseIdentifier: K.CellId.adminUserMealCell)
	}
}

//MARK: - Delegates
extension UserMealsViewController: UITableViewDelegate, UITableViewDataSource  {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.getNumberOfMeals
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let mealData = viewModel.getCellForRow(at: indexPath.row)
		let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.adminUserMealCell, for: indexPath) as! UserMealTableViewCell
		
		cell.meal = mealData
		return cell
	}
}

extension UserMealsViewController: ChangeDateViewDelegate {
	
	 func dateDidChange(_ date: Date) {
		viewModel.fetchMealsBy(date: date)
	}
	fileprivate func presentEmptyTableViewBackground() -> UIView {
		let messageText = "נראה כי לא נוצרו ארוחות ליום זה"
		let noMealsView = TableViewEmptyView(text: messageText, hasTabBar: self.tabBarController?.tabBar.frame.size.height, presentingVC: self)

		noMealsView.backgroundView.backgroundColor = .red
		return noMealsView
	}
}
