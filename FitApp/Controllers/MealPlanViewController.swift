//
//  MealPlanViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 27/11/2020.
//

import UIKit


class MealPlanViewController: UIViewController {
	
	private var date = Date()
	private var mealViewModel = MealViewModel.shared
	private var selectedCellIndexPath: IndexPath?
		
	@IBOutlet weak var changeDateView: ChangeDateView!
	@IBOutlet weak var tableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		changeDateView.delegate = self
		addBarButtonIcon()
		callToViewModelForUIUpdate()
	}
}

extension MealPlanViewController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let meals = mealViewModel.meals {
			return meals.count
		} else {
			return 0
		}
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let mealData = mealViewModel.meals?[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.mealCell, for: indexPath) as! MealPlanTableViewCell
		cell.mealViewModel = self.mealViewModel
		cell.meal = mealData
		cell.indexPath = indexPath
		cell.selectionStyle = .none
		return cell
	}
}

extension MealPlanViewController {
	
	private func addBarButtonIcon() {
		let comments = UIButton(type: .system)
		let today = UIButton(type: .system)
		let rightBarButton = UIBarButtonItem(customView: today)
		let leftBarButton = UIBarButtonItem(customView: comments)
		
		comments.setTitle("הערות ", for: .normal)
		comments.setImage(UIImage(systemName: "info.circle.fill"), for: .normal)
		comments.addTarget(self, action: #selector(commentsBarButtonItemTapped), for: .touchUpInside)
		comments.sizeToFit()
		
		today.setTitle(" היום", for: .normal)
		today.setImage(UIImage(systemName: "calendar"), for: .normal)
		today.addTarget(self, action: #selector(todayBarButtonItemTapped), for: .touchUpInside)
		today.semanticContentAttribute = .forceLeftToRight
		today.sizeToFit()
		
		navigationItem.rightBarButtonItem = rightBarButton
		navigationItem.leftBarButtonItem = leftBarButton
	}
	private func updateDataSource() {
		Spinner.shared.stop()
		tableView.register(UINib(nibName: K.NibName.mealPlanTableViewCell, bundle: nil), forCellReuseIdentifier: K.CellId.mealCell)
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}
	}
	private func callToViewModelForUIUpdate() {
		if let navView = navigationController?.view {
			Spinner.shared.show(navView)
		}
		if mealViewModel.meals == nil {
			mealViewModel.fetchData()
			mealViewModel.bindMealViewModelToController = {
				[weak self] in
				guard let self = self else { return }
				Spinner.shared.stop()
				self.updateDataSource()
			}
		} else {
			Spinner.shared.stop()
			self.updateDataSource()
			mealViewModel.bindMealViewModelToController = {
				[weak self] in
				guard let self = self else { return }
				DispatchQueue.main.async {
					self.tableView.reloadData()
				}
			}
		}
	}
	private func presentEmptyTableViewBackground(_ date: Date) -> UIView {
		let messageText = "לחצו כאן ליצירת תפריט תזונה לתאריך ה- \(date.dateStringDisplay)"
		let noMealBackgroundView = TableViewEmptyView(text: messageText, hasTabBar: self.tabBarController?.tabBar.frame.size.height)
		
		noMealBackgroundView.delegate = self
		return noMealBackgroundView
	}
	
	@objc func commentsBarButtonItemTapped(_ sender: UIBarButtonItem) {
		if let commentVC = storyboard?.instantiateViewController(identifier: K.ViewControllerId.commentsTableViewController) {
			self.navigationController?.pushViewController(commentVC, animated: true)
		}
	}
	@objc func todayBarButtonItemTapped(_ sender: UIBarButtonItem) {
		date = Date()
		Spinner.shared.show(self.view)
		changeDateView.changeToCurrentDate()
		mealViewModel.fetchMealsBy(date: date) {
			[weak self] hasMeal in
			guard let self = self else { return }
			Spinner.shared.stop()
			self.tableView.backgroundView = hasMeal ? nil : self.presentEmptyTableViewBackground(self.date)
		}
	}
}

//MARK: - Delegates
extension MealPlanViewController: ChangeDateViewDelegate {
	
	func dateDidChange(_ date: Date) {
		Spinner.shared.show(self.view)
		self.date = date
		mealViewModel.fetchMealsBy(date: date) {
			[weak self] hasMeal in
			guard let self = self else { return }
			Spinner.shared.stop()
			self.tableView.backgroundView = hasMeal ? nil : self.presentEmptyTableViewBackground(self.date)
		}
	}
}
extension MealPlanViewController: TableViewEmptyViewDelegate {
	
	func buttonTapped() {
		Spinner.shared.show(view)
		mealViewModel.fetchData(date: date)
	}
}
