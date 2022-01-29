//
//  SettingsViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 23/01/2021.
//

import UIKit
import FirebaseAuth
import CropViewController

enum SettingsMenu {
	
	case activity
	case nutrition
	case fitness
	case system
}

class SettingsViewController: UIViewController {
	
	private var optionContentType: SettingsContentType!
	
	private let userGender = UserProfile.defaults.getGender
	private var tableViewData: [SettingsMenu: [SettingsCell]]!
	private var userData: UserProfile! = UserProfile.defaults
	
	private var inCameraMode: Bool = false
	private let imagePickerController = UIImagePickerController()
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var topBarView: BounceNavigationBarView!
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == K.SegueId.moveToSettingsOptions {
			let settingsOptionsVC = segue.destination as! SettingsOptionsTableViewController
			settingsOptionsVC.contentType = optionContentType
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupTopBar()
		registerCells()
		imagePickerController.delegate = self

	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		userData = UserProfile.defaults
		setupTableViewData()
		
		if !inCameraMode {
//			navigationController?.popViewController(animated: false)
		}
	}
}

//MARK: - Delegates
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		4
	}
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		
		switch section {
		case 0:
			return "פרטים אישיים"
		case 1:
			return "תזונה"
		case 2:
			return "כושר"
		case 3:
			return "מערכת"
		default:
			return nil
		}
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		switch section {
		case 0:
			return tableViewData[.activity]!.count
		case 1:
			return tableViewData[.nutrition]!.count
		case 2:
			return tableViewData[.fitness]!.count
		case 3:
			return tableViewData[.system]!.count
		default:
			return 0
		}
	}
	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		guard let header = view as? UITableViewHeaderFooterView else { return }
		
		header.textLabel?.frame = header.bounds
		header.textLabel?.textColor = UIColor.projectTail
		header.backgroundView?.backgroundColor = UIColor.clear
		header.textLabel?.font = UIFont(name: "Assistant-Bold", size: 18)
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		switch indexPath.section {
			
		case 0:
			personalDetailsTappedAt()
		case 1:
			nutritionDetailsTappedAt(indexPath.row)
		case 2:
			fitnessLevelDetailsTappedAt(indexPath.row)
		case 3:
			systemTappedAt(indexPath.row)
		default:
			break
		}
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let stepperCell = tableView.dequeueReusableCell(withIdentifier: K.CellId.settingCell, for: indexPath) as! SettingsTableViewCell
		
		stepperCell.delegate = self
		
		switch indexPath.section {
		case 0:
			//Personal details
			//activity level
			stepperCell.settingsCellData = tableViewData[.activity]![indexPath.row]
			stepperCell.tag = 0
		case 1:
			//Nutrition
			switch indexPath.row {
			case 0:
				//number of meals
				stepperCell.settingsCellData = tableViewData[.nutrition]![indexPath.row]
				stepperCell.tag = 1
			case 1:
				//most hungry
				stepperCell.settingsCellData = tableViewData[.nutrition]![indexPath.row]
				stepperCell.tag = 2
			default:
				return UITableViewCell()
			}
		case 2:
			//Fitness Level
			stepperCell.settingsCellData = tableViewData[.fitness]![indexPath.row]
		case 3:
			stepperCell.settingsCellData = tableViewData[.system]![indexPath.row]
		default:
			return UITableViewCell()
		}
		return stepperCell
	}
}
//Camera delegate
extension SettingsViewController: CropViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
	
	func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
		cropViewController.dismiss(animated: true) {
			self.inCameraMode = false
			Spinner.shared.show(self.view)
			self.saveImage(image)
		}
	}
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		let tempoImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
		
		picker.dismiss(animated: true)
		presentCropViewController(image: tempoImage, type: .circular)
	}
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true)
	}
}
extension SettingsViewController: SettingsStepperViewCellDelegate {
	
