//
//  WeightsViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 15/07/2022.
//

import Charts
import Foundation
import FirebaseAuth
import DateToolsSwift

class WeightsViewModel {
	
	var selectedDate: Date!
	
	fileprivate var weights: [Weight]!
	var splittedWeights: ObservableObject<[WeightPeriod]?> = ObservableObject(nil)
	
	fileprivate var googleService = GoogleApiManager()
	
	init() {
		selectedDate = Date().onlyDate
		fetchWeights()
	}
}

extension WeightsViewModel {
	
	// Get Filtered Weights
	var lastWeightingDate: Date {
		weights.last!.date
	}
	var getDailyFilteredWights: [Weight]? {
		let weightPeriod = splittedWeights.value?.first(where: { weightPeriod in
			weightPeriod.canContain(selectedDate.onlyDate)
		})
		return weightPeriod?.weightsArray
	}
	var getMonthlyFilteredWights: [Weight]? {
		guard var splitToWeeksArray = splitToWeeksArray() else { return nil }
		splitToWeeksArray = splitToWeeksArray.filter { $0.startDate >= selectedDate.onlyDate.start(of: .year) }
		var weekWeightsArray = [Weight]()
		
		for week in splitToWeeksArray {
			if week.weightsArray!.contains(where: { weight in
				weight.date.month == selectedDate.month
			}) {
				let weeklyWeightSum = week.weightsArray!.reduce(0) { accumulator, element in
					return accumulator + element.weight
				}
				let weight = Weight(dateString: week.startDate.dateStringForDB, weight: weeklyWeightSum / Double(week.weightsArray?.count ?? 0))
				weekWeightsArray.append(weight)
			}
		}
		return weekWeightsArray
	}
	var getYearlyFilteredWights: [Weight]? {
		guard var yearSplittedWeights = splitToMonthsArray() else { return nil }
		yearSplittedWeights = yearSplittedWeights.filter { $0.startDate.year == selectedDate.year }
		
		var monthWeightsArray = [Weight]()
		
		for month in yearSplittedWeights {
			let monthlyWeightSum = month.weightsArray!.reduce(0) { accumulator, element in
				return accumulator + element.weight
			}
			let weight = Weight(dateString: month.startDate.dateStringForDB, weight: monthlyWeightSum / Double(month.weightsArray?.count ?? 0))
			monthWeightsArray.append(weight)
		}
		return monthWeightsArray
	}

	// Weights Count
	var getDailyWeightsCount: Int {
		return getDailyFilteredWights?.count ?? 0
	}
	var getMonthlyWeightsCount: Int {
		return getMonthlyFilteredWights?.count ?? 0
	}
	var getYearlyWeightsCount: Int {
		guard let yearSplittedWeights = splitToMonthsArray() else { return 0 }
		let weightPeriod = yearSplittedWeights.filter( { weightPeriod in
			weightPeriod.startDate.onlyDate.year == selectedDate.onlyDate.year
		})
		return weightPeriod.count
	}
	
	// Get Weight
	func getWeights(for period: TimePeriod) -> [Weight]? {
		switch period {
		case .week:
			return getDailyFilteredWights
		case .month:
			return getMonthlyFilteredWights
		case .year:
			return getYearlyFilteredWights
		}
	}
	func getWeight(for period: TimePeriod, at row: Int) -> Weight? {
		switch period {
		case .week:
			return getDayWeight(at: row)
		case .month:
			return getMonthlyWeight(at: row)
		case .year:
			return getYearlyWeight(at: row)
		}
	}

	var getDates: (Date, Date) {
		guard let splittedWeights = splittedWeights.value else { return (Date(), Date()) }
		
		if let weightPeriod = splittedWeights.first(where: { weightPeriod in
			weightPeriod.canContain(selectedDate)
		}) {
			return (weightPeriod.startDate, weightPeriod.endDate)
		}
		return (Date(), Date())
	}
	var backButtonIsHidden: Bool {
		guard let yearSplittedWeights = getYearlyFilteredWights else { return false }
		if let firsWeightDate = yearSplittedWeights.first?.date {
			return (firsWeightDate.year > selectedDate.onlyDate.year)
		} else {
			return true
		}
	}
	
	// Private
	fileprivate func getDayWeight(at row: Int) -> Weight? {
		getDailyFilteredWights?[row]
	}
	fileprivate func getMonthlyWeight(at row: Int) -> Weight? {
		getMonthlyFilteredWights?[row]
	}
	fileprivate func getYearlyWeight(at row: Int) -> Weight? {
		getYearlyFilteredWights?[row]
	}
	
