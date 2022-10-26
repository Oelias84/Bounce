//
//  SceneDelegate.swift
//  FitApp
//
//  Created by Ofir Elias on 24/11/2020.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?
	
	@available(iOS 13.0, *)
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		// Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
		// If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
		// This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
		guard let windowScene = (scene as? UIWindowScene) else { return }
		let window = UIWindow(windowScene: windowScene)
		window.overrideUserInterfaceStyle = .light
			
		//Add loading screen here
		if !(UserProfile.defaults.hasRunBefore ?? false) {
			//Sign out User
			signOutCurrentUser()
			//Go To Login Screen
			goToLogin(window)
			UserProfile.defaults.hasRunBefore = true
		} else {
			// Run code here for every other launch but the first
			DispatchQueue.global(qos: .userInteractive).async {
				print(Date().onlyDate.second)
				if Auth.auth().currentUser != nil {
					//Check if the user is approved in data base
					GoogleApiManager.shared.checkUserApproved() {
						result in
						
						switch result {
						case .success(let isApproved):
							
							if isApproved {
								if UserProfile.defaults.finishOnboarding == true {
									self.goToHome(window) {
										if let notificationResponse = connectionOptions.notificationResponse {
											let id = notificationResponse.notification.request.identifier
											Spinner.shared.show()

											switch id {
											case NotificationTypes.mealNotification.rawValue:
												self.moveToFromNotification(storyboardId: K.StoryboardName.mealPlan, vcId: K.ViewControllerId.mealViewController)
											case NotificationTypes.weightNotification.rawValue:
												self.moveToFromNotification(storyboardId: K.StoryboardName.weightProgress, vcId: K.ViewControllerId.weightViewController)
											default:
												if UserProfile.defaults.getIsManager {
													guard let userChatId = notificationResponse.notification.request.content.userInfo["id"] as? String else { return }
													self.moveToFromNotification(storyboardId: K.StoryboardName.chat, vcId: K.ViewControllerId.ChatContainerViewController, userChatId: userChatId)
												} else {
													self.moveToFromNotification(storyboardId: K.StoryboardName.chat, vcId: K.ViewControllerId.ChatContainerViewController)
												}
											}
										}
									}
								} else {
									self.goToQuestionnaire(window)
								}
							} else {
								//Sign out if signed in
								//Go To Login Screen
								Spinner.shared.stop()
								self.signOutCurrentUser()
								self.goToLogin(window)
							}
						case .failure(let error):
							//Sign out if signed in
							//Go To Login Screen
							self.signOutCurrentUser()
							self.goToLogin(window)
							self.window?.rootViewController?.presentOkAlert(withTitle: "אופס",withMessage: "נראה שיש בעיה: \(error.localizedDescription)")
						}
					}
				} else {
					//Go To Login Screen
					self.goToLogin(window)
				}
			}
		}
	}
	func sceneDidDisconnect(_ scene: UIScene) {
		// Called as the scene is being released by the system.
		// This occurs shortly after the scene enters the background, or when its session is discarded.
		// Release any resources associated with this scene that can be re-created the next time the scene connects.
		// The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
	}
	func sceneDidBecomeActive(_ scene: UIScene) {
		// Called when the scene has moved from an inactive state to an active state.
		// Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
		
	}
	func sceneWillResignActive(_ scene: UIScene) {
		// Called when the scene will move from an active state to an inactive state.
		// This may occur due to temporary interruptions (ex. an incoming phone call).
	}
	func sceneWillEnterForeground(_ scene: UIScene) {
		// Called as the scene transitions from the background to the foreground.
		// Use this method to undo the changes made on entering the background.
	}
	func sceneDidEnterBackground(_ scene: UIScene) {
		// Called as the scene transitions from the foreground to the background.
		// Use this method to save data, release shared resources, and store enough scene-specific state information
		// to restore the scene back to its current state.
	}
}

//MARK: - Functions
extension SceneDelegate {
	