	func valueChanged(_ newValue: Double, cell: UITableViewCell) {
		
		if let cellIndex = tableView.indexPath(for: cell) {
			
			switch cellIndex.section {
			case 0:
				break
			case 1:
				//Nutrition
				switch cellIndex.row {
				case 0:
					mealStepperAction(newValue)
				default:
					break
				}
			case 2:
				//Fitness Level
				switch cellIndex.row {
				case 1:
					workoutStepperAction(newValue)
				case 2:
					externalWorkoutAction(newValue)
				default:
					break
				}
			case 3:
				break
			default:
				break
			}
		}
	}
}
extension SettingsViewController: BounceNavigationBarDelegate {
	
	func cameraButtonTapped() {
		presentImagePickerActionSheet(imagePicker: imagePickerController) {
			didSelect in
			if didSelect {
				self.inCameraMode = true
			}
		}
	}
	func backButtonTapped() {
		navigationController?.popViewController(animated: true)
	}
}

//MARK: - Functions
extension SettingsViewController {
	
	private func setupTopBar() {
		
		topBarView.delegate = self
		topBarView.nameTitle = "הגדרות"
		topBarView.isCameraButton = true
		topBarView.isBackButtonHidden = false
		topBarView.isMotivationHidden = true
		topBarView.isDayWelcomeHidden = true
	}
	private func registerCells() {
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(UINib(nibName: K.NibName.SettingsTableViewCell, bundle: nil), forCellReuseIdentifier: K.CellId.settingCell)
	}
	private func setupTableViewData() {
		
		let setupNumberOfMealsStepper = setupNumberOfMealsStepper()
		let setupNumberOfTrainingsStepper = setupNumberOfTrainingsStepper()
		let setupNumberOfExternalTrainingsStepper = setupNumberOfExternalTrainingsStepper()
		
		tableViewData =
		[
			.activity: [SettingsCell(title: "רמת פעילות", secondaryTitle: setupActivityTitle())],
			
				.nutrition: [SettingsCell(title: "מספר ארוחות", stepperValue: setupNumberOfMealsStepper.2, stepperMin: setupNumberOfMealsStepper.0, stepperMax: setupNumberOfMealsStepper.1),
							 SettingsCell(title: StaticStringsManager.shared.getGenderString?[21] ?? "", secondaryTitle: setupMostHungryTitle())],
			
				.fitness: [SettingsCell(title: "רמת קושי", secondaryTitle: setupFitnessLevelTitle()),
						   SettingsCell(title: "מספר אימונים שבועי", stepperValue: setupNumberOfTrainingsStepper.2, stepperMin: setupNumberOfTrainingsStepper.0, stepperMax: setupNumberOfTrainingsStepper.1),
						   SettingsCell(title: "מספר אימונים שבועי חיצוני", stepperValue: setupNumberOfExternalTrainingsStepper.2, stepperMin: setupNumberOfExternalTrainingsStepper.0, stepperMax: setupNumberOfExternalTrainingsStepper.1)],
			
				.system: [SettingsCell(title: "התראות", secondaryTitle: ""),
						  SettingsCell(title:  StaticStringsManager.shared.getGenderString?[22] ?? "", secondaryTitle: "")]
		]
		tableView.reloadData()
	}
	
	private func setupActivityTitle() -> String {
		if let steps = userData.steps {
			return "\(steps) צעדים"
		} else if let kilometers = userData.kilometer {
			return "\(kilometers) ק״מ"
		} else {
			return UserProfile.getLifeStyleText()
		}
	}
	private func setupMostHungryTitle() -> String {
		var hungerTitle: String {
			switch userData.mostHungry  {
			case 1:
				return "בוקר"
			case 2:
				return "צהריים"
			case 3:
				return "ערב"
			default:
				return "לא ידוע"
			}
		}
		return hungerTitle
	}
	private func setupFitnessLevelTitle() -> String {
		
		var fitnessTitle: String {
			switch userData.fitnessLevel  {
			case 1:
				return StaticStringsManager.shared.getGenderString?[14] ?? ""
			case 2:
				return "ביניים"
			case 3:
				return StaticStringsManager.shared.getGenderString?[17] ?? "" 
			default:
				return "שגיאה"
			}
		}
		return fitnessTitle
	}
	
