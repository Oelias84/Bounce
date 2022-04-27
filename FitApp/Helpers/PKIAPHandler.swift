//
//  PKIAPHandler.swift
//  FitApp
//
//  Created by Ofir Elias on 27/04/2022.
//

import UIKit
import StoreKit

enum PKIAPHandlerAlertType {
	case setProductIds
	case disabled
	case restored
	case purchased
	
	var message: String {
		switch self {
		case .setProductIds: return "Product ids not set, call setProductIds method!"
		case .disabled: return "Purchases are disabled in your device!"
		case .restored: return "You've successfully restored your purchase!"
		case .purchased: return "You've successfully bought this purchase!"
		}
	}
}


class PKIAPHandler: NSObject {
	
	static let shared = PKIAPHandler()
	private override init() { }
	
	fileprivate var productIds = [String]()
	fileprivate var productID = ""
	fileprivate var productsRequest = SKProductsRequest()
	fileprivate var fetchProductCompletion: (([SKProduct])->Void)?
	
	fileprivate var productToPurchase: SKProduct?
	fileprivate var purchaseProductCompletion: ((PKIAPHandlerAlertType, SKProduct?, SKPaymentTransaction?)->Void)?
	
	var isLogEnabled: Bool = true
		
	// Set Product Id's
	func setProductIds(ids: [String]) {
		self.productIds = ids
	}
	
	// Make Purchase of a Product
	func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }
	func purchase(product: SKProduct, completion: @escaping ((PKIAPHandlerAlertType, SKProduct?, SKPaymentTransaction?)->Void)) {
	
	self.purchaseProductCompletion = completion
	self.productToPurchase = product
	
	if self.canMakePurchases() {
		let payment = SKPayment(product: product)
		SKPaymentQueue.default().add(self)
		SKPaymentQueue.default().add(payment)
		
		log("PRODUCT TO PURCHASE: \(product.productIdentifier)")
		productID = product.productIdentifier
	}
	else {
		completion(PKIAPHandlerAlertType.disabled, nil, nil)
	}
}
	
	// Restore Purchase
	func restorePurchase(){
		SKPaymentQueue.default().add(self)
		SKPaymentQueue.default().restoreCompletedTransactions()
	}
	
	// Fetch available IAP Products
	func fetchAvailableProducts(completion: @escaping (([SKProduct])->Void)){
		
		self.fetchProductCompletion = completion
		// Put here your IAP Products ID's
		if self.productIds.isEmpty {
			log(PKIAPHandlerAlertType.setProductIds.message)
			fatalError(PKIAPHandlerAlertType.setProductIds.message)
		}
		else {
			productsRequest = SKProductsRequest(productIdentifiers: Set(self.productIds))
			productsRequest.delegate = self
			productsRequest.start()
		}
	}
	
	fileprivate func log <T> (_ object: T) {
		if isLogEnabled {
			NSLog("\(object)")
		}
	}
}

//MARK: - Delegates
extension PKIAPHandler: SKProductsRequestDelegate, SKPaymentTransactionObserver{
	
	// Request IAP Products
	func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
		
		if (response.products.count > 0) {
			if let completion = self.fetchProductCompletion {
				completion(response.products)
			}
		}
	}
	func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
		if let complition = self.purchaseProductCompletion {
			complition(PKIAPHandlerAlertType.restored, nil, nil)
		}
	}
	
	// IAP Payment Queue
	func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
		for transaction:AnyObject in transactions {
			if let trans = transaction as? SKPaymentTransaction {
				switch trans.transactionState {
				case .purchased:
					log("Product purchase done")
					SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
					if let complition = self.purchaseProductCompletion {
						complition(PKIAPHandlerAlertType.purchased, self.productToPurchase, trans)
					}
					break
					
				case .failed:
					log("Product purchase failed")
					SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
					break
				case .restored:
					log("Product restored")
					SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
					break
					
				default:
					break
				}
			}
		}
	}
}