	private func goToLogin(_ window: UIWindow) {
		DispatchQueue.main.async {
			let storyboard = UIStoryboard(name: K.StoryboardName.loginRegister, bundle: nil)
			let homeVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.startNavigationViewController) as! UINavigationController
			
			homeVC.modalPresentationStyle = .fullScreen
			window.rootViewController = homeVC
			self.window = window
			window.makeKeyAndVisible()
		}
	}
	private func goToQuestionnaire(_ window: UIWindow) {
		//Go to Questionnaire
		DispatchQueue.main.async {
			let storyboard = UIStoryboard(name: K.StoryboardName.questionnaire, bundle: nil)
			let homeVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.questionnaireNavigation) as! UINavigationController
			
			homeVC.modalPresentationStyle = .fullScreen
			window.rootViewController = homeVC
			self.window = window
			window.makeKeyAndVisible()
		}
	}
	private func goToHome(_ window: UIWindow, completion: @escaping ()->()) {
		DispatchQueue.main.async {
			let storyboard = UIStoryboard(name: K.StoryboardName.home, bundle: nil)
			let homeVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.HomeTabBar) as! UITabBarController
			
			homeVC.modalPresentationStyle = .fullScreen
			window.rootViewController = homeVC
			self.window = window
			window.makeKeyAndVisible()
			completion()
		}
	}
	private func goToChatFromNotification(with chatId: String) {
		let googleManager = GoogleDatabaseManager()
		let storyboard = UIStoryboard(name: K.StoryboardName.chat, bundle: nil)
		let destinationViewController = storyboard.instantiateViewController(withIdentifier: K.ViewControllerId.ChatContainerViewController)
		
		if let tabBarController = self.window?.rootViewController as? UITabBarController {
			let navController = tabBarController.selectedViewController as? UINavigationController
			
			if let chatViewContainer = destinationViewController as? ChatContainerViewController {
				
				DispatchQueue.global(qos: .userInteractive).async {
					googleManager.getChat(userId: chatId, isAdmin: true) {
						result in
						
						switch result {
						case .success(let chat):
							DispatchQueue.main.sync {
								let chatViewModel = ChatViewModel(chat: chat)
								chatViewContainer.chatViewController = ChatViewController(viewModel: chatViewModel)
								navController?.pushViewController(chatViewContainer, animated: true)
							}
						case .failure(let error):
							print("Error:", error.localizedDescription)
						}
					}
				}
			}
		}
	}
	
	private func moveToFromNotification(storyboardId: String, vcId: String, userChatId: String? = nil) {
		let googleManager = GoogleDatabaseManager()
		let storyboard = UIStoryboard(name: storyboardId, bundle: nil)
		let destinationViewController = storyboard.instantiateViewController(withIdentifier: vcId)
		window = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window
		
		if let tabBarController = window?.rootViewController as? UITabBarController,
		   let navController = tabBarController.selectedViewController as? UINavigationController {
			
			switch vcId {
			case K.ViewControllerId.weightViewController:
				tabBarController.selectedIndex = 3
			case K.ViewControllerId.mealViewController:
				tabBarController.selectedIndex = 1
			case K.ViewControllerId.ChatContainerViewController:
				// Manager
				Spinner.shared.show()
				
				 if let chatViewContainer = destinationViewController as? ChatContainerViewController {
					
					if let id = userChatId {
						DispatchQueue.global(qos: .userInteractive).async {
							googleManager.getChat(userId: id, isAdmin: true) {
								result in
								
								switch result {
								case .success(let chat):
									DispatchQueue.main.sync {
										let chatViewModel = ChatViewModel(chat: chat)
										chatViewContainer.chatViewController = ChatViewController(viewModel: chatViewModel)
										navController.pushViewController(chatViewContainer, animated: false)
									}
								case .failure(let error):
									print("Error:", error.localizedDescription)
								}
							}
						}
					} else {
						// User
						chatViewContainer.chatViewController = ChatViewController(viewModel: ChatViewModel(chat: nil))
						navController.pushViewController(chatViewContainer, animated: false)
					}
				}
			default:
				return
			}
		}
	}
	
	private func signOutCurrentUser() {
		do {
			UserProfile.defaults.resetUserData()
			try Auth.auth().signOut()
		} catch {
			print("could not signOut")
		}
	}
}
