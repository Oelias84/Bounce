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
	
	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		FirebaseApp.configure()
		
		if #available(iOS 10.0, *) {
		  // For iOS 10 display notification (sent via APNS)
		  UNUserNotificationCenter.current().delegate = self

		  let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
		  UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, _ in })
		} else {
		  let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
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
		print("Will present notification with ID = \(id)")
		
		switch id {
		case NotificationTypes.mealNotification.rawValue:
			if (UserProfile.defaults.showMealNotFinishedAlert ?? true) {
				completionHandler([.sound, .alert, .badge])
			}
		default:
			if presentMessageNotifications {
				completionHandler([.sound, .alert, .badge])
			}
		}
	}
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		
		let id = response.notification.request.identifier
		print("Did receive notification with ID = \(id)")

		if response.notification.request.content.categoryIdentifier == "REMAINDER_INVITATION" {
			switch response.actionIdentifier {
			case "DECLINE_ACTION":
				break
			default:
				switch id {
				case NotificationTypes.mealNotification.rawValue:
					moveTo(storyboardId: K.StoryboardName.mealPlan, vcId: K.ViewControllerId.mealViewController)
				case NotificationTypes.weightNotification.rawValue:
					moveTo(storyboardId: K.StoryboardName.weightProgress, vcId: K.ViewControllerId.weightViewController)
				default:
					return
				}
			}
		} else {
			moveTo(storyboardId: K.StoryboardName.chat, vcId: K.ViewControllerId.ChatsViewController)
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

extension AppDelegate {
	
	private var presentMessageNotifications: Bool {
		if let firstVC = (UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController?.topMostViewController()) {
			return !(firstVC.isKind(of: ChatsViewController.self) || firstVC.isKind(of: ChatViewController.self))
		}
		return true
	}
	
	private func mainView() {
		let storyboard = UIStoryboard(name: K.StoryboardName.home, bundle: nil)
		let nav = storyboard.instantiateViewController(withIdentifier: K.ViewControllerId.HomeTabBar)
		
		window = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window
		window!.rootViewController = nav
		window!.makeKeyAndVisible()
	}
	private func moveTo(storyboardId: String, vcId: String ) {
		mainView()
		let storyboard = UIStoryboard(name: storyboardId, bundle: nil)
		let toVc = storyboard.instantiateViewController(withIdentifier: vcId)
		
		if let tabBar = window?.rootViewController as? UITabBarController {
			switch vcId {
			case K.ViewControllerId.weightViewController:
				tabBar.selectedIndex = 3
			case K.ViewControllerId.mealViewController:
				tabBar.selectedIndex = 1
			default:
				tabBar.selectedIndex = 0
				if let nav = tabBar.viewControllers?.first as? UINavigationController {
					let homeVc = nav.viewControllers.first { vc in
						vc is HomeViewController
					}
					homeVc?.navigationController?.pushViewController(toVc, animated: true)
				}
			}
		}
	}
}