	private func setupNumberOfMealsStepper() -> (Int,Int,Double) {
		if let meals = userData.mealsPerDay {
			return (3, 5, Double(meals))
		}
		return (0, 0, 0)
	}
	private func setupNumberOfTrainingsStepper() -> (Int,Int,Double) {
		var min = 0
		var max = 0
		
		switch userData.fitnessLevel {
		case 1:
			min = 2
			max = 2
		case 2:
			min = 2
			max = 3
		case 3:
			min = 3
			max = 4
		default:
			break
		}
		if let workouts = userData.weaklyWorkouts {
			return (min, max, Double(workouts))
		}
		return (min, max, 0)
	}
	private func setupNumberOfExternalTrainingsStepper() -> (Int,Int,Double) {
		let min = 0
		let max = 3
		
		if let workouts = userData.externalWorkout {
			return (min, max, Double(workouts))
		}
		return (min, max, 0)
	}
	
	private func mealStepperAction(_ value: Double) {
		UserProfile.defaults.mealsPerDay = Int(value)
		UserProfile.updateServer()
	}
	private func workoutStepperAction(_ value: Double) {
		UserProfile.defaults.weaklyWorkouts = Int(value)
		UserProfile.updateServer()
	}
	private func externalWorkoutAction(_ value: Double) {
		UserProfile.defaults.externalWorkout = Int(value)
		UserProfile.updateServer()
	}
	
	private func systemTappedAt(_ row: Int) {
		switch row {
		case 0:
			optionContentType = .notifications
			performSegue(withIdentifier: K.SegueId.moveToSettingsOptions, sender: self)
		case 1:
			presentLogoutAlert()
		default:
			break
		}
	}
	private func personalDetailsTappedAt() {
		let storyboard = UIStoryboard(name: K.StoryboardName.questionnaire, bundle: nil)
		let activityLevelVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.questionnaireForth)
		as! QuestionnaireActivityViewController
		
		activityLevelVC.isFromSettings = true
		navigationController?.pushViewController(activityLevelVC, animated: true)
	}
	private func nutritionDetailsTappedAt(_ row: Int) {
		switch row {
		case 1:
			optionContentType = .mostHungry
			performSegue(withIdentifier: K.SegueId.moveToSettingsOptions, sender: self)
		default:
			break
		}
	}
	private func fitnessLevelDetailsTappedAt(_ row: Int) {
		switch row {
		case 0:
			optionContentType = .fitnessLevel
			performSegue(withIdentifier: K.SegueId.moveToSettingsOptions, sender: self)
		default:
			break
		}
	}
	
	private func sendSupportEmail() {
		let subject = ""
		let messageBody = "<h1>יש לכתוב כאן את ההודעה</h1>"
		let mailVC = MailComposerViewController(recipients: ["Fitappsupport@gmail.com"], subject: subject, messageBody: messageBody, messageBodyIsHtml: true)
		
		present(mailVC, animated: true)
	}
	
	private func saveImage(_ image: UIImage) {
		guard let userId = Auth.auth().currentUser?.uid else { return }
		let profileImagePath = "\(userId)/profile_image.jpeg"
		
		self.saveUserImage(image: image, for: profileImagePath) {
			[weak self] result in
			guard let self = self else { return }
			
			switch result {
			case .success(let imageUrl):
				// Saves image url to user defaults
				
				UserProfile.defaults.profileImageImageUrl = imageUrl.absoluteString
				self.topBarView.changeImage = true
				self.topBarView.setImage()
				Spinner.shared.stop()
			case .failure(let error):
				print(error.localizedDescription)
				Spinner.shared.stop()
				self.presentOkAlert(withMessage: "נכשל לשמור את התמונה אנא נסו שנית")
			}
		}
	}
	private func saveUserImage(image: UIImage, for url: String, completion: @escaping (Result<URL, Error>) -> Void) {
		let storageManager = GoogleStorageManager.shared
		
		DispatchQueue.global(qos: .background).async {
			storageManager.uploadImage(data: image.jpegData(compressionQuality: 0.2)!, fileName: url) { _ in
				storageManager.downloadURL(path: url,completion: completion)
			}
		}
	}
}

