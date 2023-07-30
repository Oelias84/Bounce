//
//  CurrentOrderView+ViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 27/07/2023.
//

import Foundation

extension CurrentOrderView {
    
    @MainActor class ViewModel: ObservableObject {
        
        @Published private(set) var currentOrder: CurentOrderModel?
        var userID: String
        
        init(userID: String) {
            self.userID = userID
            self.fetchData(userID)
        }
        
        var currentOrderId: String {
            currentOrder?.currentOrderId ?? .noInformation
        }
        var dateOfTransaction: String {
            currentOrder?.dateOfTransaction?.fullDateFromStringWithDash?.fullDateString ?? .noInformation
        }
        var dateOfExperation: String {
            if let period = currentOrder?.period,
               let transactionDate = transactionDate {
                return transactionDate.add(period.months).fullDateString
            } else {
                return .noInformation
            }
        }
        var orderIds: [String] {
            currentOrder?.orderIds ?? [.noInformation]
        }
        var period: String {
            if let period = currentOrder?.period {
                return "\(period)"
            } else {
                return .noInformation
            }
        }
        
        var periodUsed: String {
            if let transactionDate = transactionDate {
                let currentDate = Date()
                return "\(Calendar(identifier: .gregorian).numberOfDaysBetween(transactionDate, and: currentDate))"
            } else {
                return .noInformation
            }
        }
        var periodLeft: String {
            if let period = currentOrder?.period,
               let transactionDate = transactionDate {
                let currentDate = Date()
                
                return "\(Calendar(identifier: .gregorian).numberOfDaysBetween(currentDate, and: transactionDate.add(period.months)))"
            } else {
                return .noInformation
            }
        }
        var periodAboutToEnd: Bool {
            if let period = currentOrder?.period,
               let transactionDate = transactionDate {
                
                return Calendar(identifier: .gregorian).numberOfDaysBetween(Date(), and: transactionDate.add(period.months)) < 7
            }
            return false
        }
        
        private var transactionDate: Date? {
            if let transactionString = currentOrder?.dateOfTransaction,
               let transactionDate = transactionString.fullDateFromStringWithDash?.onlyDate {
                return transactionDate
            } else {
                return nil
            }
        }
        private func fetchData(_ userID: String) {
            GoogleApiManager.shared.getCurrentOrder(userUID: userID) {
                [weak self] resualt in
                guard let self else { return }
                
                switch resualt {
                case .success(let data):
                    self.currentOrder = data
                case .failure(let failure):
                    print(failure)
                }
            }
        }
    }
}

extension Calendar {
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from) // <1>
        let toDate = startOfDay(for: to) // <2>
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate) // <3>
        
        return numberOfDays.day!
    }
}
