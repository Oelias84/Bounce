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
    
    private var weightViewModel: WeightViewModel!
    private var filteredArray: [Weight]? {
    didSet {
        tableView.reloadData()
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
        
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedDate = Date()
        callToViewModelForUIUpdate()
        tableView.sectionHeaderHeight = 46
    }
    
    @IBAction func todayButtonAction(_ sender: Any) {
        selectedDate = Date()
        filteredArray = weightViewModel.getWeekBy(selectedDate.startOfWeek!)
        periodSegmentedControl.selectedSegmentIndex = 0
        timePeriod = .week
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
}

//MARK: - Delegates
extension WeightProgressViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let weights = filteredArray {
            return weights.count
        } else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.weightCell) as! weightTableViewCell
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
            filteredArray = weightViewModel.getWeekBy(selectedDate)
        case .month:
            filteredArray = weightViewModel.getMonthBy(selectedDate)
        case .year:
            filteredArray = weightViewModel.getYearBy(selectedDate)
        }
    }
    func addWeight(textField: UITextField) {
        todayButtonAction(self)
        
        if let weights = weightViewModel.weights, weights.contains(where: { $0.date.day == Date().day }) {
            presentOkAlert(withMessage: "כבר נשקלת היום") {}
            return
        } else if let weight = textField.text {
            let weight = Weight(date: Date(), weight: Double(weight)!)
            weightViewModel.weights?.append(weight)
            weightViewModel.addWeight()
            updateDateLabels()
            updateFiltersArray()
        }
    }
}

extension WeightProgressViewController {
    
    private func updateDataSource() {
		Spinner.shared.stop()
        filteredArray = weightViewModel.getWeekBy(selectedDate.startOfWeek!)
        self.tableView.reloadData()
    }
    private func callToViewModelForUIUpdate() {
		Spinner.shared.show(self.view)
        self.weightViewModel = WeightViewModel()
        
        self.weightViewModel!.bindWeightViewModelToController = {
            self.updateDataSource()
        }
    }
}
