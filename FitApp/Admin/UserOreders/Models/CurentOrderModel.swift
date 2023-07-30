//
//  CurentOrderModel.swift
//  FitApp
//
//  Created by Ofir Elias on 27/07/2023.
//

import Foundation

struct CurentOrderModel: Decodable {
    
    let currentOrderId: String?
    let dateOfTransaction: String?
    let orderIds: [String]?
    let period: Int?
}
