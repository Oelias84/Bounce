//
//  ChartView.swift
//  FitApp
//
//  Created by Ofir Elias on 30/06/2021.
//

import UIKit
import Charts

protocol ChartViewDelegate {
	
	func getChartData()
	var values: [Double] {get set}
	var timePeriod: TimePeriod {get set}
	var timeLinePeriod: [Date] {get set}
}

class ChartView: UIView {

	let lineChartView = LineChartView()
	var lineDataEntry: [ChartDataEntry] = []
	
	var weights = [Double]()
	var timePeriod: TimePeriod!
	var timeLinePeriod = [Date]()
	
	
	var delegate: ChartViewDelegate! {
		didSet {
			populateChart()
			cubicLineChartSetup()
		}
	}
	
	func populateChart() {
		weights = delegate.values
		timePeriod = delegate.timePeriod
		timeLinePeriod = delegate.timeLinePeriod
	}
	func cubicLineChartSetup() {
		
		self.addSubview(lineChartView)
		
		lineChartView.translatesAutoresizingMaskIntoConstraints = false
		lineChartView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		lineChartView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		lineChartView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		lineChartView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		
		lineChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInSine)
		
		cubicLineChart(dataPoints: timeLinePeriod, values: weights)
	}
	
	func cubicLineChart(dataPoints: [Date], values: [Double]) {
		
		lineChartView.backgroundColor = .white

		for i in 0..<weights.count {
			let dataPoint = ChartDataEntry(x: Double(i), y: weights[i] )
			lineDataEntry.append(dataPoint)
		}
		
		let chartData = LineChartData()
		let chartDataSet = LineChartDataSet(entries: lineDataEntry, label: "שקילות")
		
		chartData.addDataSet(chartDataSet)
		
		chartDataSet.colors = [.projectTail]
		chartDataSet.setCircleColor(.projectTail)
		chartDataSet.mode = .horizontalBezier

		chartDataSet.lineWidth = 0
		chartDataSet.circleHoleRadius = 5
		chartDataSet.circleRadius = 3
		chartDataSet.cubicIntensity = 1
		chartDataSet.drawCirclesEnabled = true
		chartDataSet.valueFormatter = ChartValuesFormatter()
		chartDataSet.valueFont = UIFont(name: "Helvetica", size: 9.0)!
		
		//Adding gradient
		let gradientColors = [UIColor.projectGreen.cgColor, UIColor.clear.cgColor] as CFArray
		let colorLocation: [CGFloat] = [1.0, 0.0]
		guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
										colors: gradientColors, locations: colorLocation) else { return }

		chartDataSet.drawFilledEnabled = true
		chartDataSet.fill = Fill(linearGradient: gradient, angle: 90.0)
		
		lineChartView.setScaleEnabled(false)
		lineChartView.legend.enabled = true
		lineChartView.rightAxis.enabled = false
		lineChartView.chartDescription?.enabled = false
		
		lineChartView.leftAxis.granularity = 1
		lineChartView.leftAxis.drawLabelsEnabled = true
		lineChartView.leftAxis.drawGridLinesEnabled = false
		
		lineChartView.xAxis.granularity = 1
		lineChartView.xAxis.gridLineDashPhase = 0
		lineChartView.xAxis.labelPosition = .bottom
		lineChartView.xAxis.gridLineDashLengths = [10, 10]
		lineChartView.xAxis.avoidFirstLastClippingEnabled = true
		lineChartView.xAxis.valueFormatter = ChartFormatter(type: timePeriod, titles: timeLinePeriod)

		lineChartView.data = chartData
	}
}


