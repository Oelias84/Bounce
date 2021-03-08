//
//  WeightProgressViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 22/12/2020.
//

import UIKit
import Foundation
import DateToolsSwift
import CropViewController
import SDWebImage

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
	
	private var timePeriod: TimePeriod = .week
	private var selectedDate: Date! {
		didSet {
			updateDateLabels()
		}
	}
	
	private var weightImage: UIImage?
	private var weightAlert: AddWeightAlertView?
	private let imagePickerController = UIImagePickerController()
	
	var bindToController: (() -> ()) = {}
	
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
		dateRightButton.isHidden = true
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
		if let weights = weightViewModel.weights, weights.contains(where: { $0.date.day == Date().day }) {
			presentOkAlert(withMessage: "כבר נשקלת היום") {}
			return
		} else {
			let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
			
			imagePickerController.delegate = self
			weightAlert = AddWeightAlertView()
			weightAlert?.delegate = self
			weightAlert?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width,
										height:  UIScreen.main.bounds.size.height)
			if let alert = weightAlert {
				window?.addSubview(alert)
			}
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
	
	private func updateDateLabels() {
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
	private func updateFiltersArray() {
		switch timePeriod {
		case .week:
			filteredArray = weightViewModel.getWeekBy(selectedDate)
		case .month:
			filteredArray = weightViewModel.getMonthBy(selectedDate)
		case .year:
			filteredArray = weightViewModel.getYearBy(selectedDate)
		}
	}
	private func addWeight(weight: String, image: UIImage?) {
		todayButtonAction(self)
		
		getImageUrl {
			[weak self] image in
			guard let self = self else { return }
			
			let weight = Weight(date: Date(), weight: Double(weight)!)
			self.weightViewModel.weights?.append(weight)
			self.weightViewModel.addWeight()
			self.updateDateLabels()
			self.updateFiltersArray()
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
		if let navView = navigationController?.view {
			Spinner.shared.show(navView)
		}
		self.weightViewModel = WeightViewModel()
		
		self.weightViewModel!.bindWeightViewModelToController = {
			self.updateDataSource()
		}
	}
	
	private func getImageUrl(completion: @escaping (String?) -> ()) {
		var weightImageUrl: String {
			let userEmail = UserProfile.defaults.email!
			return "\(userEmail.safeEmail)_\(Date().dateStringForDB)_weight_image.jpeg"
		}
		
		if let image = self.weightImage {
			GoogleStorageManager.shared.uploadImage(from: .weightImage, data: image.jpegData(compressionQuality: 8)!, fileName: weightImageUrl){
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
}

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
	
	func confirmButtonAction(weight: String) {
		addWeight(weight: weight, image: weightImage)
		weightAlert?.removeFromSuperview()
		weightAlert = nil
	}
	func cancelButtonAction() {
		weightAlert?.removeFromSuperview()
		weightAlert = nil
	}
	func cameraButtonTapped() {
		presentImagePickerActionSheet(imagePicker: imagePickerController) {_ in}
	}
}

extension WeightProgressViewController: weightTableViewCellDelegate {
	
	func presentImage(url: URL) {
		let photoViewr = PhotoViewerViewController(with: url)
		present(photoViewr, animated: true)
	}
}
