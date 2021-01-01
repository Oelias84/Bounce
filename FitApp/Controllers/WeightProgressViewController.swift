//
//  WeightProgressViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 22/12/2020.
//

import UIKit
import Foundation
import DateToolsSwift

enum TimePeriod {
    case week
    case month
    case year
}

class WeightProgressViewController: UIViewController {
    
    
    var weightsArray = [
        Weight(date: "2020-02-02".dateFromString!, weight: 73.26),
        Weight(date: "2020-02-03".dateFromString!, weight: 71.55),
        Weight(date: "2020-02-04".dateFromString!, weight: 70.55),
        Weight(date: "2020-02-05".dateFromString!, weight: 69.96),
        
        Weight(date: "2020-02-10".dateFromString!, weight: 56.0),
        
        Weight(date: "2020-03-01".dateFromString!, weight: 56),
        Weight(date: "2020-03-02".dateFromString!, weight: 56),
        Weight(date: "2020-03-03".dateFromString!, weight: 56),
        
        Weight(date: "2020-12-08".dateFromString!, weight: 56),
        Weight(date: "2020-12-09".dateFromString!, weight: 56),
        Weight(date: "2020-12-10".dateFromString!, weight: 56),
        Weight(date: "2020-12-30".dateFromString!, weight: 56),
        
        Weight(date: "2021-3-08".dateFromString!, weight: 56),
        Weight(date: "2021-3-09".dateFromString!, weight: 56),
        Weight(date: "2021-3-10".dateFromString!, weight: 56),
        
        Weight(date: "2021-3-30".dateFromString!, weight: 56)
    ]
    var filteredArray: [Weight]? {
        didSet {
            weightDatesTableView.reloadData()
        }
    }
    var timePeriod: TimePeriod = .week
    var selectedDate: Date! {
        didSet {
            updateDateLabels()
        }
    }
    
    @IBOutlet weak var periodSegmentedControl: UISegmentedControl! {
        didSet {
            periodSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)], for: .normal)
        }
    }
    
    @IBOutlet weak var dateRightButton: UIButton!
    @IBOutlet weak var dateTextLabel: UILabel!
    @IBOutlet weak var dateLeftButton: UIButton!
        
    @IBOutlet weak var weightDatesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedDate = Date()
        filteredArray = getWeekBy(selectedDate.startOfWeek!)
        weightDatesTableView.sectionHeaderHeight = 46
    }
    
    @IBAction func periodSegmentedControlAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            timePeriod = .week
        case 1:
            timePeriod = .month
        case 2:
            timePeriod = .year
        default:
            break
        }
        updateDateLabels()
        updateFiltersArray()
    }
    @IBAction func changeDateButtons(_ sender: UIButton) {
        
        switch timePeriod {
        case .week:
            if sender == dateRightButton {
                selectedDate = selectedDate.startOfWeek?.add(1.weeks)
            } else {
                selectedDate = selectedDate.startOfWeek?.subtract(1.weeks)
            }
        case .month:
            if sender == dateRightButton {
                selectedDate = selectedDate.start(of: .month).add(1.months)
            } else {
                selectedDate = selectedDate.start(of: .month).subtract(1.months)
            }
        case .year:
            if sender == dateRightButton {
                selectedDate = selectedDate.start(of: .year).add(1.years)
            } else {
                selectedDate = selectedDate.start(of: .year).subtract(1.years)
            }
        }
        updateDateLabels()
        updateFiltersArray()
    }
    @IBAction func addWeightButtonAction(_ sender: Any) {
        
        let alert = UIAlertController(title: "הזני משקל", message: "אנא הזיני את משקלך הנוחכי", preferredStyle: .alert)
        
        alert.addTextField { (textField) in }
        
        alert.addAction(UIAlertAction(title: "אישור", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0]
            self.addWeight(textField: textField)
        }))
        alert.addAction(UIAlertAction(title: "ביטול", style: .cancel))
        self.present(alert, animated: true, completion: nil)
        
    }
    @IBAction func todayButtonAction(_ sender: Any) {
        selectedDate = Date()
        filteredArray = getWeekBy(selectedDate.startOfWeek!)
        periodSegmentedControl.selectedSegmentIndex = 0
        timePeriod = .week
        updateDateLabels()
        updateFiltersArray()
    }
    func addWeight(textField: UITextField) {
        todayButtonAction(self)
        if let weight = textField.text {
            weightsArray.append(Weight(date: Date(), weight: Double(weight)!))
            updateDateLabels()
            updateFiltersArray()
        }
    }
}

