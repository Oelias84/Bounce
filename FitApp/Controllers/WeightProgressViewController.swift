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
import FirebaseAuth
import DateToolsSwift
import CropViewController
import BetterSegmentedControl

enum TimePeriod {
	
	case week
	case month
	case year
}

class WeightProgressViewController: UIViewController {
	
	public var isFromAdmin: Bool = false
	public var weightViewModel: WeightViewModel?
	private var filteredArray: [Weight]? {
		didSet {
			DispatchQueue.main.async {
				self.populateChart()
				self.addChartView()
				self.tableView.reloadData()
				if let wights = self.filteredArray, !wights.isEmpty {
					self.tableView.scrollToRow(at: IndexPath(row: wights.count - 1, column: 0), at: .bottom, animated: true)
				}
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
	internal var timePeriod: TimePeriod = .week {
		didSet {
			if !isFromAdmin {
				addWeightButton.isHidden = timePeriod != .week
			}
		}
	}
	
	@IBOutlet weak var chartView: UIView!
	@IBOutlet weak var chartViewContainer: UIView! {
		didSet {
			chartViewContainer.cellView()
		}
	}
	
	@IBOutlet weak var todayButton: UIButton!
	@IBOutlet weak var dateRightButton: UIButton!
	@IBOutlet weak var dateTextLabel: UILabel!
	@IBOutlet weak var dateLeftButton: UIButton!
	@IBOutlet weak var addWeightButton: UIButton!
	
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
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		topBarView.setImage()
	}
	
	@IBAction func todayButtonAction(_ sender: Any) {
		guard let weightViewModel = weightViewModel else { return }
		
		selectedDate = Date()
		filteredArray = weightViewModel.getWeekBy(selectedDate.startOfWeek!)
		segmentedControl.setIndex(0)
		timePeriod = .week
		updateDateLabels()
		updateFiltersArray()
	}
	@IBAction func addWeightButtonAction(_ sender: Any) {
		if isFromAdmin {
			dismiss(animated: true)
			return
		}
		guard let weightViewModel = weightViewModel,
				let lastWeightDate = weightViewModel.getLastWeightDate() else { return }
		
		let currentDate = Date().onlyDate
		addWeightButton.isEnabled = false
		
		if lastWeightDate == currentDate {
			presentOkAlert(withMessage: "כבר נשקלת היום")
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

//MARK: - Delegates
extension WeightProgressViewController: CropViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
	
	func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
		cropViewController.dismiss(animated: true) {
			if let imageData = image.jpegData(compressionQuality: 0.2) {
				self.weightImage = UIImage(data: imageData)
				self.weightAlert?.chageCheckMarkState()
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
extension WeightProgressViewController: AddWeightAlertViewDelegate {
	
	func cancelButtonAction() {
		weightAlert?.removeFromSuperview()
		weightAlert = nil
		Spinner.shared.stop()
		addWeightButton.isEnabled = true
	}
	func cameraButtonTapped() {
		presentImagePickerActionSheet(imagePicker: imagePickerController) {_ in}
	}
	func confirmButtonAction(weight: String, date: Date?) {
		weightAlert?.removeFromSuperview()
		guard let window = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window else {
			return
		}
		Spinner.shared.show(window)
		guard let weightInt = Double(weight) else { return }
		
		if weightInt>150 || weightInt<30  {
			weightAlert = nil
			Spinner.shared.stop()
			self.presentOkAlert(withTitle: "אופס", withMessage: StaticStringsManager.shared.getGenderString?[34] ?? "")
		} else {
			if let weightTab = self.tabBarController?.tabBar.items?[3] {
				weightTab.image = UIImage(named:"Weight")
			}
			self.weightAlert?.removeFromSuperview()
			self.weightAlert = nil
			self.addWeight(weight: weight, image: self.weightImage, date: date)
		}
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
				if isFromAdmin { return }
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
		topBarView.isProfileButtonHidden = false
		
		if isFromAdmin {
			addWeightButton.setImage(UIImage(systemName: "xmark"), for: .normal)
			addWeightButton.setTitle("", for: .normal)
		}
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
		guard let weightViewModel = weightViewModel else { return }
		
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
			if let navView = self.navigationController?.view {
				Spinner.shared.show(navView)
			}
		}
	}
	private func addWeight(weight: String, image: UIImage?, date: Date? = nil) {
		todayButtonAction(self)
		let weight = Weight(dateString: (date ?? Date()).dateStringForDB, weight: Double(weight)!)
		
		uploadWeightImage(weightDate: weight.date) {
			guard let weightViewModel = self.weightViewModel else { return }
			
			Spinner.shared.stop()
			weightViewModel.weights?.removeAll(where: { $0.date.onlyDate == date?.onlyDate })
			weightViewModel.weights?.append(weight)
			weightViewModel.addWeight()
			self.updateDateLabels()
			self.updateFiltersArray()
			self.addWeightButton.isEnabled = true
		}
	}
	
	private func updateDataSource() {
		Spinner.shared.stop()
		guard let weightViewModel = weightViewModel else { return }
		
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
		if weightViewModel == nil {
			self.weightViewModel = WeightViewModel()
		}
		
		self.weightViewModel!.bindWeightViewModelToController = {
			[weak self] in
			self?.updateDataSource()
		}
	}
	private func uploadWeightImage(weightDate: Date?, completion: @escaping () -> ()) {
		
		guard let userID = Auth.auth().currentUser?.uid else { return }
		let imagePath = "\(userID)/weight_images/\((weightDate ?? Date()).dateStringForDB).jpeg"
		
		if let image = self.weightImage {
			DispatchQueue.global(qos: .background).async {
				GoogleStorageManager.shared.uploadImage(data: image.jpegData(compressionQuality: 1)!, fileName: imagePath) {
					result in
					
					switch result {
					case .success(_):
						completion()
					case .failure(let error):
						completion()
						self.presentOkAlert(withTitle: "אופס", withMessage: "שמירת התמונה נכלשה", buttonText: "אישור")
						print("Error: ", error.localizedDescription)
					}
				}
			}
		} else {
			completion()
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
