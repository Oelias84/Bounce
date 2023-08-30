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
	
	func didDissmisView()
	func cancelButtonTapped()
	func didPickDish(name: String?)
}

class DishesTableViewController: UIViewController {
	
	var state: DishesState!
	
	var type: DishType!
	var originalDishName: String!
	
	private var dishes: [ServerDish]!
    
    private var otherCarbDishes: [String] = []
    private var otherFatDishes: [String] = []
    private var otherProtainDishes: [String] = []

    private var selectedDish: String?
	private var indexPath: IndexPath?
	private let mealViewModel = MealViewModel.shared
	
	var delegate: DishesTableViewControllerDelegate?
	
	@IBOutlet weak var titleTextLabel: UILabel!
	@IBOutlet weak var tableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
        
		configure()
	}
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
        
		delegate?.didDissmisView()
	}
	
	@IBAction func otherButtonAction(_ sender: Any) {
		presentAlert(withTitle: "הזנת מנה" , withMessage: "אנא הזינו את שם המנה הרצויה ולאחר מכן אישור בכדי לבצע את ההחלפה", options: "אישור", "ביטול", alertNumber: 1)
	}
	@IBAction func cancelButtonAction(_ sender: Any) {
		delegate?.cancelButtonTapped()
		dismiss(animated: true)
	}
}

// MARK: - Delegates
extension DishesTableViewController: UITableViewDataSource, UITableViewDelegate {
	
	func numberOfSections(in tableView: UITableView) -> Int {
        getDishesCountFor() == 0 ? 1 : 2
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		switch section {
		case 0:
			return dishes.count
		case 1:
			return getDishesCountFor()
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
            cell.textLabel?.text = getOtherDish(at: indexPath.row)
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
            removeOtherDish(at: indexPath.row)
			
            tableView.beginUpdates()
			tableView.deleteRows(at: [indexPath], with: .middle)
			
			if getDishesCountFor() == 0 {
				tableView.deleteSections(IndexSet(integer: 1), with: .bottom)
			}
            
			tableView.endUpdates()
		}
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.indexPath = indexPath
		
        switch indexPath.section {
		case 0:
			selectedDish = self.dishes[indexPath.row].name
			delegate?.didPickDish(name: selectedDish)
		case 1:
            selectedDish = getOtherDish(at: indexPath.row)
		default:
			break
		}
		changeDishAlert()
	}
}
extension DishesTableViewController: PopupAlertViewDelegate {
	
	func thirdButtonTapped(alertNumber: Int) {
		return
	}
	func cancelButtonTapped(alertNumber: Int) {
		dismiss(animated: true)
		self.selectedDish = nil
	}
	func okButtonTapped(alertNumber: Int, selectedOption: String?, textFieldValue: String?) {
		
		switch alertNumber {
		case 0:
			if let indexPath = indexPath {
                tableView.deselectRow(at: indexPath, animated: true)
                
				dismiss(animated: true) {
                    Spinner.shared.show()

					self.delegate?.didPickDish(name: self.selectedDish)
					self.dismiss(animated: true)
				}
			}
		case 1:
			if let text = textFieldValue, text != "" {
                
                addOtherDish(name: text)
                
				dismiss(animated: true) {
                    Spinner.shared.show()

					self.delegate?.didPickDish(name: text)
					self.dismiss(animated: true)
				}
			}
		default:
			return
		}
	}
}

// MARK: - Functions
extension DishesTableViewController {
    
    private func getDishesCountFor() -> Int {
        switch self.type {
        case .protein:
            return otherProtainDishes.count
        case .carbs:
            return otherCarbDishes.count
        case .fat:
            return otherFatDishes.count
        case .none:
            return 0
        }
    }
    private func getOtherDish(at row: Int) -> String {
        switch type {
        case .protein:
            return otherProtainDishes[row]
        case .carbs:
            return otherCarbDishes[row]
        case .fat:
            return otherFatDishes[row]
        case .none:
            return ""
        }
    }
    private func addOtherDish(name: String) {
        switch type {
        case .protein:
            if UserProfile.defaults.otherProtainDishes == nil {
                UserProfile.defaults.otherProtainDishes = [name]
            } else {
                UserProfile.defaults.otherProtainDishes?.append(name)
            }
            otherProtainDishes.append(name)
        case .carbs:
            if UserProfile.defaults.otherCarbDishes == nil {
                UserProfile.defaults.otherCarbDishes = [name]
            } else {
                UserProfile.defaults.otherCarbDishes?.append(name)
            }
            otherCarbDishes.append(name)
        case .fat:
            if UserProfile.defaults.otherFatDishes == nil {
                UserProfile.defaults.otherFatDishes = [name]
            } else {
                UserProfile.defaults.otherFatDishes?.append(name)
            }
            otherFatDishes.append(name)
        case .none:
            break
        }
    }
    private func removeOtherDish(at row: Int) {
        switch self.type {
        case .protein:
            otherProtainDishes.remove(at: row)
            UserProfile.defaults.otherProtainDishes?.remove(at: row)
        case .carbs:
            otherCarbDishes.remove(at: row)
            UserProfile.defaults.otherCarbDishes?.remove(at: row)
        case .fat:
            otherFatDishes.remove(at: row)
            UserProfile.defaults.otherFatDishes?.remove(at: row)
        case .none:
            break
        }
    }
    
	private func configure() {
		dishes = mealViewModel.mealManager.getDishesFor(type: type)
		titleTextLabel.text = "מנות " + type.rawValue
		
        if let otherFatDishes = UserProfile.defaults.otherFatDishes {
			self.otherFatDishes = otherFatDishes
		}
        if let otherCarbDishes = UserProfile.defaults.otherCarbDishes {
            self.otherCarbDishes = otherCarbDishes
        }
        if let otherProtainDishes = UserProfile.defaults.otherProtainDishes {
            self.otherProtainDishes = otherProtainDishes
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
	}
	private func changeDishAlert() {
		guard let selectedDish = self.selectedDish, let originalDishName = originalDishName else { return }
		
		switch state {
		case .normal:
			presentAlert(withTitle: "החלפת מנה" , withMessage: "האם ברצונך להחליף \nאת- \(originalDishName)\n ב- \(selectedDish)", options: "אישור", "ביטול", alertNumber: 0)
		case .exceptional:
			self.delegate?.didPickDish(name: selectedDish)
			dismiss(animated: true)
		default:
			break
		}
	}
	private func changeOtherDishAlert() {
		presentAlert(withTitle: "הזנת מנה" , withMessage: "אנא הזינו את שם המנה הרצויה ולאחר מכן אישור בכדי לבצע את ההחלפה", options: "אישור", "ביטול", alertNumber: 1)
	}
	private func presentAlert(withTitle title: String? = nil, withMessage message: String, options: (String)..., alertNumber: Int) {
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
		if alertNumber == 1 { customAlert.popupType = .textField }

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
		
		present(customAlert, animated: true)
	}
}
