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
struct UserOrderData: Codable {
	
	let currentOrderId: String
	let dateOfTransaction: String
	let orderIds: [String]
	let period: Int
}
struct PermissionLevel: Codable {
	
	let permissionLevel: Int?
}
struct OrderData: Codable {
	
	var address: String?
	var city: String?
	var companyName: String?
	var country: String?
	var dateOfTranasction: String
	var email: String?
	var period: Int
	var phoneNumberL: String?
	var postCode: Int?
	var productName: String
	var state: String?
	var transactionAmount: String
	var userType: String?
}
