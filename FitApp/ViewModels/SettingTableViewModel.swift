//
//  SettingTableViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 09/05/2021.
//

import UIKit

class SettingTableViewModel {
	
	var vc: UITableViewController!
	var contentType: SettingsContentType!
	private let notificationManager = LocalNotificationManager.shared
	
	private var tableViewTitle: String!
	private var tableViewItemArray = [String]()
	private var notificationsArray: [Notification]? {
		didSet {
			bindNotificationViewModelToController()
		}
	}
	
	var bindNotificationViewModelToController : (() -> ()) = {}
	
	init(contentType: SettingsContentType, for vc: UITableViewController) {
		
		self.contentType = contentType
		self.vc = vc

		setTitle()
		setTableView()
		notificationManager.bindNotificationsManagerToController = {
			self.notificationsArray = self.notificationManager.getNotifications()
		}
	}
	
	//MARK: - Setters
	private func setTitle() {
		
		switch contentType {
		case .fitnessLevel:
			tableViewTitle = "רמת כושר"
		case .mostHungry:
			tableViewTitle = "מתי אני הכי רעבה"
		case .notifications:
			tableViewTitle = "התראות"
		default:
			break
		}
	}
	private func setTableView() {
		
		switch contentType {
		case .fitnessLevel:
			tableViewItemArray = ["מתחיל", "בינוני", "מתקדם"]
		case .mostHungry:
			tableViewItemArray = ["בוקר", "צהריים", "ערב", "לא ידוע"]
		case .notifications:
			tableViewItemArray = ["התראות שקילה", "התראות שתייה"]
		case .none:
			break
		}
	}
	
	//MARK: - Getters
	func getVCTitle() -> String {
		return tableViewTitle
	}
	func getNumberOfSections() -> Int {
		return (contentType == .notifications) ? 2 : 1
	}
	func getCellTitle(at index: Int) -> String {
		return tableViewItemArray[index]
	}
	func getNotificationCell(at index: Int) -> Notification {
		return notificationsArray![index]
	}
	func getNumberOfRows() -> Int {
		return tableViewItemArray.count
	}
	func getNumberOfNotificationsRows() -> Int {
		return notificationsArray?.count ?? 0
	}
	func getNotificationTitleCellAccessoryView(at index: Int) -> UIView {
		
		switch index {
		case 0:
			if let scaleNotification = notificationsArray?.filter({ $0.id == "weightNotification" }) {
				if scaleNotification.count > 0 {
					return UIImageView(image: UIImage(systemName: "square.and.pencil"))
				}
			} else {
				return UIImageView(image: UIImage(systemName: "plus"))
			}
		default:
			break
		}
		return UIImageView(image: UIImage(systemName: "plus"))
	}
	func didSelect(at indexPath: IndexPath) {
		
		switch contentType {
		case .mostHungry:
			mealChange(at: indexPath.row)
		case .fitnessLevel:
			fitnessLevelChange(at: indexPath.row+1)
		case .notifications:
			if indexPath.section == 0 {
				notificationsPressed(at: indexPath.row)
			}
		default:
			break
		}
	}
	
	func mealChange(at hunger: Int) {
		
		if hunger == 3 {
			UserProfile.defaults.mostHungry = nil
		} else {
			UserProfile.defaults.mostHungry = hunger+1
		}
		UserProfile.updateServer()
		vc.navigationController?.popViewController(animated: true)
	}
	func presentFitnessAlert(_ level: Int) {
		vc.presentAlert(withTitle: "שינוי רמת קושי", withMessage: "שימי לב! בעקבות שינוי ברמת הקושי גם כמות האימונים תשתנה לכמות דיפולטיבית שאותה את תוכלי לשנות ממסך ההגדרות, האם ברצונך לאשר את השינוי?", options: "אישור", "ביטול") { selection in
			
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
				self.updateAndPopViewController(level)
			case 1:
				self.vc.navigationController?.popViewController(animated: true)
			default:
				break
			}
		}
	}
	func notificationsPressed(at row: Int) {
		
		switch row {
		case 0:
			notificationManager.showNotificationAlert(withTitle: K.Notifications.alertWeightTitle,
													  withMessage: K.Notifications.alertWeightMessage, type: .weightNotification, vc: vc)
		case 1:
			addWaterNotificationCell()
		default:
			break
		}
//		UserProfile.updateServer()
		vc.navigationController?.popViewController(animated: true)
	}
	func fitnessLevelChange(at fitnessLevel: Int) {
		if let currentNumberOfWorkouts = UserProfile.defaults.weaklyWorkouts {
			
			switch fitnessLevel {
			case 1:
				if currentNumberOfWorkouts > 2 {
					presentFitnessAlert(fitnessLevel)
				} else {
					updateAndPopViewController(fitnessLevel)
				}
			case 2:
				if currentNumberOfWorkouts < 2 || currentNumberOfWorkouts > 3 {
					presentFitnessAlert(fitnessLevel)
				} else {
					updateAndPopViewController(fitnessLevel)
				}
			case 3:
				if currentNumberOfWorkouts < 3 {
					presentFitnessAlert(fitnessLevel)
				} else {
					updateAndPopViewController(fitnessLevel)
				}
			default:
				break
			}
			
		}
	}
	
	func removeNotification(at: IndexPath) {
		if let notificationToRemove = notificationsArray?[at.row] {
			notificationManager.removeNotification(notificationToRemove)
			notificationsArray?.remove(at: at.row)
		}
	}
	func updateNotification() {
		self.notificationsArray = notificationManager.getNotifications()
	}
	private func updateAndPopViewController(_ level: Int) {
		UserProfile.defaults.fitnessLevel = level
		UserProfile.updateServer()
		vc.navigationController?.popViewController(animated: true)
	}
	private func addWaterNotificationCell() {
		notificationManager.showNotificationAlert(withTitle: K.Notifications.alertWaterTitle, withMessage: K.Notifications.alertWeterMessage, type: .waterNotification, vc: vc)
		// Add Animation Here
		
//		vc.tableView.beginUpdates()
//		vc.tableView.insertRows(at: [IndexPath(row: self.notificationsArray!.count-1, section: 1)], with: .automatic)
//		vc.tableView.endUpdates()
	}
}
