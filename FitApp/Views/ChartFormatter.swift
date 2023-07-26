//
//  ChartFormatter.swift
//  FitApp
//
//  Created by Ofir Elias on 29/06/2021.
//

import Charts
import Foundation

@objc(ChartFormatter)
class ChartFormatter: NSObject, AxisValueFormatter {
	
	let dates: [Date]
	let type: TimePeriod

	init(type: TimePeriod, titles: [Date]) {
		self.dates = titles
		self.type = type
	}
	
	func stringForValue(_ value: Double, axis: AxisBase?) -> String {
		
		if dates.count == 1 {
			if value == 0.0 {
				return stringDateByType(index: 0)
			} else {
				return ""
			}
		} else {
			return stringDateByType(index: Int(value.whole))
		}
	}
	private func stringDateByType(index: Int) -> String {

		switch type {
		case .week:
			return dates[index].displayDay
		case .month:
			return "\(dates[index].startOfWeek!.displayDay)-\(dates[index].endOfWeek!.displayDayInMonth)"
		case .year:
			return dates[index].displayOnlyMonth
		}
	}
}

class ChartValuesFormatter: ValueFormatter {
	
	func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
		return String(format: "%.1f", value)
	}
}
