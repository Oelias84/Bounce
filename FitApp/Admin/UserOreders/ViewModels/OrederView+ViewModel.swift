//
//  OrederView+ViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 27/07/2023.
//

import SwiftUI
import Foundation

extension OrederView {
    
    @MainActor class ViewModel: ObservableObject {
        
        @Published private(set) var order: OrderModel?
        
        var orderID: String
        
        init(userID: String, orderID: String) {
            self.orderID = orderID
            fetchOrder(userID, orderID)
        }
        
        var address: String {
            var postCode: String {
                if let postCode = order?.postCode {
                    return "\(postCode)"
                }
                return ""
            }
            var address: String {
                if let address = order?.address {
                    return address
                }
                return ""
            }
            var city: String {
                if let city = order?.city {
                    return city
                }
                return ""
            }
            var country: String {
                if let country = order?.country {
                    return country
                }
                return ""
            }
            
            return address + ", " + city + ", " +  country + ", " + postCode
        }
        var state: String {
            order?.state ?? .noInformation
        }
        var companyName: String {
            order?.companyName ?? .noInformation
        }
        var dateOfTranasction: String {
            order?.dateOfTranasction?.fullDateFromStringWithDash?.fullDateString ?? .noInformation
        }
        var email: String {
            order?.email ?? .noInformation
        }
        var period: String {
            if let period = order?.period {
                return "\(period)"
            }
            return .noInformation
        }
        var phoneNumber: String {
            order?.phoneNumber ?? .noInformation
        }
        var productName: String {
            order?.productName ?? .noInformation
        }
        var transactionAmount: String {
            order?.transactionAmount ?? .noInformation
        }
        var userType: String {
            order?.userType ?? .noInformation
        }
        
        private func fetchOrder(_ userID: String, _ orderID: String) {
            GoogleApiManager.shared.getOrder(orderID: orderID) {
                [weak self] resualt in
                guard let self else { return }
                
                switch resualt {
                case .success(let data):
                    self.order = data
                case .failure(let failure):
                    print(failure)
                }
            }
        }
    }
}
