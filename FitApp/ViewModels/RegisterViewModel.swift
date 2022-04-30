//
//  RegisterViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 23/07/2021.
//

import Foundation
import FirebaseAuth

class RegisterViewModel {
	
	var email: String?
	var password: String?
	
	func validateData(email: String?, password: String?, confirmPassword: String?, termsOfUse: Bool?, completion: @escaping (Error?) -> Void) throws {
		guard let email = email, !email.isEmpty, email != "" else {
			throw ErrorManager.RegisterError.emptyEmail
		}
		if !email.isValidEmail {
			throw ErrorManager.RegisterError.incorrectEmail
		}
		guard let password = password, !password.isEmpty, password != "" else {
			throw ErrorManager.RegisterError.emptyPassword
		}
		guard let confirmPassword = confirmPassword, !confirmPassword.isEmpty, confirmPassword != "" else {
			throw ErrorManager.RegisterError.emptyConfirmPassword
		}
		guard let termsOfUse = termsOfUse, termsOfUse != false else {
			throw ErrorManager.RegisterError.termsOfUse
		}
		
		UserProfile.defaults.termsApproval = TermsAgreeDataModel()
		UserProfile.defaults.healthApproval = TermsAgreeDataModel()
		UserProfile.defaults.permissionLevel = 9
		UserProfile.defaults.email = email
		
		self.email = email
		self.password = password
		
		Auth.auth().fetchSignInMethods(forEmail: email) {
			isSignedMethods, error in
			
			if let error = error {
				completion(error)
			}
			
			if isSignedMethods == nil {
				completion(nil)
			} else {
				completion(ErrorManager.RegisterError.emailExist)
			}
		}
	}
	func register(orderId: String, order: OrderData, completion: @escaping (Result<Bool, Error>) -> Void) {
		guard let email = email, let password = password else {
			completion(.failure(ErrorManager.RegisterError.emptyEmail))
			return
		}
		
		// User not exist, Authenticate new User
		self.authRegister(email: email, password: password) {
			result in
			
			switch result {
			case .success(_):
			
				UserProfile.updateServer()
				self.saveOrderData(id: orderId, order: order) {
					completion(.success(true))
				}
			case .failure(let error as NSError):
				
				//17007: Email exist
				if error.code == 17007 {
					completion(.failure(ErrorManager.RegisterError.emailExist))
				} else {
					completion(.failure(error))
				}
			}
		}
	}
	private func authRegister(email: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void) {
		
		Auth.auth().createUser(withEmail: email, password: password) {
			(user, error) in
			
			if let error = error {
				completion(.failure(error))
			} else {
				completion(.success(true))
			}
		}
	}
	private func saveOrderData(id: String, order: OrderData, completion: @escaping ()->()) {
		
		let data: UserOrderData = {
			return UserOrderData(currentOrderId: id, dateOfTransaction: order.dateOfTranasction, orderIds: [id], period: order.period)
		}()
		
		let queue = DispatchQueue.global(qos: .userInteractive)
		let dispatchGroup = DispatchGroup()

		dispatchGroup.enter()
		queue.async(group: dispatchGroup) {
			GoogleApiManager.shared.addOrderData(data: order, with: id) { _ in
				dispatchGroup.leave()
			}
		}
		dispatchGroup.enter()
		queue.async(group: dispatchGroup) {
			GoogleApiManager.shared.addUserOrderData(userOrderData: data) { _ in
				dispatchGroup.leave()
			}
		}
		dispatchGroup.notify(queue: .global()) {
			completion()
		}
	}
}
