//
//  SettingsViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 23/01/2021.
//

import UIKit

class SettingsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		switch indexPath.section {
		
		case 0:
			personalDetailsTappedAt(indexPath.row)
		case 1:
			nutritionDetailsTappedAt(indexPath.row)
		case 2:
			fitnessLevelDetailsTappedAt(indexPath.row)
		case 3:
			systemDetailsTappedAt(indexPath.row)
		default:
			break
		}
		
	}
}

extension SettingsViewController {
	
	func personalDetailsTappedAt(_ row: Int) {
		let storyboard = UIStoryboard(name: K.StoryboardName.questionnaire, bundle: nil)
		switch row {
		case 0:
			let fatPrecentVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.questionnaireThird)
			navigationController?.pushViewController(fatPrecentVC, animated: true)
		case 1:
			""
		default:
			break
		}
	}
	func nutritionDetailsTappedAt(_ row: Int) {
		switch row {
		case 0:
			""
		case 1:
			""
		default:
			break
		}
	}
	func fitnessLevelDetailsTappedAt(_ row: Int) {
		switch row {
		case 0:
			""
		case 1:
			""
			
		default:
			break
		}
	}
	func systemDetailsTappedAt(_ row: Int) {
		switch row {
		case 0:
			""
			
		default:
			break
		}
	}
}
