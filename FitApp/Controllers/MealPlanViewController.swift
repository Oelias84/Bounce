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
	private var showAddNewMealButton: Bool = false
	
	@IBOutlet weak var topBarView: BounceNavigationBarView!
	@IBOutlet weak var changeDateView: ChangeDateView!
	@IBOutlet weak var tableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		changeDateView.delegate = self
		tableView.register(UINib(nibName: K.NibName.addingTableViewCell, bundle: nil), forCellReuseIdentifier: K.CellId.addingCell)
		
		topBarView.delegate = self
		topBarView.nameTitle = "ארוחות"
		topBarView.isMotivationHidden = true
		topBarView.isDayWelcomeHidden = true
		topBarView.isBackButtonHidden = true
		topBarView.isDayWelcomeHidden = true
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		callToViewModelForUIUpdate()
		topBarView.setImage()
	}
	
	@IBAction private func todayButtonTapped(_ sender: UIButton) {
		date = Date()
		Spinner.shared.show(self.view)
		changeDateView.changeToCurrentDate()
		mealViewModel.fetchMealsBy(date: date) {
			[weak self] hasMeal in
			guard let self = self else { return }
			Spinner.shared.stop()
			if !hasMeal {
				self.showAddNewMealButton = true
			}
			self.tableView.reloadData()
		}
	}
}

extension MealPlanViewController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if showAddNewMealButton {
			return 1
		} else {
			return mealViewModel.getMealsCount()
		}
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.row == mealViewModel.meals!.count || showAddNewMealButton {
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
					self.showAddNewMealButton = true
				} else {
					self.showAddNewMealButton = false
				}
				self.tableView.backgroundView = nil
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
	private func presentAlert(withTitle title: String? = nil, withMessage message: String, options: (String)..., alertNumber: Int) {
		guard let window = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window else {
			return
		}
		let storyboard = UIStoryboard(name: "PopupAlertView", bundle: nil)
		let customAlert = storyboard.instantiateViewController(identifier: "PopupAlertView") as! PopupAlertView
		
		customAlert.providesPresentationContextTransitionStyle = true
		customAlert.definesPresentationContext = true
		customAlert.modalPresentationStyle = .overCurrentContext
		customAlert.modalTransitionStyle = .crossDissolve
		
		customAlert.delegate = self
		customAlert.titleText = title
		customAlert.messageText = message
		customAlert.alertNumber = alertNumber
		customAlert.okButtonText = options[0]
		
		switch options.count {
		case 1:
			customAlert.cancelButtonIsHidden = true
		case 2:
			customAlert.cancelButtonText = options[1]
		case 3:
			customAlert.cancelButtonText = options[1]
			customAlert.doNotShowText = options.last
		default:
			break
		}
		
		window.rootViewController?.present(customAlert, animated: true, completion: nil)
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
			if !hasMeal {
				self.showAddNewMealButton = true
			}
			self.tableView.reloadData()
		}
	}
}
extension MealPlanViewController: TableViewEmptyViewDelegate {
	
	func createNewMealButtonTapped() {
		return
	}
}
extension MealPlanViewController: AddingTableViewCellDelegate {
	
	func didTapped() {
		if showAddNewMealButton {
			presentAlert(withMessage: "האם ברצונך לבצע פעולה זו?", options: "אישור", "ביטול", alertNumber: 3)
		} else {
			if mealViewModel.checkIfCurrentMealIsDone() {
				presentAlert(withTitle: "הוספת ארוחת חריגה", withMessage: "האם ברצונך להוסיף ארוחה לתפריט היום?", options: "אישור", "ביטול", alertNumber: 1)
			} else {
				presentAlert(withTitle: "הוספת ארוחת חריגה", withMessage: "שמנו לב שלא סימנת את כל הארוחות היום, אולי בכלל אין צורך בארוחת חריגה :)", options: "אישור", "ביטול", alertNumber: 2)
			}
		}
	}
}
extension MealPlanViewController: PopupAlertViewDelegate {
	
	func okButtonTapped(alertNumber: Int, selectedOption: String?, textFieldValue: String?) {
		switch alertNumber {
		case 1:
			self.presentAddMealAlert()
		case 2:
			self.presentAddMealAlert()
		case 3:
			Spinner.shared.show(view)
			tableView.backgroundView = nil
			mealViewModel.fetchData(date: date)
		default:
			break
		}
	}
	func cancelButtonTapped(alertNumber: Int) {
		return
	}
	func thirdButtonTapped(alertNumber: Int) {
		return
	}
}
extension MealPlanViewController: AddMealAlertViewDelegate {
	
	func didFinish(with: Meal) {
		mealViewModel.meals?.append(with)
		mealViewModel.updateMeals(for: date)
	}
}
extension MealPlanViewController: BounceNavigationBarDelegate {
	
	func backButtonTapped() {}
}
