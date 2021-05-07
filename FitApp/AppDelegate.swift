//
//  AppDelegate.swift
//  FitApp
//
//  Created by Ofir Elias on 24/11/2020.
//


import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications

// MARK: - UISceneSession Lifecycle
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		FirebaseApp.configure()
		
		if #available(iOS 10.0, *) {
		  // For iOS 10 display notification (sent via APNS)
		  UNUserNotificationCenter.current().delegate = self

		  let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
		  UNUserNotificationCenter.current().requestAuthorization(
			options: authOptions,
			completionHandler: {_, _ in })
		} else {
		  let settings: UIUserNotificationSettings =
		  UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
		  application.registerUserNotificationSettings(settings)
		}
		application.registerForRemoteNotifications()

		Messaging.messaging().delegate = self
		
		return true
	}
	
	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}
}

//MARK: - Notifications
extension AppDelegate: UNUserNotificationCenterDelegate {
	
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

		let id = notification.request.identifier
		
		print("Received notification with IDluhh = \(id)")
		completionHandler([.sound, .alert, .badge])
	}
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		
		let id = response.notification.request.identifier
		
		print("Received notification with IDkjhk = \(id)")

		if response.notification.request.content.categoryIdentifier == "REMAINDER_INVITATION" {
			
			switch response.actionIdentifier {
			case "ACCEPT_ACTION":
				
				guard let window = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window else {
					return
				}
				let storyboard = UIStoryboard(name: K.StoryboardName.home, bundle: nil)
				let nav = storyboard.instantiateViewController(withIdentifier: K.ViewControllerId.HomeTabBar) as? UITabBarController
				
				window.rootViewController = nav
				window.makeKeyAndVisible()
				break
			case "DECLINE_ACTION":
				break
			case UNNotificationDefaultActionIdentifier, UNNotificationDismissActionIdentifier:
				break
			default:
				break
			}
		}
		completionHandler()
	}
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		Messaging.messaging().apnsToken = deviceToken
	}
}

extension AppDelegate: MessagingDelegate {
	
	func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
		let tokenDict = ["token": fcmToken]
		
		UserProfile.defaults.fcmToken = tokenDict["token"]
		NotificationCenter.default.post(name: NSNotification.Name("FCMToken"), object: nil, userInfo: tokenDict)
	}
}
