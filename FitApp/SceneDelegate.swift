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
			if Auth.auth().currentUser != nil {
				//Check if the user is approved in data base
				GoogleApiManager.shared.checkUserApproved() {
					result in
					
					switch result {
					case .success(let isApproved):
						if isApproved {
							
							if UserProfile.defaults.finishOnboarding == true {
								self.goToHome(window)
							} else {
								self.goToQuestionnaire(window)
							}
						} else {
							Spinner.shared.stop()
							self.goToLogin(window)
							self.window?.rootViewController?.presentOkAlert(withTitle: "אופס",withMessage: "אין באפשרוך להתחבר, אנא צרי איתנו קשר")
						}
					case .failure(let error):
						self.goToLogin(window)
						self.window?.rootViewController?.presentOkAlert(withTitle: "אופס",withMessage: "נראה שיש בעיה: \(error.localizedDescription)")
					}
				}
			} else {
				//Go To Login Screen
				goToLogin(window)
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
//	private func lunchScreen(_ window: UIWindow) {
//		let storyboard = UIStoryboard(name: K.StoryboardName.launchScreen, bundle: nil)
//		let homeVC = storyboard.instantiateViewController(identifier: "lunchScreen")
//
//		homeVC.modalPresentationStyle = .fullScreen
//		window.rootViewController = homeVC
//		self.window = window
//		window.makeKeyAndVisible()
//	}
	private func goToLogin(_ window: UIWindow) {
		let storyboard = UIStoryboard(name: K.StoryboardName.loginRegister, bundle: nil)
		let homeVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.startNavigationViewController) as! UINavigationController
		
		homeVC.modalPresentationStyle = .fullScreen
		window.rootViewController = homeVC
		self.window = window
		window.makeKeyAndVisible()
	}
	private func goToQuestionnaire(_ window: UIWindow) {
		//Go to Questionnaire
		let storyboard = UIStoryboard(name: K.StoryboardName.questionnaire, bundle: nil)
		let homeVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.questionnaireNavigation) as! UINavigationController
		
		homeVC.modalPresentationStyle = .fullScreen
		window.rootViewController = homeVC
		self.window = window
		window.makeKeyAndVisible()
	}
	private func goToHome(_ window: UIWindow) {
		let storyboard = UIStoryboard(name: K.StoryboardName.home, bundle: nil)
		let homeVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.HomeTabBar) as! UITabBarController
		
		homeVC.modalPresentationStyle = .fullScreen
		window.rootViewController = homeVC
		self.window = window
		window.makeKeyAndVisible()
	}
	private func signOutCurrentUser() {
		do {
			try Auth.auth().signOut()
		} catch {
			print("could not signOut")
		}
	}
}

