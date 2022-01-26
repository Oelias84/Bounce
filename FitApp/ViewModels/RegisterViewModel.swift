//
//  RegisterViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 23/07/2021.
//

import Foundation
import FirebaseAuth

class RegisterViewModel {

	func register(userName: String?, email: String?, password: String?, confirmPassword: String?, userImage: UIImage?, termsOfUse: Bool?, completion: @escaping (Result<Bool, Error>) -> Void) throws {
//
//		guard var userName = userName, !userName.isEmpty, userName != "" else {
//			throw ErrorManager.RegisterError.emptyUserName
//		}
//		if !userName.isValidFullName {
//			throw ErrorManager.RegisterError.userNameNotFullName
//		}
//		guard let email = email, !email.isEmpty, email != "" else {
//			throw ErrorManager.RegisterError.emptyEmail
//		}
//		if !email.isValidEmail {
//			throw ErrorManager.RegisterError.incorrectEmail
//		}
//		guard let password = password, !password.isEmpty, password != "" else {
//			throw ErrorManager.RegisterError.emptyPassword
//		}
//		guard let confirmPassword = confirmPassword, !confirmPassword.isEmpty, confirmPassword != "" else {
//			throw ErrorManager.RegisterError.emptyConfirmPassword
//		}
//		guard let termsOfUse = termsOfUse, termsOfUse != false else {
//			throw ErrorManager.RegisterError.termsOfUse
//		}
//		UserProfile.defaults.termsApproval = TermsAgreeDataModel()
//		UserProfile.defaults.healthApproval = TermsAgreeDataModel()
//		UserProfile.defaults.name = userName
//		UserProfile.defaults.email = email
//
//		// Check if email dose exist in database
//		GoogleDatabaseManager.shared.userExists(with: email) { exist in
//
//			if exist {
//				// The email is taken, show error
//				completion(.failure(ErrorManager.RegisterError.emailExist))
//			} else {
//
//				// User not exist, Authenticate new User
//				self.registerUser(email: email, password: password) {
//					[weak self] result in
//					guard let self = self else { return }
//
//					switch result {
//
//					case .success(_):
//
//						while userName.last?.isWhitespace == true { userName = String(userName.dropLast()) }
//						let splitUserName = userName.splitFullName
//						let user = User(firsName: splitUserName.0, lastName: splitUserName.1, email: email, deviceToken: UserProfile.defaults.fcmToken)
//
//						// Insert User into database
//						self.insertUserToDataBase(user: user) {
//							success in
//
//							if success {
//								// Save User name and update server
//								UserProfile.updateServer()
//
//								// If contain User image upload to server
//								if let image = userImage {
//									// If contain User image upload to server
//									self.saveUserImage(image: image, for: user.profileImageUrl) {
//										result in
//
//										switch result {
//										case .success(let imageUrl):
//											// Saves image url to user defaults
//											UserProfile.defaults.profileImageImageUrl = imageUrl
//
//											//Check if the user is approved in data base
//											GoogleApiManager.shared.checkUserApproved() {
//												result in
//
//												switch result {
//												case .success(let isApproved):
//													if isApproved {
//														completion(.success(true))
//													} else {
//														completion(.failure(ErrorManager.RegisterError.userNotApproved))
//													}
//												case .failure(let error):
//													completion(.failure(error))
//												}
//											}
//										case .failure(let error):
//											completion(.failure(error))
//										}
//									}
//								} else {
//									//Check if the user is approved in data base
//									GoogleApiManager.shared.checkUserApproved() {
//										result in
//
//										switch result {
//										case .success(let isApproved):
//											if isApproved {
//												completion(.success(true))
//											} else {
//												completion(.failure(ErrorManager.RegisterError.userNotApproved))
//											}
//										case .failure(let error):
//											completion(.failure(error))
//										}
//									}
//								}
//							} else {
//								completion(.failure(ErrorManager.RegisterError.userNotSaved))
//							}
//						}
//					case .failure(let error):
//						completion(.failure(error))
//					}
//				}
//			}
//		}
	}
//
	private func insertUserToDataBase(user: User, completion: @escaping (Bool) -> Void) {
//
//		GoogleDatabaseManager.shared.insertUser(with: user) {
//			success in
//
//			if success {
//				completion(true)
//			} else {
//				completion(false)
//			}
//		}
	}
	private func registerUser(email: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void) {
//
//		Auth.auth().createUser(withEmail: email, password: password) {
//			(user, error) in
//
//			if let error = error {
//				completion(.failure(error))
//			} else {
//				completion(.success(true))
//			}
//		}
	}
	private func saveUserImage(image: UIImage, for url: String, completion: @escaping (Result<String, Error>) -> Void) {
//
//		GoogleStorageManager.shared.uploadImage(from: .profileImage, data: image.jpegData(compressionQuality: 8)!, fileName: url) {
//			result in
//			completion(result)
//		}
	}
}
