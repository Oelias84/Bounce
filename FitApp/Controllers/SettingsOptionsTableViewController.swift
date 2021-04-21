//
//  SettingsOptionsTableViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 28/01/2021.
//

import UIKit

enum SettingsContentType {
	
	case mostHungry
	case fitnessLevel
}

class SettingsOptionsTableViewController: UITableViewController {
	
	var contentType: SettingsContentType!
	
	private var hungerArray = ["בוקר", "צהריים", "ערב", "לא ידוע"]
	private var fitnessLevelArray = ["מתחיל", "בינוני", "מתקדם"]

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch contentType {
		case .mostHungry:
			return hungerArray.count
		case .fitnessLevel:
			return fitnessLevelArray.count
		default:
			return 0
		}
    }
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.settingsOptionCell)!
		switch contentType {
		case .mostHungry:
			cell.textLabel?.text = hungerArray[indexPath.row]
		case .fitnessLevel:
			cell.textLabel?.text = fitnessLevelArray[indexPath.row]
		default:
			break
		}
		return cell
	}
	override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		UIView()
	}
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		switch contentType {
		case .mostHungry:
			mealChange(hunger: indexPath.row)
		case .fitnessLevel:
			fitnessLevelChange(fitnessLevel: indexPath.row+1)
		default:
			break
		}
	}
}

extension SettingsOptionsTableViewController {
	
	private func mealChange(hunger: Int) {
		if hunger == 3 {
			UserProfile.defaults.mostHungry = nil
		} else {
			UserProfile.defaults.mostHungry = hunger+1
		}
		UserProfile.updateServer()
		navigationController?.popViewController(animated: true)
	}
	private func fitnessLevelChange(fitnessLevel: Int) {
		if let currentNumberOfWorkouts = UserProfile.defaults.weaklyWorkouts {
			
			switch fitnessLevel {
			case 1:
				if currentNumberOfWorkouts > 2 {
					presentFitnessAlert(fitnessLevel)
				} else {
					UpdateAndPopViewController(fitnessLevel)
				}
			case 2:
				if currentNumberOfWorkouts < 2 || currentNumberOfWorkouts > 3 {
					presentFitnessAlert(fitnessLevel)
				} else {
					UpdateAndPopViewController(fitnessLevel)
				}
			case 3:
				if currentNumberOfWorkouts < 3 {
					presentFitnessAlert(fitnessLevel)
				} else {
					UpdateAndPopViewController(fitnessLevel)
				}
			default:
				break
			}
			
		}
	}
	private func presentFitnessAlert(_ level: Int) {
		presentAlert(withTitle: "שינוי רמת קושי", withMessage: "שימי לב! בעקבות שינוי ברמת הקושי גם כמות האימונים תשתנה לכמות דיפולטיבית שאותה את תוכלי לשנות ממסך ההגדרות, האם ברצונך לאשר את השינוי?", options: "אישור", "ביטול") { selection in
			
			switch selection {
			case 0:
				switch level {
				case 1:
					UserProfile.defaults.weaklyWorkouts = 2
				case 2:
					UserProfile.defaults.weaklyWorkouts = 2
				case 3:
					UserProfile.defaults.weaklyWorkouts = 3
				default:
					break
				}
				self.UpdateAndPopViewController(level)
			case 1:
				self.navigationController?.popViewController(animated: true)
			default:
				break
			}
		}
	}
	private func UpdateAndPopViewController(_ level: Int) {
		UserProfile.defaults.fitnessLevel = level
		UserProfile.updateServer()
		navigationController?.popViewController(animated: true)
	}
}
