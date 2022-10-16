//
//  WeightsViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 15/07/2022.
//

import UIKit
import Charts
import SDWebImage
import Foundation
import FirebaseAuth
import DateToolsSwift
import CropViewController
import BetterSegmentedControl

enum TimePeriod {

	case week
	case month
	case year
}

class WeightsViewController: UIViewController {
	
	var viewModel: WeightsViewModel!
	
	var values = [Double]()
	var timeLinePeriod = [Date]()
	var timePeriod: TimePeriod = .week
	
	private var weightImage: UIImage?
	private var weightAlert: AddWeightAlertView?
	private let imagePickerController = UIImagePickerController()
	
	@IBOutlet weak var chartView: UIView!
	@IBOutlet weak var chartViewContainer: UIView!
	@IBOutlet weak var todayButton: UIButton!
	@IBOutlet weak var dateRightButton: UIButton!
	@IBOutlet weak var dateTextLabel: UILabel!
	@IBOutlet weak var dateLeftButton: UIButton!
	@IBOutlet weak var addWeightButton: UIButton!
	
	@IBOutlet weak var topBarView: BounceNavigationBarView!
	@IBOutlet weak var segmentedControl: BetterSegmentedControl!
	
	@IBOutlet weak var tableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		viewModel = WeightsViewModel()
		setupView()
		bindViewModel()
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		topBarView.setImage()
	}
	
	@IBAction func todayButtonAction(_ sender: Any) {
		viewModel.selectedDate = Date()
		updateView()
	}
	@IBAction func addWeightButtonAction(_ sender: Any) {
		
		addWeightButton.isEnabled = false
		if viewModel.didWeightForCurrentDate {
			presentOkAlert(withMessage: "כבר נשקלת היום")
		} else {
			presentAddWeightAlert()
		}
	}
	@IBAction func changeDateButtons(_ sender: UIButton) {
		
		switch timePeriod {
		case .week:
			if sender == dateRightButton {
				self.viewModel.selectedDate = self.viewModel.selectedDate.add(1.weeks)
			} else {
				self.viewModel.selectedDate = self.viewModel.selectedDate.subtract(1.weeks)
			}
		case .month:
			if sender == dateRightButton {
				self.viewModel.selectedDate = self.viewModel.selectedDate.start(of: .month).add(1.months)
			} else {
				self.viewModel.selectedDate = self.viewModel.selectedDate.start(of: .month).subtract(1.months)
			}
		case .year:
			if sender == dateRightButton {
				self.viewModel.selectedDate = self.viewModel.selectedDate.start(of: .year).add(1.years)
			} else {
				self.viewModel.selectedDate = self.viewModel.selectedDate.start(of: .year).subtract(1.years)
			}
		}
		updateView()
	}
	@IBAction func segmentedControlAction(_ sender: BetterSegmentedControl) {
		switch sender.index {
		case 0:
			timePeriod = .week
		case 1:
			timePeriod = .month
		case 2:
			timePeriod = .year
		default:
			break
		}
		viewModel.updateSplittedWeights(for: timePeriod)
		updateView()
	}
}

//MARK: - Delegates
extension WeightsViewController: CropViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
	
	func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
		cropViewController.dismiss(animated: true) {
			if let imageData = image.jpegData(compressionQuality: 0.2) {
				self.weightImage = UIImage(data: imageData)
				self.weightAlert?.changeCheckMarkState()
			}
		}
	}
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		if let image = info[.originalImage] as? UIImage {
			picker.dismiss(animated: true) {
				self.presentCropViewController(image: image, type: .default)
			}
		}
	}
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true)
	}
}
extension WeightsViewController: AddWeightAlertViewDelegate {
	