	fileprivate func fetchWeights() {
		googleService.getWeights {
			[weak self] result in
			guard let self = self else { return }
			
			switch result {
			case .success(let weights):
				if let weights = weights {
					self.weights = weights.sorted()
					self.splittedWeights.value = self.splitToWeeksArray()
				} else {
					self.weights = []
				}
			case.failure(let error):
				print(error)
			}
		}
	}
	fileprivate func splitToWeeksArray() -> [WeightPeriod]? {
		guard let weights = self.weights else { return [] }
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
		
		
//		for i in 0...weights.count-1 {
//			let weight = weights[i]
//
//			if i == weights.count-1 {
//				if tempWeightPeriod.weightsArray != nil {
//					tempWeightPeriod.weightsArray?.append(weight)
//				} else {
//					tempWeightPeriod.weightsArray = [weight]
//				}
//				weightPeriodArray.append(tempWeightPeriod)
//
//				while startDate.isEarlierThanOrEqual(to: Date().onlyDate) {
//					startDate = startDate.add(7.days)
//					endDate = startDate.add(6.days)
//					tempWeightPeriod = WeightPeriod(startDate: startDate, endDate: endDate, weightsArray: [])
//					weightPeriodArray.append(tempWeightPeriod)
//				}
//			} else {
//				if tempWeightPeriod.weightsArray != nil {
//					if tempWeightPeriod.canContain(weight.date) {
//						tempWeightPeriod.weightsArray?.append(weight)
//					} else {
//						weightPeriodArray.append(tempWeightPeriod)
//						startDate = startDate.add(7.days)
//						endDate = startDate.add(6.days)
//						tempWeightPeriod = WeightPeriod(startDate: startDate, endDate: endDate, weightsArray: [weight])
//					}
//				} else {
//					if tempWeightPeriod.canContain(weight.date) {
//						tempWeightPeriod.weightsArray = [weight]
//					} else {
//						weightPeriodArray.append(tempWeightPeriod)
//						startDate = startDate.add(7.days)
//						endDate = startDate.add(6.days)
//						tempWeightPeriod = WeightPeriod(startDate: startDate, endDate: endDate, weightsArray: [weight])
//					}
//				}
//			}
//		}
		return weightPeriodArray
	}
	fileprivate func splitToMonthsArray() -> [WeightPeriod]? {
		guard let weights = self.weights else { return [] }
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
		
//		for i in 0...weights.count-1 {
//			let weight = weights[i]
//
//			if i == weights.count-1 {
//				if tempWeightPeriod.weightsArray != nil {
//					tempWeightPeriod.weightsArray?.append(weight)
//				} else {
//					tempWeightPeriod.weightsArray = [weight]
//				}
//				weightPeriodArray.append(tempWeightPeriod)
//
//				while startDate.isEarlierThanOrEqual(to: Date().onlyDate) {
//					startDate = startDate.add(1.months).onlyDate
//					endDate = startDate.add(1.months).subtract(1.days).onlyDate
//					tempWeightPeriod = WeightPeriod(startDate: startDate, endDate: endDate, weightsArray: [])
//					weightPeriodArray.append(tempWeightPeriod)
//				}
//			} else {
//				if tempWeightPeriod.weightsArray != nil {
//					if tempWeightPeriod.canContain(weight.date.onlyDate) {
//						tempWeightPeriod.weightsArray?.append(weight)
//					} else {
//						weightPeriodArray.append(tempWeightPeriod)
//						startDate = startDate.add(1.months).onlyDate
//						endDate = startDate.add(1.months).subtract(1.days).onlyDate
//						tempWeightPeriod = WeightPeriod(startDate: startDate, endDate: endDate, weightsArray: [weight])
//					}
//				} else {
//					if tempWeightPeriod.canContain(weight.date.onlyDate) {
//						tempWeightPeriod.weightsArray = [weight]
//					} else {
//						weightPeriodArray.append(tempWeightPeriod)
//						startDate = startDate.add(1.months).onlyDate
//						endDate = startDate.add(1.months).subtract(1.days).onlyDate
//						tempWeightPeriod = WeightPeriod(startDate: startDate, endDate: endDate, weightsArray: [weight])
//					}
//				}
//			}
//		}
		return weightPeriodArray
	}
	
	fileprivate func replaceElseInsert(weight: Weight) {
		weights?.removeAll(where: { $0.date.onlyDate == weight.date.onlyDate })
		weights?.append(weight)
	}
	fileprivate func uploadWeightImage(weightImage: UIImage, weightDate: Date, completion: @escaping (Result<String, Error>) -> ()) {
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
	
	func addWeight(weight: Double, image: UIImage?, date: Date? = nil, completion: @escaping (Error?) -> ()) {
		let weightDate = date ?? Date()
		let group = DispatchGroup()
		var path: URL?
		
		if let image = image {
			var imagePath: String!
			
			group.enter()
			uploadWeightImage(weightImage: image, weightDate: weightDate) {
				result in
				switch result {
				case .success(let path):
					imagePath = path
					group.leave()
				case .failure(let error):
					completion(error)
					return
				}
			}
			DispatchQueue.global(qos: .userInteractive).async {
				group.wait()
				group.enter()
				GoogleStorageManager.shared.downloadURL(path: imagePath) {
					result in
					switch result {
					case .success(let url):
						path = url
					case .failure(_):
						path = nil
					}
					group.leave()
				}

				group.wait()
				group.enter()
				let weight = Weight(dateString: weightDate.dateStringForDB, weight: weight, imagePath: path?.absoluteString)
				self.replaceElseInsert(weight: weight)

				self.googleService.updateWeights(weight: self.weights ?? [weight]) {
					error in
					if error != nil {
						completion(error)
						return
					}
					group.leave()
				}
			}
		} else {
			let weight = Weight(dateString: weightDate.dateStringForDB, weight: weight, imagePath: path?.absoluteString)
			
			self.weights?.append(weight)
			
			self.googleService.updateWeights(weight: self.weights ?? [weight]) {
				error in
				if error != nil {
					completion(error)
					return
				}
				group.leave()
			}
		}
		group.notify(queue: .main) {
			completion(nil)
		}
	}
}
