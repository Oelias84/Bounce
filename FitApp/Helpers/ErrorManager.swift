//
//  ErrorManager.swift
//  FitApp
//
//  Created by Ofir Elias on 13/07/2021.
//

import Foundation

struct ErrorManager {
	
	enum LoginError: Error {
		
		case emptyEmail
		case emptyPassword
		case invalidEmail
		case incorrectPasswordLength
	}
	
}
