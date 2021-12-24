//
//  WeightProgressViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 22/12/2020.
//

import UIKit
import Charts
import SDWebImage
import Foundation
import DateToolsSwift
import CropViewController
import BetterSegmentedControl

enum TimePeriod {
	
	case week
	case month
	case year
}

class WeightProgressViewController: UIViewController {
	
	
	private var weightViewModel: WeightViewModel!
	private var filteredArray: [Weight]? {
		didSet {
			DispatchQueue.main.async {
				[unowned self] in
				populateChart()
				addChartView()
				tableView.reloadData()
			}
		}
	}
	
	private var selectedDate: Date! {
		didSet {
			updateDateLabels()
		}
	}
	
	private var weightImage: UIImage?
	private var weightAlert: AddWeightAlertView?
	private let imagePickerController = UIImagePickerController()
	
	internal var values = [Double]()
	internal var timeLinePeriod = [Date]()
	internal var timePeriod: TimePeriod = .week
	
	@IBOutlet weak var chartView: UIView!
	@IBOutlet weak var chartViewContainer: UIView! {
		didSet {
			chartViewContainer.buttonShadow()
		}
	}
	
	@IBOutlet weak var todayButton: UIButton!
	@IBOutlet weak var dateRightButton: UIButton!
	@IBOutlet weak var dateTextLabel: UILabel!
	@IBOutlet weak var dateLeftButton: UIButton!
	
	@IBOutlet weak var topBarView: BounceNavigationBarView!
	@IBOutlet weak var segmentedControl: BetterSegmentedControl!
	
	@IBOutlet weak var tableView: UITableView!
	
	deinit {
		removeKeyboardListener()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupView()
		selectedDate = Date()
		callToViewModelForUIUpdate()
		dateRightButton.isHidden = true
		tableView.sectionHeaderHeight = 46
	}
	
	@IBAction func todayButtonAction(_ sender: Any) {
		selectedDate = Date()
		filteredArray = weightViewModel.getWeekBy(selectedDate.startOfWeek!)
		segmentedControl.setIndex(0)
		timePeriod = .week
		updateDateLabels()
		updateFiltersArray()
	}
	@IBAction func addWeightButtonAction(_ sender: Any) {
		if let weights = weightViewModel.weights, !weights.isEmpty, weights.last!.date.onlyDate == Date().onlyDate {
			presentOkAlert(withMessage: "כבר נשקלת היום") { 	return }
		} else {
			presentAddWeightAlert()
		}
	}
	@IBAction func changeDateButtons(_ sender: UIButton) {
		
		switch timePeriod {
		case .week:
			if sender == dateRightButton {
				selectedDate = selectedDate.startOfWeek?.add(1.weeks)
			} else {
				selectedDate = selectedDate.startOfWeek?.subtract(1.weeks)
			}
			dateRightButton.isHidden = selectedDate.onlyDate >= Date().startOfWeek!.onlyDate
		case .month:
			if sender == dateRightButton {
				selectedDate = selectedDate.start(of: .month).add(1.months)
			} else {
				selectedDate = selectedDate.start(of: .month).subtract(1.months)
			}
			dateRightButton.isHidden = selectedDate.onlyDate >= Date().start(of: .month).onlyDate
		case .year:
			if sender == dateRightButton {
				selectedDate = selectedDate.start(of: .year).add(1.years)
			} else {
				selectedDate = selectedDate.start(of: .year).subtract(1.years)
			}
			dateRightButton.isHidden = selectedDate.onlyDate >= Date().start(of: .year).onlyDate
		}
		updateDateLabels()
		updateFiltersArray()
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
		updateDateLabels()
		updateFiltersArray()
	}
}

//MARK: - TableView
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
			let differenceInPrecent = ( difference / weight!.weight) * 100
			
			cell.changeTextLabel.text = String(format: "%.1f", differenceInPrecent)+"%"
			cell.differenceTextLabel.text = String(format: "%.1f", difference)
		}
		cell.delegate = self
		cell.weight = weight
		cell.timePeriod = timePeriod
		return cell
	}
	func tableView(_ View: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headerView = UIView(frame: CGRect(x: 0, y: 0, width: View.frame.size.width, height: 18))
		let label = UILabel(frame: CGRect(x: 20, y: 20, width: headerView.frame.size.width - 38, height: headerView.frame.size.height))
		
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
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let cell = filteredArray?[indexPath.row] {
			switch timePeriod {
			case .week:
				presentAddWeightAlert(weight: cell)
			case .month:
				selectedDate = cell.date
				segmentedControl.setIndex(0)
				timePeriod = .week
			case .year:
				selectedDate = cell.date
				segmentedControl.setIndex(1)
				timePeriod = .month
			}
			updateDateLabels()
			updateFiltersArray()
		}
	}
}

//MARK: - Functions
extension WeightProgressViewController {
	
