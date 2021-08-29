//
//  ErrorManager.swift
//  FitApp
//
//  Created by Ofir Elias on 13/07/2021.
//

import Foundation

struct ErrorManager: Error {
	
	enum LoginError: Error {
		
		case emptyEmail
		case invalidEmail
		case emailNotExist
		case emptyPassword
		case incorrectPassword
	}
	
	enum RegisterError: Error {
		
		case termsOfUse
		case failToRegister
		case userNotApproved
		case userNotSaved
		case emptyUserName
		case userNameNotFullName
		case emptyEmail
		case incorrectEmail
		case emailExist
		case emptyPassword
		case shortPassword
		case emptyConfirmPassword
		case confirmPasswordDoNotMatch
	}
	
	enum DatabaseError: Error {
		
		case failedToUpdate
		case failedToFetch
		case failedToDecodeData
		case dataIsEmpty
		case userExist
		case noFetch
		case isPrime
	}
}
