//
//  LocalNotificationManager.swift
//  FitApp
//
//  Created by iOS Bthere on 15/01/2021.
//

import UIKit
import UserNotifications

struct Notification {
    
    var id: String
    var title: String
    var body: String
    var dateTime: DateComponents
}

class LocalNotificationManager {
    
    var notifications = [Notification]()
    var delegate: UIViewController?
    
    init(_ viewController: UIViewController) {
        self.delegate = viewController
    }

    func listScheduledNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
            
            for notification in notifications {
                print(notification)
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
    func schedule() {
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
    private func scheduleNotifications() {
        for notification in notifications {
            
            let ok = UNNotificationAction(identifier: "ACCEPT_ACTION", title: "אישור", options: [])
            let cancel = UNNotificationAction(identifier: "DECLINE_ACTION", title: "ביטול",  options: [])
            let category = UNNotificationCategory(identifier: "REMAINDER_INVITATION", actions: [ok, cancel],
                                                  intentIdentifiers: [], options: .customDismissAction)
            
            UNUserNotificationCenter.current().setNotificationCategories([category])
            
            let content = UNMutableNotificationContent()
            content.categoryIdentifier = "REMAINDER_INVITATION"
            content.title = notification.title
            content.sound = .default
                        
            let trigger = UNCalendarNotificationTrigger(dateMatching: notification.dateTime, repeats: true)
            let request = UNNotificationRequest(identifier: "REMAINDER_INVITATION", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                
                guard error == nil else { return }
                
                print("Notification scheduled! --- ID = \(notification.id)")
            }
        }
    }
    func showNotificationAlert() {
        let alert = UIAlertController(title: "קביעת תיזכורת שקילה", message: "באיזה שעה תרצי לקבוע תזכורת שקילה?", preferredStyle: .alert)

        alert.addTextField { textField in
            textField.textAlignment = .center
        }
        
        alert.addAction(UIAlertAction(title: "אישור", style: .default, handler: { _ in
            let textField = alert.textFields![0] as UITextField
            
            if let text = textField.text, let time = text.timeFromString {
                
                var dateComponents = DateComponents()
                dateComponents.hour = time.hour
                dateComponents.minute = time.minute
                dateComponents.second = time.second
                
                self.notifications = [Notification(id: "reminder", title: "זמן להישקל", body: "לחצי כאן בכדי להזין את השקילה היומית שלך", dateTime: dateComponents)]
                self.schedule()
            }
        }))
        alert.addAction(UIAlertAction(title: "ביטול", style: .cancel, handler: { _ in
            
        }))
        delegate?.present(alert, animated: true)
    }
}