	private func setupView() {
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
	}
	private func updateDateLabels() {
		switch timePeriod {
		case .week:
			DispatchQueue.main.async { [weak self] in
				guard let self = self else { return }
				self.dateTextLabel.text = "\((self.selectedDate.startOfWeek?.displayDayInMonth)!) - \((self.selectedDate.endOfWeek?.displayDayInMonth)!)"
			}
		case .month:
			DispatchQueue.main.async { [weak self] in
				guard let self = self else { return }
				self.dateTextLabel.text = "\((self.selectedDate.displayMonth))"
			}
		case .year:
			DispatchQueue.main.async { [weak self] in
				guard let self = self else { return }
				self.dateTextLabel.text = "\((self.selectedDate.year))"
			}
		}
	}
	private func updateFiltersArray() {
		switch timePeriod {
		case .week:
			filteredArray = weightViewModel.getWeekBy(selectedDate).sorted()
		case .month:
			filteredArray = weightViewModel.getMonthBy(selectedDate).sorted()
		case .year:
			filteredArray = weightViewModel.getYearBy(selectedDate).sorted()
		}
	}
	private func presentAddWeightAlert(weight: Weight? = nil) {
		let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
		
		imagePickerController.delegate = self
		weightAlert = AddWeightAlertView(weight: weight)
		weightAlert?.delegate = self
		weightAlert?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width,
									height: UIScreen.main.bounds.size.height)
		if let alert = weightAlert {
			window?.addSubview(alert)
		}
	}
	private func addWeight(weight: String, image: UIImage?, date: Date? = nil) {
		todayButtonAction(self)
		let weight = Weight(date: date ?? Date(), weight: Double(weight)!)
		
		getImageUrl(weightDate: weight.date) {
			[weak self] image in
			guard let self = self else { return }
			
			self.weightViewModel.weights?.removeAll(where: { $0.date.onlyDate == date?.onlyDate })
			self.weightViewModel.weights?.append(weight)
			self.weightViewModel.addWeight()
			self.updateDateLabels()
			self.updateFiltersArray()
		}
	}
	
	private func updateDataSource() {
		Spinner.shared.stop()
		filteredArray = weightViewModel.getWeekBy(selectedDate.startOfWeek!)
		DispatchQueue.main.async {
			[unowned self] in
			self.tableView.reloadData()
		}
	}
	private func callToViewModelForUIUpdate() {
		if let navView = navigationController?.view {
			Spinner.shared.show(navView)
		}
		self.weightViewModel = WeightViewModel()
		
		self.weightViewModel!.bindWeightViewModelToController = {
			[unowned self] in
			self.updateDataSource()
		}
	}
	private func getImageUrl(weightDate: Date?, completion: @escaping (String?) -> ()) {
		var weightImageUrl: String {
			let userEmail = UserProfile.defaults.email!
			return "\(userEmail.safeEmail)_\((weightDate ?? Date()).dateStringForDB)_weight_image.jpeg"
		}
		
		if let image = self.weightImage {
			GoogleStorageManager.shared.uploadImage(from: .weightImage, data: image.jpegData(compressionQuality: 3)!, fileName: weightImageUrl){
				result in
				
				switch result {
				case .success(let url):
					completion(url)
				case .failure(let error):
					completion(nil)
					print(error)
				}
			}
		} else {
			completion(nil)
		}
	}
	
	//MARK: - Chart
	private func addChartView() {
		let lineChat = ChartView(frame: CGRect(x: 0, y: 0, width: chartView.frame.width, height: chartView.frame.height))
		lineChat.delegate = self
		
		chartView.addSubview(lineChat)
	}
	private func populateChart() {
		if let dataArray = filteredArray {
			let weights = dataArray.map { $0.weight }
			let weightsDates = dataArray.map { $0.date }
			
			values = weights
			timeLinePeriod = weightsDates
			getChartData()
		}
	}
}

//MARK: - Delegates
extension WeightProgressViewController: CropViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
	
	func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
		cropViewController.dismiss(animated: true) {
			self.weightImage = image
			self.weightAlert?.chageCheckMarkState()
		}
	}
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		let tempoImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
		
		picker.dismiss(animated: true)
		presentCropViewController(image: tempoImage, type: .default)
	}
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true)
	}
}

extension WeightProgressViewController: AddWeightAlertViewDelegate {
	
	func cancelButtonAction() {
		weightAlert?.removeFromSuperview()
		weightAlert = nil
	}
	func cameraButtonTapped() {
		presentImagePickerActionSheet(imagePicker: imagePickerController) {_ in}
	}
	func confirmButtonAction(weight: String, date: Date?) {
		if let weightTab = self.tabBarController?.tabBar.items?[3] {
			weightTab.image = UIImage(named:"ScaleIcon")
		}
		addWeight(weight: weight, image: weightImage, date: date)
		weightAlert?.removeFromSuperview()
		weightAlert = nil
	}
}

extension WeightProgressViewController: weightTableViewCellDelegate {
	
	func presentImage(url: URL) {
		let photoViewr = PhotoViewerViewController(with: url)
		present(photoViewr, animated: true)
	}
}

extension WeightProgressViewController: ChartViewDelegate {
	
	func getChartData() {}
}
extension WeightProgressViewController: BounceNavigationBarDelegate {
	
	func backButtonTapped() {}
}
