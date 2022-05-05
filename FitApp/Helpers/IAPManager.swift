//
//  IAPManager.swift
//  FitApp
//
//  Created by Ofir Elias on 27/04/2022.
//

import StoreKit

enum IAPHandlerAlertType: String {
	
	case purchased = "You payment has been successfully processed."
	case failed = "Failed to process the payment."
}

enum IAPProducts: String, CaseIterable {
	
	case monthlySubID = "com.bouncefit.ios"
}

class IAPManager: NSObject {
	
	static let shared = IAPManager()
	
	fileprivate var productIds = IAPProducts.allCases.map(\.rawValue)
	fileprivate var productID = ""
	fileprivate var productsRequest = SKProductsRequest()
	fileprivate var productToPurchase: SKProduct?
	fileprivate var fetchProductcompletion: (([SKProduct]) -> Void)?
	fileprivate var purchaseProductcompletion: ((String, SKProduct?, SKPaymentTransaction?)->Void)?
	
	private func canMakePurchases() -> Bool {
		SKPaymentQueue.canMakePayments()
	}
}

// MARK: Public methods
extension IAPManager {
	
	func purchase(product: SKProduct, completion: @escaping ((String, SKProduct?, SKPaymentTransaction?)->Void)) {
		purchaseProductcompletion = completion
		productToPurchase = product
		
		if canMakePurchases() {
			let payment = SKPayment(product: product)
			SKPaymentQueue.default().add(self)
			SKPaymentQueue.default().add(payment)
			productID = product.productIdentifier
		} else {
			completion("In app purchases are disabled", nil, nil)
		}
	}
	func fetchAvailableProducts(completion: @escaping (([SKProduct]) -> Void)){
		fetchProductcompletion = completion
		
		if productIds.isEmpty {
			fatalError("Product Ids are not found")
		} else {
			productsRequest = SKProductsRequest(productIdentifiers: Set(productIds))
			productsRequest.delegate = self
			productsRequest.start()
		}
	}
}

// MARK: SKProductsRequestDelegate
extension IAPManager: SKProductsRequestDelegate, SKPaymentTransactionObserver {
	
	func productsRequest (_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
		if response.products.count > 0, let completion = fetchProductcompletion {
			completion(response.products)
		} else {
			print("Invalid Product Identifiers: \(response.invalidProductIdentifiers)")
		}
	}
	func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
		
		for transaction in transactions {
			switch transaction.transactionState {
			case .failed:
				print("Product purchase failed")
				SKPaymentQueue.default().finishTransaction(transaction)
				
				if let completion = purchaseProductcompletion {
					completion(IAPHandlerAlertType.failed.rawValue, nil, nil)
				}
				break
			case .purchased:
				print("Product purchase done")
				SKPaymentQueue.default().finishTransaction(transaction)
				
				if let completion = purchaseProductcompletion {
					completion(IAPHandlerAlertType.purchased.rawValue, productToPurchase, transaction)
				}
				break
			default:
				print(transaction.error?.localizedDescription ?? "Something went wrong")
				break
			}
		}
	}
}
