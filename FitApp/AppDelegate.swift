//
//  AppDelegate.swift
//  FitApp
//
//  Created by Ofir Elias on 24/11/2020.
//


import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging
import UserNotifications

// MARK: - UISceneSession Lifecycle
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		FirebaseApp.configure()
		Auth.auth().useAppLanguage()
		
		window = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window
		
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
		
		if #available(iOS 13.0, *) {
			// In iOS 13 setup is done in SceneDelegate
		} else {
			let window = UIWindow(frame: UIScreen.main.bounds)
			self.window = window
			
			if !(UserProfile.defaults.hasRunBefore ?? false) {
				do {
					UserProfile.defaults.resetUserData()
					try Auth.auth().signOut()
				} catch {
					print("could not signOut")
				}
				UserProfile.defaults.hasRunBefore = true
			} else {
				Spinner.shared.show(window)
				// Run code here for every other launch but the first
				if Auth.auth().currentUser != nil {
					//Check if the user is approved in data base
					GoogleApiManager.shared.checkUserApproved() {
						result in
						switch result {
						case .success(let isApproved):
							if isApproved, (UserProfile.defaults.finishOnboarding ?? false) == true {
								if UserProfile.defaults.finishOnboarding ?? false {
									Spinner.shared.stop()
								} else {
									self.startQuestionnaire()
								}
							} else {
								Spinner.shared.stop()
								self.window!.rootViewController?.presentOkAlert(withTitle: "אופס",withMessage: "אין באפשרוך להתחבר, אנא צרי איתנו קשר")
							}
						case .failure(let error):
							self.window!.rootViewController?.presentOkAlert(withTitle: "אופס",withMessage: "נראה שיש בעיה: \(error.localizedDescription)")
						}
					}
				} else {
					self.goToLoginScreen()
				}
			}
		}
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
				completionHandler([.sound, .badge])
			}
		default:
			if let userInfo = notification.request.content.userInfo as? [String: Any], let userId = userInfo["id"] as? String {
				if presentMessageNotifications(chatUserId: userId) {
					completionHandler([.sound, .badge])
				}
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
					moveTo(storyboardId: K.StoryboardName.weightProgress, vcId: K.ViewControllerId.weightsViewController)
				default:
					return
				}
			}
		} else {
			if UserProfile.defaults.getIsManager {
				guard let notificationData = response.notification.request.content.userInfo as? [String: Any],
					  let userChatId = notificationData["id"] as? String else { return }
				
				moveTo(storyboardId: K.StoryboardName.adminChat, vcId: K.ViewControllerId.ChatViewController, userChatId: userChatId)
			} else {
				moveTo(storyboardId: K.StoryboardName.chat, vcId: K.ViewControllerId.ChatContainerViewController)
			}
		}
		completionHandler()
	}
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		Messaging.messaging().apnsToken = deviceToken
	}
}

extension AppDelegate: MessagingDelegate {
	
	func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken else { return }
		let tokenDict = ["token": fcmToken]
		
		UserProfile.defaults.fcmToken = tokenDict["token"]
		NotificationCenter.default.post(name: NSNotification.Name("FCMToken"), object: nil, userInfo: tokenDict)
	}
}

extension AppDelegate {
	
	private func presentMessageNotifications(chatUserId: String) -> Bool {
		window = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window
		
		if UserProfile.defaults.getIsManager {
			if let nav = window?.rootViewController?.presentedViewController as? UINavigationController {
				if let chatVC = nav.viewControllers.last as? ChatViewController {
					
					if chatVC.viewModel.getChatUserId == chatUserId {
						return false
					}
				} else {
					return true
				}
			}
		} else {
			if let tabBarController = window?.rootViewController as? UITabBarController,
			   let navController = tabBarController.selectedViewController as? UINavigationController {
				
				return navController.viewControllers.first(where: {$0.isKind(of: ChatContainerViewController.self)}) == nil
			}
		}
		return true
	}
	
	private func startQuestionnaire() {
		let storyboard = UIStoryboard(name: K.StoryboardName.questionnaire, bundle: nil)
		let questionnaireVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.questionnaireNavigation)
		
		questionnaireVC.modalPresentationStyle = .fullScreen
		self.window!.rootViewController = questionnaireVC
	}
	private func goToLoginScreen() {
		let storyboard = UIStoryboard(name: K.StoryboardName.loginRegister, bundle: nil)
		let questionnaireVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.startNavigationViewController)
		
		questionnaireVC.modalPresentationStyle = .fullScreen
		self.window!.rootViewController = questionnaireVC
	}
	private func moveTo(storyboardId: String, vcId: String, userChatId: String? = nil) {
		let googleManager = GoogleDatabaseManager()
		let storyboard = UIStoryboard(name: storyboardId, bundle: nil)
		let destinationViewController = storyboard.instantiateViewController(withIdentifier: vcId)
		
		window = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window
		guard let window = window else { return }
		
		if let tabBarController = window.rootViewController as? UITabBarController,
		   let navController = tabBarController.selectedViewController as? UINavigationController {
			
			switch vcId {
			case K.ViewControllerId.weightsViewController:
				tabBarController.selectedIndex = 3
			case K.ViewControllerId.mealViewController:
				tabBarController.selectedIndex = 1
			case K.ViewControllerId.ChatViewController:
				
				if let id = userChatId {
					
					DispatchQueue.global(qos: .userInteractive).async {
						googleManager.getChat(userId: id, isAdmin: true) {
							result in
							
							switch result {
							case .success(let chat):
								DispatchQueue.main.sync {
									
									guard var chatVC = destinationViewController as? ChatViewController else  { return }
									chatVC = ChatViewController(viewModel: ChatViewModel(chat: chat))
									
									if let adminNavigation = navController.presentedViewController as? UINavigationController {
										if let adminUserListVC = adminNavigation.viewControllers.first {
											if adminUserListVC.isKind(of: UsersListViewController.self) {
												adminNavigation.pushViewController(chatVC, animated: true)
											}
										}
									} else {
										let adminStoryBoard = UIStoryboard(name: K.StoryboardName.adminChat, bundle: nil)
										let adminUserChat = adminStoryBoard.instantiateViewController(identifier: K.NavigationId.adminChatNavigationController) as UINavigationController
										guard let chatVC = adminUserChat.viewControllers.first as? ChatViewController else { return }
										
										chatVC.viewModel = ChatViewModel(chat: chat)
										adminUserChat.modalPresentationStyle = .fullScreen
										navController.present(adminUserChat, animated: true)
									}
								}
							case .failure(let error):
								print("Error:", error.localizedDescription)
							}
						}
					}
				}
			case K.ViewControllerId.ChatContainerViewController:
				guard let chatViewContainerVC = destinationViewController as? ChatContainerViewController else  { return }
				chatViewContainerVC.chatViewController = ChatViewController(viewModel: ChatViewModel(chat: nil))
				navController.pushViewController(chatViewContainerVC, animated: true)
			default:
				return
			}
		}
	}
}
