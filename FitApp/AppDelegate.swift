//
//  AppDelegate.swift
//  FitApp
//
//  Created by Ofir Elias on 24/11/2020.
//


import UIKit
import FirebaseCore
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
		return true
	}

	// MARK: UISceneSession Lifecycle
	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}
	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
	}
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
    {
        let id = response.notification.request.identifier
        print("Received notification with ID = \(id)")
        
        if response.notification.request.content.categoryIdentifier == "REMAINDER_INVITATION" {
            
            switch response.actionIdentifier {
            case "ACCEPT_ACTION":
                
                guard let window = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window else {
                    return
                }
                let storyboard = UIStoryboard(name: K.StoryboardName.home, bundle: nil)
                let nav = storyboard.instantiateViewController(withIdentifier: K.StoryboardNameId.HomeTabBar) as? UITabBarController
                window.rootViewController = nav
                window.makeKeyAndVisible()

                break
            case "DECLINE_ACTION":
                break
            case UNNotificationDefaultActionIdentifier,
                 UNNotificationDismissActionIdentifier:
                break
            default:
                break
            }
        }

        
        completionHandler()
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        let id = notification.request.identifier
        print("Received notification with ID = \(id)")
        
        completionHandler([.sound, .alert])
    }
    
    
    
}

