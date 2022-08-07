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
	
	fileprivate var weightsManager = WeightsManager.shared
	
	init() {
		selectedDate = Date().onlyDate
		
		weightsManager.splittedWeeksWeightsPeriod.bind { data in
			if data != nil {
				self.splittedWeights.value = data
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
	var backButtonIsHidden: Bool {
		guard let yearSplittedWeights = splittedWeights.value else { return false }
		
		if let firsWeightDate = yearSplittedWeights.first?.weightsArray?.first?.date {
			return (firsWeightDate.year >= selectedDate.onlyDate.year)
		} else {
			return true
		}
	}
	var didWeightForCurrentDate: Bool {
		weightsManager.lastWeightingDate == Date().onlyDate
	}

	// Get Weights Count
	var getDailyWeightsCount: Int {
		return getDailyFilteredWights(for: selectedDate)?.count ?? 0
	}
	var getMonthlyWeightsCount: Int {
		return getMonthlyFilteredWights(for: selectedDate)?.count ?? 0
	}
	var getYearlyWeightsCount: Int {
		return getYearlyFilteredWights(for: selectedDate)?.count ?? 0
	}

	// Get Weights
	func getWeights(for period: TimePeriod) -> [Weight]? {
		switch period {
		case .week:
			return getDailyFilteredWights(for: selectedDate)
		case .month:
			return getMonthlyFilteredWights(for: selectedDate)
		case .year:
			return getYearlyFilteredWights(for: selectedDate)
		}
	}
	func getWeight(for period: TimePeriod, at row: Int) -> Weight? {
		switch period {
		case .week:
			return getDayWeight(for: selectedDate, at: row)
		case .month:
			return getMonthlyWeight(for: selectedDate, at: row)
		case .year:
			return getYearlyWeight(for: selectedDate, at: row)
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
	fileprivate func getDailyFilteredWights(for selectedDate: Date) -> [Weight]? {
		let weightPeriod = splittedWeights.value?.first(where: { weightPeriod in
			weightPeriod.canContain(selectedDate.onlyDate)
		})
		return weightPeriod?.weightsArray
	}
	fileprivate func getMonthlyFilteredWights(for selectedDate: Date) -> [Weight]? {
		guard var splitToWeeksArray = splittedWeights.value else { return nil }
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
	fileprivate func getYearlyFilteredWights(for selectedDate: Date) -> [Weight]? {
		guard var yearSplittedWeights = splittedWeights.value else { return nil }
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
	
	fileprivate func getDayWeight(for date: Date, at row: Int) -> Weight? {
		return getDailyFilteredWights(for: date)?[row]
	}
	fileprivate func getMonthlyWeight(for date: Date, at row: Int) -> Weight? {
		return getMonthlyFilteredWights(for: date)?[row]
	}
	fileprivate func getYearlyWeight(for date: Date, at row: Int) -> Weight? {
		return getYearlyFilteredWights(for: date)?[row]
	}
	
}
