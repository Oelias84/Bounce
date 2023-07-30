//
//  OrderModel.swift
//  FitApp
//
//  Created by Ofir Elias on 27/07/2023.
//

import Foundation

struct OrderModel: Decodable {
    
    let address: String?
    let city: String?
    let companyName: String?
    let country: String?
    let dateOfTranasction: String?
    let email: String?
    let period: Int?
    let phoneNumber: String?
    let postCode: Int?
    let productName: String?
    let state: String?
    let transactionAmount: String?
    let userType: String?
}
