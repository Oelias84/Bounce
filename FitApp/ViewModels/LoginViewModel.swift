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
	
	private let googleManager = GoogleApiManager.shared
	
	func login(email: String?, password: String?, completion: @escaping (Bool, String?) -> () ) throws {
		
		guard let email = email, !email.isEmpty, email != "" else {
			throw ErrorManager.LoginError.emptyEmail
		}
		guard let password = password, !password.isEmpty, password != "" else {
			throw ErrorManager.LoginError.emptyPassword
		}
		if !email.isValidEmail {
			throw ErrorManager.LoginError.invalidEmail
		}
		
		Auth.auth().signIn(withEmail: email, password: password) {
			[weak self] (user, error) in
			guard let self = self else { return }
			
			if let error = error {
				completion(false, error.localizedDescription)
			} else {
				
				//Check if the user is approved in data base
				GoogleApiManager.shared.checkUserApproved() {
					result in
					
					switch result {
					case .success(let isApproved):
						if isApproved {
							
							self.googleManager.getUserData { result in

								switch result {
								case .success(let userData):
									LocalNotificationManager.shared.setMealNotification()
									
									if let user = user?.user, let data = userData {
										UserProfile.defaults.updateUserProfileData(data, id: user.uid)
										let _ = MessagesManager.shared
									}
									UserProfile.defaults.email = email
									completion(true, nil)
								case .failure(let error):
									print("Error fetching user data: ", error)
									completion(false, nil)
								}
							}
						} else {
							completion(false, "אין באפשרוך להתחבר, אנא צרי איתנו קשר")
						}
					case .failure(let error):
						completion(false, "נראה שיש בעיה: \(error.localizedDescription)")
					}
				}
			}
		}
	}
}
