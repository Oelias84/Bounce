//
//  LoginViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 13/07/2021.
//

import Foundation
import FirebaseAuth
import FirebaseAnalytics
import FirebaseDatabase

class LoginViewModel {
	
	private let googleManager = GoogleApiManager()

	func login(email: String?, password: String?, completion: @escaping (Bool, String?) -> () ) throws {
		
		guard let email = email else {
			throw ErrorManager.LoginError.emptyEmail
		}
		guard let password = password else {
			throw ErrorManager.LoginError.emptyPassword
		}
		if !email.isValidEmail {
			throw ErrorManager.LoginError.invalidEmail
		}
		if password.count != 6 {
			throw ErrorManager.LoginError.incorrectPasswordLength
		}
		
		
		Auth.auth().signIn(withEmail: email, password: password) {
			[weak self] (user, error) in
			guard let self = self else { return }
			
			if error == nil {
				self.getUserImageProfileUrl(with: email)
				self.googleManager.getUserData { result in
					
					switch result {
					case .success(let userData):
						Analytics.logEvent(AnalyticsEventLogin, parameters: ["USER_EMAIL": email])
						
						#warning("Remove this after users update")
						LocalNotificationManager.shared.setMealNotification()

						UserProfile.defaults.email = email
						if let user = user?.user, let data = userData {
							UserProfile.defaults.updateUserProfileData(data, id: user.uid)
							if let token =  UserProfile.defaults.fcmToken {
								let userName = data.name.splitFullName
								GoogleDatabaseManager.shared.add(token: token, for: User(firsName: userName.0, lastName: userName.1, email: user.email!, deviceToken: token))
							}
						}
						completion(true, nil)
					case .failure(let error):
						print("Error fetching user data: ", error)
					}
				}
			} else {
				completion(false, error?.localizedDescription)
			}
		}
	}
	
	func getUserImageProfileUrl(with email: String) {
		let path = "\(email.safeEmail)_profile_picture.jpeg"
		GoogleStorageManager.shared.downloadImageURL(from: .profileImage , path: path) {
			result in
			
			switch result {
			case .success(let url):
				DispatchQueue.main.async {
					UserProfile.defaults.profileImageImageUrl = url.absoluteString
				}
			case .failure(let error):
				print("no image exist", error)
			}
		}
	}
}