	func cancelButtonAction() {
		weightAlert?.removeFromSuperview()
		weightAlert = nil
		Spinner.shared.stop()
		addWeightButton.isEnabled = true
	}
	func cameraButtonTapped() {
		presentImagePickerActionSheet(imagePicker: imagePickerController) {_ in}
	}
	func confirmButtonAction(weight: String, date: Date?, imagePath: String?) {
		guard let weightDouble = Double(weight) else { return }
		Spinner.shared.show(self.view)
		
		if weightDouble>150 || weightDouble<30 {
			weightAlert = nil
			Spinner.shared.stop()
			self.presentOkAlert(withTitle: "אופס", withMessage: StaticStringsManager.shared.getGenderString?[34] ?? "")
			addWeightButton.isEnabled = true
		} else {
			if let weightTab = self.tabBarController?.tabBar.items?[3] {
				weightTab.image = UIImage(named:"Weight")
			}
			self.weightAlert?.removeFromSuperview()
			self.weightAlert = nil
			
			self.viewModel.addWeight(weight: weightDouble, image: weightImage, imagePath: imagePath, date: date) {
				error in
				Spinner.shared.stop()
				self.addWeightButton.isEnabled = true
				if error != nil {
					self.presentOkAlert(withMessage: "משהו קרה נבו במועד מאוחר יותר")
				}
			}
		}
	}
}
extension WeightsViewController: weightTableViewCellDelegate {
	
	func presentImage(image: UIImage) {
		let photoViewer = PhotoViewerViewController(image: image)
		present(photoViewer, animated: true)
	}
}
extension WeightsViewController: ChartViewDelegate {
	
	func getChartData() {}
}
extension WeightsViewController: BounceNavigationBarDelegate {
	
	func backButtonTapped() {
		return
	}
}
extension WeightsViewController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ View: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headerView = UIView(frame: CGRect(x: 0, y: 0, width: View.frame.size.width, height: 20))
		let label = UILabel(frame: CGRect(x: 0, y: 0, width: headerView.frame.size.width - 38, height: headerView.frame.size.height))
		
		switch timePeriod {
		case .week:
			label.text =  "        תאריך                הפרש                  משקל"
		default:
			label.text =  " תאריך             הפרש           שינוי          ממוצע"
		}
		label.textColor = .black
		headerView.backgroundColor = .projectBackgroundColor
		headerView.addSubview(label)
		return headerView
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch timePeriod {
		case .week:
			return viewModel.getDailyWeightsCount
		case .month:
			return viewModel.getMonthlyWeightsCount
		case .year:
			return viewModel.getYearlyWeightsCount
		}
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.weightCell) as! weightTableViewCell
		let weightData = viewModel.getWeight(for: timePeriod, at: indexPath.row)
		
		if indexPath.row == 0 {
			cell.differenceTextLabel.text = "-"
			cell.changeTextLabel.text = "-"
		} else {
			let difference: Decimal = {
				let weight = weightData!.decimalWeight
				let lastWeight = viewModel.getWeight(for: timePeriod, at: indexPath.row-1)?.decimalWeight ?? weight
				
				switch timePeriod {
				case .week:
					return Decimal(string: weight.shortFraction())! - Decimal(string: lastWeight.shortFraction())!
				case .month, .year:
					return weight - lastWeight
				}
			}()
			let differenceInPrecent = (difference / weightData!.decimalWeight) * 100.0
			
			cell.changeTextLabel.text = differenceInPrecent.isNaN ? "-" : differenceInPrecent.shortFraction() + "%"
			cell.differenceTextLabel.text = difference.isNaN ? "-" : difference.shortFraction()
		}
		
		cell.delegate = self
		cell.setupCell(weight: weightData!, timePeriod: timePeriod)
		return cell
	}
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		30
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let weight = viewModel.getWeight(for: timePeriod, at: indexPath.row)

		switch timePeriod {
		case .week:
			presentAddWeightAlert(weight: weight)
		case .month:
			viewModel.selectedDate = weight?.date
			segmentedControl.setIndex(0)
			timePeriod = .week
		case .year:
			return
		}
		updateView()
	}
}

//MARK: - Functions
extension WeightsViewController {
	
