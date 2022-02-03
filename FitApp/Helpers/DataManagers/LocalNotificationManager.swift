//
//  LocalNotificationManager.swift
//  FitApp
//
//  Created by iOS Bthere on 15/01/2021.
//

import UIKit
import UserNotifications

enum NotificationTypes: String {
	
	case waterNotification
	case weightNotification
	case mealNotification
}

class LocalNotificationManager {
	
	static let shared = LocalNotificationManager()
	
	private var currentNotification: [Notification]? {
		didSet {
			bindNotificationsManagerToController()
		}
	}
	private var postNotifications: Set<Notification> = Set<Notification>()
	
	var bindNotificationsManagerToController: (() -> ()) = {}
	
	private init() {
		
		getScheduledNotifications()
	}
	
	func getNotifications() -> [Notification]? {
		return currentNotification
	}
	
	func removeMealsNotification() {
		UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [NotificationTypes.mealNotification.rawValue])
		getScheduledNotifications()
	}
	func removeNotification(_ notification: Notification) {
		UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.id])
		getScheduledNotifications()
	}
	func removeAllNotifications() {
		UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
		UNUserNotificationCenter.current().removeAllDeliveredNotifications()
	}
	func setMealNotification() {
		guard let time = "17:00".timeFromString, !postNotifications.contains(where: { $0.id == "mealNotification" }) else { return }
		var dateComponents = DateComponents()
		
		dateComponents.hour = time.hour
		dateComponents.minute = time.minute
		dateComponents.second = time.second
		
		self.postNotifications.insert(Notification(id: NotificationTypes.mealNotification.rawValue, title: "אופס", body:  StaticStringsManager.shared.getGenderString?[29] ?? "", dateTime: dateComponents))
		self.schedule()
	}
	func showNotificationAlert(withTitle: String, withMessage: String, type: NotificationTypes, vc: UIViewController) {
		let alert = UIAlertController(title: withTitle, message: withMessage, preferredStyle: .alert)
		
		alert.addTextField { textField in
			textField.textAlignment = .center
			textField.setupTimePicker()
		}
		
		alert.addAction(UIAlertAction(title: "אישור", style: .default, handler: { _ in
			let textField = alert.textFields![0] as UITextField
			
			if let text = textField.text, let time = text.timeFromString {
				
				var dateComponents = DateComponents()
				dateComponents.hour = time.hour
				dateComponents.minute = time.minute
				dateComponents.second = time.second
				
				switch type {
				case .waterNotification:
					self.postNotifications.insert(Notification(title: "זמן לשתות", body: "נראה שהגיע הזמן לשתות", dateTime: dateComponents))
				case .weightNotification:
					self.postNotifications.insert(Notification(title: "זמן להישקל", body: StaticStringsManager.shared.getGenderString?[28] ?? "", dateTime: dateComponents))
				case .mealNotification:
					break
				}
				self.schedule()
			}
		}))
		alert.addAction(UIAlertAction(title: "ביטול", style: .cancel))
		vc.present(alert, animated: true)
	}
}

//MARK: - Class Functions
extension LocalNotificationManager {
	
	private func schedule() {
		UNUserNotificationCenter.current().getNotificationSettings { settings in
			
			switch settings.authorizationStatus {
			case .notDetermined:
				self.requestAuthorization()
			case .authorized, .provisional:
				self.scheduleNotifications()
			default:
				break
			}
		}
	}
	private func requestAuthorization() {
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
			
			if granted == true && error == nil {
				self.scheduleNotifications()
			}
		}
	}
	private func scheduleNotifications() {
		for notification in postNotifications {
			addNotification(notification: notification)
		}
		postNotifications.removeAll()
	}
	private func getScheduledNotifications() {
		var notifications = [Notification]()
		UNUserNotificationCenter.current().getPendingNotificationRequests { notificationsItems in
			
			notifications = notificationsItems.map {
				let content = $0.content
				let trigger = $0.trigger as! UNCalendarNotificationTrigger
				return Notification(id: $0.identifier, title: content.title, body: content.body, dateTime: trigger.dateComponents)
			}
			self.currentNotification = notifications.filter { $0.id != NotificationTypes.mealNotification.rawValue }
													.sorted(by: { $0.title < $1.title })
		}
	}
	private func addNotification(notification: Notification) {
		let ok = UNNotificationAction(identifier: "ACCEPT_ACTION", title: "אישור", options: [])
		let cancel = UNNotificationAction(identifier: "DECLINE_ACTION", title: "ביטול",  options: [])
		let category = UNNotificationCategory(identifier: "REMAINDER_INVITATION", actions: [ok, cancel],
											  intentIdentifiers: [], options: .customDismissAction)
		
		UNUserNotificationCenter.current().setNotificationCategories([category])
		
		let content = UNMutableNotificationContent()
		content.categoryIdentifier = "REMAINDER_INVITATION"
		content.title = notification.title
		content.body = notification.body
		content.sound = .default
		
		let trigger = UNCalendarNotificationTrigger(dateMatching: notification.dateTime, repeats: true)
		let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
		
		UNUserNotificationCenter.current().add(request) { error in
			
			guard error == nil else { return }
			self.getScheduledNotifications()
		}
	}
}
