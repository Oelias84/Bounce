//
//  WeightsViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 15/07/2022.
//

import Charts
import Foundation
import DateToolsSwift

class WeightsViewModel {
	
	var selectedDate: Date!
	var splittedWeights: ObservableObject<[WeightPeriod]?> = ObservableObject(nil)
	
	fileprivate var weightsManager: WeightsManager!
	
	init(userUID: String? = nil) {
		selectedDate = Date().onlyDate
		
		if userUID != nil {
			splittedWeights = ObservableObject(nil)
			weightsManager = WeightsManager(userID: userUID)
			weightsManager.splittedWeeksWeightsPeriod.bind { data in
				if data != nil {
					self.splittedWeights.value = data
				}
			}
		} else {
			weightsManager = WeightsManager.shared
			weightsManager.splittedWeeksWeightsPeriod.bind { data in
				if data != nil {
					self.splittedWeights.value = data
				}
			}
		}
	}
}

extension WeightsViewModel {
	
	var getDates: (Date, Date) {
		guard let splittedWeights = splittedWeights.value else { return (Date(), Date()) }
		
		if let weightPeriod = splittedWeights.first(where: { weightPeriod in
			weightPeriod.canContain(selectedDate)
		}) {
			return (weightPeriod.startDate, weightPeriod.endDate)
		}
		return (Date(), Date())
	}
	
	func backButtonIsHidden(period: TimePeriod) -> Bool {
		guard let splittedWeights = splittedWeights.value else { return false }
		if let firsWeightDate = splittedWeights.first?.weightsArray?.first?.date {
			
			switch period {
			case .week:
				return selectedDate.onlyDate <= firsWeightDate.onlyDate
			case .month:
				return selectedDate.year <= firsWeightDate.year && selectedDate.month <= firsWeightDate.month
			case .year:
				return selectedDate.year <= firsWeightDate.year
			}
		} else {
			return true
		}
	}
	func forwardButtonIsHidden(period: TimePeriod) -> Bool {

		switch period {
		case .week:
			return selectedDate.onlyDate >= Date().onlyDate
		case .month:
			return selectedDate.year >= Date().year && selectedDate.month >= Date().month
		case .year:
			return selectedDate.year >= Date().year
		}
	}
	
	var didWeightForCurrentDate: Bool {
		weightsManager.lastWeightingDate == Date().onlyDate
	}
	
	// Get Weights Count
	var getDailyWeightsCount: Int {
		return getDailyFilteredWights()?.count ?? 0
	}
	var getMonthlyWeightsCount: Int {
		return getMonthlyFilteredWights()?.count ?? 0
	}
	var getYearlyWeightsCount: Int {
		return getYearlyFilteredWights()?.count ?? 0
	}
	
	// Get Weights
	func getWeights(for period: TimePeriod) -> [Weight]? {
		switch period {
		case .week:
			return getDailyFilteredWights()
		case .month:
			return getMonthlyFilteredWights()
		case .year:
			return getYearlyFilteredWights()
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
	
	// Update Weights
	func addWeight(weight: Double, image: UIImage?, imagePath: String?, date: Date? = nil, completion: @escaping (Error?) -> ()) {
		let weightDate = date ?? Date()
		let group = DispatchGroup()
		var path: URL?
		
		if let image = image {
			var imagePath: String!
			
			group.enter()
			weightsManager.uploadWeightImage(weightImage: image, weightDate: weightDate) {
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
				
				self.weightsManager.addWeights(weight: weight) {
					error in
					if error != nil {
						completion(error)
						return
					}
					group.leave()
				}
			}
		} else {
			group.enter()
			let weight = Weight(dateString: weightDate.dateStringForDB, weight: weight, imagePath: path?.absoluteString ?? imagePath)
			self.weightsManager.addWeights(weight: weight) {
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
	
	// Update Splitted Weights
	func updateSplittedWeights(for period: TimePeriod) {
		splittedWeights.value = weightsManager.getSplittedPeriodArray(for: period)
	}
	
	// Private
	fileprivate func getDailyFilteredWights() -> [Weight]? {
		let weightPeriod = splittedWeights.value?.first(where: { weightPeriod in
			weightPeriod.canContain(selectedDate.onlyDate)
		})
		return weightPeriod?.weightsArray
	}
	fileprivate func getMonthlyFilteredWights() -> [Weight]? {
		guard var splitToWeeksArray = splittedWeights.value else { return nil }
		splitToWeeksArray = splitToWeeksArray.filter { $0.startDate >= selectedDate.onlyDate.start(of: .year) }
		var weekWeightsArray = [Weight]()
		
		for week in splitToWeeksArray {
			if week.weightsArray!.contains(where: { weight in
				weight.date.month == selectedDate.month
			}) {
				let calculatedWeight = (week.weightsSum / Decimal(week.weightsArray?.count ?? 0))
				let weight = Weight(dateString: week.startDate.dateStringForDB, weight: Double(calculatedWeight.shortFraction())!)
				
				weekWeightsArray.append(weight)
			}
		}
		return weekWeightsArray
	}
	fileprivate func getYearlyFilteredWights() -> [Weight]? {
		guard var yearSplittedWeights = splittedWeights.value else { return nil }
		yearSplittedWeights = yearSplittedWeights.filter { $0.startDate.year == selectedDate.year }
		var monthWeightsArray = [Weight]()
		
		for month in yearSplittedWeights {
			let calculatedWeight = (month.weightsSum / Decimal(month.weightsArray?.count ?? 0))
			let weight = Weight(dateString: month.startDate.dateStringForDB, weight: Double(calculatedWeight.shortFraction())!)
			
			monthWeightsArray.append(weight)
		}
		return monthWeightsArray
	}
	
	fileprivate func getDayWeight(at row: Int) -> Weight? {
		return getDailyFilteredWights()?[row]
	}
	fileprivate func getMonthlyWeight(at row: Int) -> Weight? {
		return getMonthlyFilteredWights()?[row]
	}
	fileprivate func getYearlyWeight(at row: Int) -> Weight? {
		return getYearlyFilteredWights()?[row]
	}
}
