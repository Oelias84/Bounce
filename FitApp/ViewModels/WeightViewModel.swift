//
//  WeightViewModel.swift
//  FitApp
//
//  Created by iOS Bthere on 07/01/2021.
//

import Foundation

class WeightViewModel: NSObject {
    
    var weights: [Weight]? {
        didSet {
            self.bindWeightViewModelToController()
        }
    }
    private var googleService: GoogleApiManager!
    
    var bindWeightViewModelToController : (() -> ()) = {}
    
    override init() {
        super.init()
        
        googleService = GoogleApiManager()
        fetchWeights()
    }
    
    func getWeekBy(_ date: Date) -> [Weight] {
        guard let weights = self.weights else { return [] }
        let weekArray = weights.filter {
			$0.date.day >= date.startOfWeek!.day && $0.date.day <= date.endOfWeek!.day
        }
        return weekArray
    }
    func getMonthBy(_ date: Date) -> [Weight] {
        var weeksArray = [Weight]()
        guard var weeks = splitToWeeksArray() else { return [] }
        weeks = weeks.filter { (weekArray) -> Bool in
			weekArray.first?.date.month == date.month && weekArray.first?.date.year == date.year
        }
        
        if weeks.isEmpty { return [] }
        for i in 0...weeks.count-1 {
			let date = weeks[i].first!.date
            var weight = 0.0
            for j in 0...weeks[i].count-1 {
                weight += weeks[i][j].weight
            }
            weight = weight / Double(weeks[i].count)
			weeksArray.append(Weight(date: date, weight: weight))
        }
        return weeksArray
    }
    func getYearBy(_ date: Date) -> [Weight] {
        var monthsArray = [Weight]()
        if let year = splitToYearsArray()?.first(where: { $0.first?.date.year == date.year }), !year.isEmpty {
            let yearMonths = splitToMonthsArray(weightsArray: year)!
            
            for month in yearMonths {
                let monthDate = month.first!.date
                var weight = 0.0
                for day in month {
                    weight += day.weight
                }
				monthsArray.append(Weight(date: monthDate, weight: weight / Double(month.count)))
                weight = 0.0
            }
        }
        return monthsArray
    }
    
    func splitToWeeksArray() -> [[Weight]]? {
        guard let weights = self.weights else { return [] }
        if weights.isEmpty { return nil }
        var weeksArray: [[Weight]]?
		var date = weights.first!.date
        var section = 0
        
        for day in weights {
			
			if day.date.day >= date.startOfWeek!.day && day.date.day <= date.endOfWeek!.day {
                if weeksArray == nil {
                    weeksArray = [[day]]
                } else {
                    weeksArray?[section].append(day)
                }
            } else {
                date = day.date
                section += 1
                weeksArray?.append([day])
            }
        }
        return weeksArray
    }
    func splitToMonthsArray(weightsArray: [Weight]) -> [[Weight]]? {
        if weightsArray.isEmpty { return nil }
        var monthArray: [[Weight]] = [[Weight]()]
        
        var month = weightsArray.first!.date
        var section = 0
        var weight = 0.0
        var monthDays = 0.0
        for day in weightsArray {
            if day.date.month != month.month {
				monthArray[section].append(Weight(date: month, weight: weight / monthDays))
                monthArray.append([Weight]())
                section += 1
                month = day.date
                weight = day.weight
                monthDays = 0
            } else if day.date.month == month.month {
                weight += day.weight
                monthDays += 1
            }
        }
		monthArray[section].append(Weight(date: month, weight: weight / monthDays))
        return monthArray
    }
    func splitToYearsArray() -> [[Weight]]? {
        guard let weights = self.weights else { return [] }
        if weights.isEmpty { return nil }
        var yearArray: [[Weight]]?
        var year = weights.first!.date.year
        var section = 0
        
        for i in 0...weights.count-1 {
            
            if yearArray == nil {
                yearArray = [[weights[i]]]
            } else if weights[i].date.year == year {
                yearArray![section].append(weights[i])
            } else {
                yearArray?.append([])
                section += 1
                year = weights[i].date.year
            }
        }
        return yearArray
    }
    
    func fetchWeights() {
        googleService.getWeights { result in
            switch result {
            case .success(let weights):
                if let weights = weights {
					self.weights = weights.sorted()
                } else {
                    self.weights = []
                }
            case.failure(let error):
                print(error)
            }
        }
    }
    func addWeight(){
        guard let weights = self.weights else { return }
        let weightsModel = Weights(weights: weights)
        
        googleService.updateWeights(weights: weightsModel)
    }
}
