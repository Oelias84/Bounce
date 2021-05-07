//
//  ChatUser.swift
//  FitApp
//
//  Created by Ofir Elias on 07/02/2021.
//

import Foundation

struct User: Codable {
	
	let firsName: String
	let lastName: String
	let email: String
	var deviceToken: String?
	
	var safeEmail: String {
		return email.safeEmail
	}
	var profileImageUrl: String {
		return "\(safeEmail)_profile_picture.jpeg"
	}
	var weightImageUrl: String {
		return "\(safeEmail)_\(Date().dateStringForDB)_weight_image.jpeg"
	}
}
