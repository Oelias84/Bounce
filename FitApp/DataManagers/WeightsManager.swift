//
//  WeightsManager.swift
//  FitApp
//
//  Created by Ofir Elias on 11/09/2021.
//

import Foundation
import FirebaseAuth

class WeightsManager {
	
	static let shared = WeightsManager()
	fileprivate var googleService = GoogleApiManager()
	
	var weights: ObservableObject<[Weight]?> = ObservableObject(nil)
	var splittedWeeksWeightsPeriod: ObservableObject<[WeightPeriod]?> = ObservableObject(nil)
	var splittedMonthsWeightsPeriod: ObservableObject<[WeightPeriod]?> = ObservableObject(nil)
	
	init() {
		fetchWeights()
	}
}

extension WeightsManager {
	
	var getFirstWeight: Weight? {
		weights.value?.first
	}
	var lastWeightingDate: Date {
		weights.value!.last!.date
	}
	func checkAddWeight(completion: @escaping (Bool) -> ()) {
		GoogleApiManager.shared.getWeights { result in
			switch result {
			case .success(let weights):
				if let weights = weights {
					if weights.last!.date.onlyDate < Date().onlyDate {
						completion(true)
					}
					completion(false)
				}
			case .failure(_):
				completion(false)
				return
			}
		}
	}
	func getSplittedPeriodArray(for period: TimePeriod) -> [WeightPeriod]? {
		switch period {
		case .month, .week:
			return self.splittedWeeksWeightsPeriod.value
		case .year:
			return self.splittedMonthsWeightsPeriod.value
		}
	}
	
	// Add Weight
	func replaceElseInsert(weight: Weight) {
		weights.value?.removeAll(where: { $0.date.onlyDate == weight.date.onlyDate })
		weights.value?.append(weight)
	}
	func uploadWeightImage(weightImage: UIImage, weightDate: Date, completion: @escaping (Result<String, Error>) -> ()) {
		guard let userID = Auth.auth().currentUser?.uid else { return }
		let imagePath = "\(userID)/weight_images/\(weightDate.dateStringForDB).jpeg"
		
		DispatchQueue.global(qos: .background).async {
			GoogleStorageManager.shared.uploadImage(data: weightImage.jpegData(compressionQuality: 1)!, fileName: imagePath) {
				result in
				
				switch result {
				case .success(_):
					completion(.success(imagePath))
				case .failure(let error):
					completion(.failure(error))
					//					self.presentOkAlert(withTitle: "אופס", withMessage: "שמירת התמונה נכלשה", buttonText: "אישור")
					print("Error: ", error.localizedDescription)
				}
			}
		}
	}
	func addWeights(weight: Weight, completion: @escaping (Error?) -> ()) {
		replaceElseInsert(weight: weight)
		googleService.updateWeights(weights: self.weights.value ?? [weight]) {
			error in
			if error != nil {
				completion(error)
				return
			}
			completion(nil)
		}
	}
	
	// Private
	fileprivate func fetchWeights() {
		googleService.getWeights {
			[weak self] result in
			guard let self = self else { return }
			
			switch result {
			case .success(let weights):

				if let weights = weights {
					self.weights.value = weights.sorted()
					self.splittedWeeksWeightsPeriod.value = self.splitToWeeksArray()
					self.splittedMonthsWeightsPeriod.value = self.splitToMonthsArray()
				} else {
					self.weights.value = []
				}
			case.failure(let error):
				print(error)
			}
		}
	}
	fileprivate func splitToWeeksArray() -> [WeightPeriod]? {
		guard let weights = self.weights.value else { return [] }
		if weights.isEmpty { return nil }
		
		var startDate = weights.first!.date
		var endDate = startDate.add(6.days)
		var tempWeightPeriod = WeightPeriod(startDate: startDate, endDate: endDate, weightsArray: [])
		var weightPeriodArray = [tempWeightPeriod]
		var weightPeriodIterator = 0
		
		while startDate.isEarlierThanOrEqual(to: Date().onlyDate) {
			startDate = startDate.add(7.days)
			endDate = startDate.add(6.days)
			tempWeightPeriod = WeightPeriod(startDate: startDate, endDate: endDate, weightsArray: [])
			weightPeriodArray.append(tempWeightPeriod)
		}
		
		for weight in weights {
			if weightPeriodArray[weightPeriodIterator].canContain(weight.date) {
				weightPeriodArray[weightPeriodIterator].weightsArray?.append(weight)
			} else {
				while weightPeriodArray.count != weightPeriodIterator {
					if weightPeriodArray[weightPeriodIterator].canContain(weight.date) {
						weightPeriodArray[weightPeriodIterator].weightsArray?.append(weight)
						break
					} else {
						weightPeriodIterator += 1
					}
				}
			}
		}
		return weightPeriodArray
	}
	fileprivate func splitToMonthsArray() -> [WeightPeriod]? {
		guard let weights = self.weights.value else { return [] }
		if weights.isEmpty { return nil }
		
		var startDate = weights.first!.date.start(of: .month).onlyDate
		var endDate = startDate.end(of: .month).onlyDate
		
		var tempWeightPeriod = WeightPeriod(startDate: startDate, endDate: endDate, weightsArray: [])
		var weightPeriodArray = [tempWeightPeriod]
		var weightPeriodIterator = 0
		
		while endDate.isEarlier(than: Date().onlyDate) {
			startDate = startDate.add(1.months).onlyDate
			endDate = startDate.add(1.months).subtract(1.days).onlyDate
			tempWeightPeriod = WeightPeriod(startDate: startDate, endDate: endDate, weightsArray: [])
			weightPeriodArray.append(tempWeightPeriod)
		}
		
		for weight in weights {
			if weightPeriodArray[weightPeriodIterator].canContain(weight.date) {
				weightPeriodArray[weightPeriodIterator].weightsArray?.append(weight)
			} else {
				while weightPeriodArray.count != weightPeriodIterator {
					if weightPeriodArray[weightPeriodIterator].canContain(weight.date) {
						weightPeriodArray[weightPeriodIterator].weightsArray?.append(weight)
						break
					} else {
						weightPeriodIterator += 1
					}
				}
			}
		}
		return weightPeriodArray
	}
}