//MARK: - Delegates
extension WeightProgressViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredArray?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = weightDatesTableView.dequeueReusableCell(withIdentifier: K.CellId.weightCell) as! weightTableViewCell
        let weight = filteredArray?[indexPath.row]
        
        if indexPath.row == 0 {
            cell.differenceTextLabel.text = "-"
            cell.changeTextLabel.text = "-"
        } else {
            let difference = weight!.weight - filteredArray![indexPath.row-1].weight
            let differenceInPrecent = (weight!.weight / filteredArray![indexPath.row-1].weight)
            
            cell.changeTextLabel.text = String(format: "%.1f", differenceInPrecent)+"%"
            cell.differenceTextLabel.text = String(format: "%.1f", difference)
        }
        cell.weight = weight
        cell.timePeriod = timePeriod
        return cell
    }
    func tableView(_ View: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: View.frame.size.width, height: 18))
        let label = UILabel(frame: CGRect(x: 20, y: 20, width: headerView.frame.size.width - 38, height: headerView.frame.size.height))
        
        switch timePeriod {
        case .week:
            label.text =  " תאריך             הפרש           שינוי          משקל"
        default:
            label.text =  " תאריך             הפרש           שינוי          ממוצע"
        }
        label.textColor = .gray
        headerView.backgroundColor = .white
        headerView.addSubview(label)
        return headerView
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = filteredArray?[indexPath.row] {
            switch timePeriod {
            case .week:
                break
            case .month:
                selectedDate = cell.date
                periodSegmentedControl.selectedSegmentIndex = 0
                timePeriod = .week
            case .year:
                selectedDate = cell.date
                periodSegmentedControl.selectedSegmentIndex = 1
                timePeriod = .month
            }
            updateDateLabels()
            updateFiltersArray()
        }
    }
}

//MARK: - Function
extension WeightProgressViewController {
    
    func getWeekBy(_ date: Date) -> [Weight] {
        let weekArray = weightsArray.filter {
            $0.date >= date.startOfWeek! && $0.date <= date.endOfWeek!
        }
        return weekArray
    }
    func getMonthBy(_ date: Date) -> [Weight] {
        var weeksArray = [Weight]()
        let weeks = splitToWeeksArray()!.filter { (weekArray) -> Bool in
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
        if weightsArray.isEmpty { return nil }
        var weeksArray: [[Weight]]?
        var date = weightsArray.first!.date
        var section = 0
        
        for day in weightsArray {
            if day.date >= date.startOfWeek! && day.date <= date.endOfWeek! {
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
        if weightsArray.isEmpty { return nil }
        var yearArray: [[Weight]]?
        var year = weightsArray.first!.date.year
        var section = 0
        
        for i in 0...weightsArray.count-1 {
            
            if yearArray == nil {
                yearArray = [[weightsArray[i]]]
            } else if weightsArray[i].date.year == year {
                yearArray![section].append(weightsArray[i])
            } else {
                yearArray?.append([])
                section += 1
                year = weightsArray[i].date.year
            }
        }
        return yearArray
    }
    
    func updateDateLabels() {
        switch timePeriod {
        case .week:
            DispatchQueue.main.async {
                self.dateTextLabel.text = "\((self.selectedDate.startOfWeek?.displayDay)!) - \((self.selectedDate.endOfWeek?.displayDayInMonth)!)"
            }
        case .month:
            DispatchQueue.main.async {
                self.dateTextLabel.text = "\((self.selectedDate.displayMonth))"
            }
        case .year:
            DispatchQueue.main.async {
                self.dateTextLabel.text = "\((self.selectedDate.year))"
            }
        }
    }
    func updateFiltersArray() {
        switch timePeriod {
        case .week:
            filteredArray = getWeekBy(selectedDate)
        case .month:
            filteredArray = getMonthBy(selectedDate)
        case .year:
            filteredArray = getYearBy(selectedDate)
        }
    }
}
