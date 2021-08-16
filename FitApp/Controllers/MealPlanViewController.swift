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
		tableView.register(UINib(nibName: K.NibName.addingTableViewCell, bundle: nil), forCellReuseIdentifier: K.CellId.addingCell)
		addBarButtonIcon()
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		callToViewModelForUIUpdate()
	}
}

extension MealPlanViewController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		mealViewModel.getMealsCount()
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.row == mealViewModel.meals!.count {
			let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.addingCell, for: indexPath) as! AddingTableViewCell
			cell.delegate = self
			return cell
		} else {
			let mealData = mealViewModel.meals![indexPath.row]
			let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.mealCell, for: indexPath) as! MealPlanTableViewCell
			cell.mealViewModel = self.mealViewModel
			cell.meal = mealData
			cell.indexPath = indexPath
			cell.selectionStyle = .none
			return cell
		}
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
		} else {
			updateDataSource()
		}
		mealViewModel.bindMealViewModelToController = {
			[unowned self] in
			Spinner.shared.stop()
			DispatchQueue.main.async {
				if let meals = self.mealViewModel.meals, meals.isEmpty {
					self.tableView.backgroundView = self.presentEmptyTableViewBackground(self.date)
				} else {
					self.tableView.backgroundView = nil
				}
				self.updateDataSource()
				self.tableView.reloadData()
			}
		}
	}
	private func presentEmptyTableViewBackground(_ date: Date) -> UIView {
		let messageText = "לחצו כאן ליצירת תפריט תזונה לתאריך ה- \(date.dateStringDisplay)"
		let noMealBackgroundView = TableViewEmptyView(text: messageText, hasTabBar: self.tabBarController?.tabBar.frame.size.height, presentingVC: self)
		
		noMealBackgroundView.delegate = self
		return noMealBackgroundView
	}
	private func presentAddMealAlert() {
		let addMealAlert = AddMealAlertView()
		addMealAlert.delegate = self
		addMealAlert.mealDate = date
		addMealAlert.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width,
									height: UIScreen.main.bounds.size.height)
		view.addSubview(addMealAlert)
	}
	
	@objc private func todayBarButtonItemTapped(_ sender: UIBarButtonItem) {
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
	@objc private func commentsBarButtonItemTapped(_ sender: UIBarButtonItem) {
		if let commentVC = storyboard?.instantiateViewController(identifier: K.ViewControllerId.commentsTableViewController) {
			self.navigationController?.pushViewController(commentVC, animated: true)
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
	
	func createNewMealButtonTapped() {
		Spinner.shared.show(view)
		tableView.backgroundView = nil
		mealViewModel.fetchData(date: date)
	}
}
extension MealPlanViewController: AddingTableViewCellDelegate {
	
	func didTapped() {
		if mealViewModel.checkIfCurrentMealIsDone() {
			presentAlert(withTitle: "הוספת ארוחת חריגה",
						 withMessage: "האם ברצונך להוסיף ארוחה לתפריט היום?",
						 options: "אישור", "ביטול") {
				
				selection in
				switch selection {
				case 0:
					self.presentAddMealAlert()
				default:
					break
				}
			}
		} else {
			presentAlert(withTitle: "הוספת ארוחת חריגה",
						 withMessage: "שמנו לב שלא סימנת את כל הארוחות היום, אולי בכלל אין צורך בארוחת חריגה :)",
						 options: "אישור", "ביטול") {
				
				selection in
				switch selection {
				case 0:
					self.presentAddMealAlert()
				default:
					break
				}
			}
		}
	}
}
extension MealPlanViewController: AddMealAlertViewDelegate {
	
	func didFinish(with: Meal) {
		mealViewModel.meals?.append(with)
		mealViewModel.updateMeals(for: date)
	}
}