	fileprivate func setupView() {
		chartViewContainer.cellView()

		segmentedControl.backgroundColor = .projectBackgroundColor
		segmentedControl.borderColorV = .projectGray.withAlphaComponent(0.2)
		segmentedControl.borderWidthV = 1
		
		segmentedControl.options = [
			.cornerRadius(20),
			.indicatorViewBackgroundColor(.projectTail),
		]
		
		segmentedControl.segments =  [
			LabelSegment(text: "שבוע", normalFont: UIFont(name: "Assistant-SemiBold", size: 18), normalTextColor: .black, selectedTextColor: .white),
			LabelSegment(text: "חודש", normalFont: UIFont(name: "Assistant-SemiBold", size: 18), normalTextColor: .black, selectedTextColor: .white),
			LabelSegment(text: "שנה", normalFont: UIFont(name: "Assistant-SemiBold", size: 18), normalTextColor: .black, selectedTextColor: .white),
		]
		
		topBarView.delegate = self
		topBarView.nameTitle = "מעקב שקילה"
		topBarView.isMotivationHidden = true
		topBarView.isDayWelcomeHidden = true
		topBarView.isBackButtonHidden = true
		topBarView.isDayWelcomeHidden = true
		topBarView.isProfileButtonHidden = false
		dateLeftButton.isHidden = true
	}
	fileprivate func updateView() {
		updateDateLabels()
		updateTableView()
		updateButtons()
	}
	fileprivate func addChartView() {
		let lineChat = ChartView(frame: CGRect(x: 0, y: 0, width: self.chartView.frame.width, height: self.chartView.frame.height))
		lineChat.delegate = self
		
		self.chartView.addSubview(lineChat)
	}
	fileprivate func bindViewModel() {
		
		viewModel.splittedWeights.bind {
			weights in
			
			if weights != nil {
				self.updateView()
			}
		}
	}
	fileprivate func populateChart() {
		guard let weightsArray = self.viewModel.getWeights(for: self.timePeriod) else { return }
		let weights = weightsArray.map { $0.weight.isNaN ? 0 : $0.weight }
		let weightsDates = weightsArray.map { $0.date }
		
		self.values = weights
		self.timeLinePeriod = weightsDates
	}
	fileprivate func updateTableView() {
		DispatchQueue.main.async {
			self.populateChart()
			self.addChartView()
			self.getChartData()
			self.tableView.reloadData()
			
			if let wights = self.viewModel.getWeights(for: self.timePeriod), !wights.isEmpty {
				self.tableView.scrollToRow(at: IndexPath(row: wights.count - 1, column: 0), at: .bottom, animated: true)
			}
		}
	}
	fileprivate func updateDateLabels() {
		let dates = self.viewModel.getDates
		let startDate = dates.0
		let endDate = dates.1
		
		DispatchQueue.main.async {
			[weak self] in
			guard let self = self else { return }
			
			switch self.timePeriod {
			case .week:
				self.dateTextLabel.text = "\(startDate.displayDayInMonth) - \(endDate.displayDayInMonth)"
			case .month:
				self.dateTextLabel.text = "\((self.viewModel.selectedDate!.displayMonthAndYear))"
			case .year:
				self.dateTextLabel.text = "\((self.viewModel.selectedDate!.year))"
			}
		}
	}
	fileprivate func updateButtons() {
		DispatchQueue.main.async {
			self.dateRightButton.isHidden = self.viewModel.forwardButtonIsHidden(period: self.timePeriod)
			self.dateLeftButton.isHidden = self.viewModel.backButtonIsHidden(period: self.timePeriod)
		}
	}
	
	fileprivate func presentAddWeightAlert(weight: Weight? = nil) {
		let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
		
		imagePickerController.delegate = self
		weightAlert = AddWeightAlertView(weight: weight)
		weightAlert?.delegate = self
		weightAlert?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width,
									height: UIScreen.main.bounds.size.height)
		if let alert = weightAlert {
			window?.addSubview(alert)
			if let navView = self.navigationController?.view {
				Spinner.shared.show(navView)
			}
		}
	}
}
