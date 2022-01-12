//
//  DishesTableViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 07/04/2021.
//

import UIKit

enum DishesState {
	
	case normal
	case exceptional
}

protocol DishesTableViewControllerDelegate {
	
	func didPickDish(name: String?)
}

class DishesTableViewController: UIViewController {
	
	var state: DishesState!
	var originalDish: Dish!

	private var dishes: [ServerDish]!
	private var otherDishes: [String]?
	private var selectedDish: String?
	private let mealViewModel = MealViewModel.shared
	private var indexPath: IndexPath?
	
	var delegate: DishesTableViewControllerDelegate?
	
	@IBOutlet weak var titleTextLabel: UILabel!
	@IBOutlet weak var tableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		configure()
	}
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.delegate?.didPickDish(name: self.selectedDish)
	}
	
	@IBAction func otherButtonAction(_ sender: Any) {
		
		changeOtherDishAlert()
	}
	@IBAction func cancelButtonAction(_ sender: Any) {
		
		dismiss(animated: true)
	}
}

// MARK: - Delegates
extension DishesTableViewController: UITableViewDataSource, UITableViewDelegate {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return (otherDishes == nil || otherDishes?.count == 0) ? 1 : 2
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		switch section {
		case 0:
			return dishes.count
		case 1:
			return otherDishes!.count
		default:
			return 0
		}
	}
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return section == 1 ? "אחר" : nil
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.dishesCell, for: indexPath)
		
		switch indexPath.section {
		case 0:
			cell.textLabel?.text = dishes[indexPath.row].name
		case 1:
			cell.textLabel?.text = otherDishes![indexPath.row]
		default:
			break
		}
		return cell
	}
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		
		switch indexPath.section {
		case 1:
			return true
		default:
			return false
		}
	}
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if (editingStyle == .delete) {
			self.otherDishes?.remove(at: indexPath.row)
			UserProfile.defaults.otherDishes?.remove(at: indexPath.row)
			self.tableView.beginUpdates()
			self.tableView.deleteRows(at: [indexPath], with: .middle)
			
			if otherDishes?.count == 0 {
				self.tableView.deleteSections(IndexSet(integer: 1), with: .bottom)
			}
			self.tableView.endUpdates()
		}
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		self.indexPath = indexPath
		switch indexPath.section {
		case 0:
			self.selectedDish = self.dishes[indexPath.row].name
		case 1:
			self.selectedDish = self.otherDishes![indexPath.row]
		default:
			break
		}
		changeDishAlert()
	}
}
extension DishesTableViewController: PopupAlertViewDelegate {
	
	func okButtonTapped(alertNumber: Int, selectedOption: String?, textFieldValue: String?) {
		self.selectedDish = nil
		if let indexPath = indexPath {
			self.tableView.deselectRow(at: indexPath, animated: true)
		}
	}
	func cancelButtonTapped(alertNumber: Int) {
		dismiss(animated: true)
	}	
	func thirdButtonTapped(alertNumber: Int) {
		return
	}
}

// MARK: - Functions
extension DishesTableViewController {
	
	private func configure() {
		dishes = mealViewModel.mealManager.getDishesFor(type: originalDish.type)
		
		titleTextLabel.text = "מנות " + originalDish.printDishType
		if let otherDishes = UserProfile.defaults.otherDishes {
			self.otherDishes = otherDishes
			DispatchQueue.main.async {
				[unowned self] in
				self.tableView.reloadData()
			}
		}
	}
	private func changeDishAlert() {
		guard let selectedDish = self.selectedDish else { return }
		
		switch state {
		case .normal:
			presentAlert(withTitle: "החלפת מנה" , withMessage: "האם ברצונך להחליף \nאת-\(self.originalDish.getDishName)\n ב-\(selectedDish)", options: "ביטול", "אישור")
		case .exceptional:
			dismiss(animated: true)
		default:
			break
		}
	}
	private func changeOtherDishAlert() {
		let alert = UIAlertController(title: "הזנת מנה", message: "אנא הזינו את שם המנה הרצויה ולאחר מכן אישור בכדי לבצע את ההחלפה", preferredStyle: .alert)
		
		alert.addTextField { textField in
			textField.placeholder = "הזינו את שם המנה"
		}
		alert.addAction(UIAlertAction(title: "אישור", style: .default) { _ in
			guard let textField = alert.textFields?[0] ,let otherDishText = textField.text else { return }
			
			if UserProfile.defaults.otherDishes == nil {
				UserProfile.defaults.otherDishes = [otherDishText]
			} else {
				UserProfile.defaults.otherDishes?.append(otherDishText)
			}
			self.selectedDish = textField.text
			self.dismiss(animated: true)
		})
		alert.addAction(UIAlertAction(title: "ביטול", style: .cancel) { _ in
			self.selectedDish = nil
		})
		present(alert, animated: true)
	}
	private func presentAlert(withTitle title: String? = nil, withMessage message: String, options: (String)...) {
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
		customAlert.okButtonText = options[0]
		customAlert.cancelButtonText = options[1]
		
		if options.count == 3 {
			customAlert.doNotShowText = options.last
		}
		window.rootViewController?.present(customAlert, animated: true, completion: nil)
	}
}
