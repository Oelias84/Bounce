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
    
	@IBOutlet weak var dateTextLabel: UILabel!
	@IBOutlet weak var backwardDateButtonView: UIView!
	@IBOutlet weak var backwardDateButton: UIButton!
	@IBOutlet weak var forwardDateButtonView: UIView!
    @IBOutlet weak var forwardDateButton: UIButton!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

		setupView()
		addBarButtonIcon()
        callToViewModelForUIUpdate()
    }
	
    @IBAction func changeDateButtons(_ sender: UIButton) {
		Spinner.shared.show(self.view)
		
		switch sender {
        case forwardDateButton:
            date = date.add(1.days)
			mealViewModel.fetchMealsBy(date: date) {
				[weak self] hasMeal in
				guard let self = self else { return }
				self.tableView.backgroundView = hasMeal ? nil : self.presentEmptyTableViewBackground(self.date)
			}
        case backwardDateButton:
            date = date.subtract(1.days)
            mealViewModel.fetchMealsBy(date: date) {
				[weak self] hasMeal in
				guard let self = self else { return }
				self.tableView.backgroundView = hasMeal ? nil : self.presentEmptyTableViewBackground(self.date)
			}
        default:
            break
        }
		forwardDateButton.isEnabled = date.onlyDate.isEarlier(than: Date().onlyDate)
		forwardDateButton.alpha = forwardDateButton.isEnabled ? 1 : 0.2
		dateTextLabel.text = date.dateStringDisplay + " " + date.displayDayName

        mealViewModel.bindMealViewModelToController = {
			Spinner.shared.stop()
            self.updateDataSource()
        }
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
    
	private func setupView() {
		forwardDateButton.isEnabled = false
		dateTextLabel.text = date.dateStringDisplay + " " + date.displayDayName
		forwardDateButton.alpha = forwardDateButton.isEnabled ? 1 : 0.2

		backwardDateButtonView.buttonShadow()
		forwardDateButtonView.buttonShadow()
	}
	private func addBarButtonIcon() {
		let comments = UIButton(type: .system)
		let today = UIButton(type: .system)
		let rightBarButton = UIBarButtonItem(customView: today)
		let leftBarButton = UIBarButtonItem(customView: comments)

		
		comments.setTitle("הערות ", for: .normal)
		comments.setImage(UIImage(systemName: "info.circle.fill"), for: .normal)
		comments.addTarget(self, action: #selector(barButtonItemTapped), for: .touchUpInside)
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
		tableView.reloadData()
	}
	private func callToViewModelForUIUpdate() {
		if let navView = navigationController?.view {
			Spinner.shared.show(navView)
		}
		if mealViewModel.meals == nil {
			mealViewModel.fetchData()
			mealViewModel.bindMealViewModelToController = {
				Spinner.shared.stop()
				self.updateDataSource()
			}
		} else {
			Spinner.shared.stop()
			self.updateDataSource()
			mealViewModel.bindMealViewModelToController = {
				self.tableView.reloadData()
			}
		}
	}
	private func presentEmptyTableViewBackground(_ date: Date) -> UIView {
		let messageText = "לחצו כאן ליצירת תפריט תזונה לתאריך ה- \(date.dateStringDisplay)"
		let noMealBackgroundView = TableViewEmptyView(text: messageText, hasTabBar: self.tabBarController?.tabBar.frame.size.height)
		
		noMealBackgroundView.delegate = self
		return noMealBackgroundView
	}
	@objc func barButtonItemTapped(_ sender: UIBarButtonItem) {
		if let commentVC = storyboard?.instantiateViewController(identifier: K.ViewControllerId.commentsViewController) {
			present(commentVC, animated: true)
		}
	}
	@objc func todayBarButtonItemTapped(_ sender: UIBarButtonItem) {
		date = Date()
		mealViewModel.fetchMealsBy(date: date) {_ in}
		dateTextLabel.text = date.dateStringDisplay + " " + date.displayDayName
	}
}

extension MealPlanViewController: TableViewEmptyViewDelegate {

	func buttonTapped() {
		Spinner.shared.show(view)
		mealViewModel.fetchData(date: date)
	}
}
