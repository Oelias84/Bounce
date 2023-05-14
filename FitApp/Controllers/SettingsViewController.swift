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
	
	@objc private func resourcesButtonAction() {
		let url = "https://bouncefit.co.il/%d7%a7%d7%99%d7%a9%d7%95%d7%a8%d7%99%d7%9d-%d7%9c%d7%9e%d7%a7%d7%95%d7%a8%d7%95%d7%aa-%d7%9e%d7%99%d7%93%d7%a2/"
		if let url = URL(string: url) {
			UIApplication.shared.open(url)
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
			stepperCell.infoButton.isHidden = !(indexPath.row == 2)
		case 3:
			//System
			switch indexPath.row {
			case 0:
				stepperCell.settingsCellData = tableViewData[.system]![indexPath.row]
			default:
				stepperCell.settingsCellData = tableViewData[.system]![indexPath.row]
				stepperCell.titleLabel.textColor = .red
				stepperCell.labelStackView.isHidden = true
				stepperCell.titleLabel.font = UIFont(name: "Assistant-SemiBold", size: 14.0)
			}
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
			Spinner.shared.show(self)
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
	func infoButtonDidTapped() {
		presentOkAlert(withTitle: StaticStringsManager.shared.getGenderString?[32] ?? "" ,withMessage: StaticStringsManager.shared.getGenderString?[33] ?? "")
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
	
	fileprivate func setupTopBar() {
		
		topBarView.delegate = self
		topBarView.nameTitle = "הגדרות"
		topBarView.isCameraButton = true
		topBarView.isBackButtonHidden = false
		topBarView.isMotivationHidden = true
		topBarView.isDayWelcomeHidden = true
		topBarView.isProfileButtonHidden = false
	}
	fileprivate func registerCells() {
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(UINib(nibName: K.NibName.SettingsTableViewCell, bundle: nil), forCellReuseIdentifier: K.CellId.settingCell)
	}
	fileprivate func setupTableViewData() {
		
		let setupNumberOfMealsStepper = setupNumberOfMealsStepper()
		let setupNumberOfTrainingsStepper = setupNumberOfTrainingsStepper()
		let setupNumberOfExternalTrainingsStepper = setupNumberOfExternalTrainingsStepper()
		
		tableViewData = [
			.activity: [SettingsCell(title: "רמת פעילות", secondaryTitle: setupActivityTitle())],
			
				.nutrition: [SettingsCell(title: "מספר ארוחות", stepperValue: setupNumberOfMealsStepper.2, stepperMin: setupNumberOfMealsStepper.0, stepperMax: setupNumberOfMealsStepper.1),
							 SettingsCell(title: StaticStringsManager.shared.getGenderString?[21] ?? "", secondaryTitle: setupMostHungryTitle())],
			
				.fitness: [SettingsCell(title: "רמת קושי", secondaryTitle: setupFitnessLevelTitle()),
						   SettingsCell(title: "מספר אימונים שבועי", stepperValue: setupNumberOfTrainingsStepper.2, stepperMin: setupNumberOfTrainingsStepper.0, stepperMax: setupNumberOfTrainingsStepper.1),
						   SettingsCell(title: "מספר אימונים שבועי חיצוני", stepperValue: setupNumberOfExternalTrainingsStepper.2, stepperMin: setupNumberOfExternalTrainingsStepper.0, stepperMax: setupNumberOfExternalTrainingsStepper.1)],
			
				.system: [SettingsCell(title: "התראות", secondaryTitle: ""),
						  SettingsCell(title:  StaticStringsManager.shared.getGenderString?[22] ?? "", secondaryTitle: ""),
						  SettingsCell(title:  StaticStringsManager.shared.getGenderString?[40] ?? "", secondaryTitle: "")]
		]
		tableView.reloadData()
	}
	
	fileprivate func setupActivityTitle() -> String {
		if let steps = userData.steps {
			return "\(steps) צעדים"
		} else if let kilometers = userData.kilometer {
			return String(format: "%.1f", kilometers) + "ק״מ"
		} else {
			return UserProfile.getLifeStyleText()
		}
	}
	fileprivate func setupMostHungryTitle() -> String {
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
	fileprivate func setupFitnessLevelTitle() -> String {
		
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
	
	fileprivate func setupNumberOfMealsStepper() -> (Int,Int,Double) {
		if let meals = userData.mealsPerDay {
			return (3, 5, Double(meals))
		}
		return (0, 0, 0)
	}
	fileprivate func setupNumberOfTrainingsStepper() -> (Int,Int,Double) {
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
	fileprivate func setupNumberOfExternalTrainingsStepper() -> (Int,Int,Double) {
		let min = 0
		let max = 3
		
		if let workouts = userData.externalWorkout {
			return (min, max, Double(workouts))
		}
		return (min, max, 0)
	}
	
	fileprivate func mealStepperAction(_ value: Double) {
		UserProfile.defaults.mealsPerDay = Int(value)
		UserProfile.updateServer()
	}
	fileprivate func workoutStepperAction(_ value: Double) {
		UserProfile.defaults.weaklyWorkouts = Int(value)
		UserProfile.updateServer()
	}
	fileprivate func externalWorkoutAction(_ value: Double) {
		UserProfile.defaults.externalWorkout = Int(value)
		UserProfile.updateServer()
	}
	
	fileprivate func systemTappedAt(_ row: Int) {
		switch row {
		case 0:
			let storyboard = UIStoryboard(name: K.StoryboardName.settings, bundle: nil)
			let vc = storyboard.instantiateViewController(identifier: K.ViewControllerId.SettingsOptionsTableViewController) as! SettingsOptionsTableViewController
				vc.contentType = .notifications
			self.navigationController?.pushViewController(vc, animated: true)
		case 1:
			presentLogoutAlert()
		case 2:
			presentDeleteAccountAlert()
		default:
			break
		}
	}
	fileprivate func personalDetailsTappedAt() {
		let storyboard = UIStoryboard(name: K.StoryboardName.questionnaire, bundle: nil)
		let activityLevelVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.questionnaireForth)
		as! QuestionnaireActivityViewController
		
		activityLevelVC.isFromSettings = true
		navigationController?.pushViewController(activityLevelVC, animated: true)
	}
	fileprivate func nutritionDetailsTappedAt(_ row: Int) {
		switch row {
		case 1:
			let storyboard = UIStoryboard(name: K.StoryboardName.settings, bundle: nil)
			let vc = storyboard.instantiateViewController(identifier: K.ViewControllerId.SettingsOptionsTableViewController) as! SettingsOptionsTableViewController
				vc.contentType = .mostHungry
			self.navigationController?.pushViewController(vc, animated: true)
		default:
			break
		}
	}
	fileprivate func fitnessLevelDetailsTappedAt(_ row: Int) {
		switch row {
		case 0:
			let storyboard = UIStoryboard(name: K.StoryboardName.settings, bundle: nil)
			let vc = storyboard.instantiateViewController(identifier: K.ViewControllerId.SettingsOptionsTableViewController) as! SettingsOptionsTableViewController
				vc.contentType = .fitnessLevel
			self.navigationController?.pushViewController(vc, animated: true)
		default:
			break
		}
	}
	
	fileprivate func sendSupportEmail() {
		let subject = ""
		let messageBody = "<h1>יש לכתוב כאן את ההודעה</h1>"
		let mailVC = MailComposerViewController(recipients: ["Fitappsupport@gmail.com"], subject: subject, messageBody: messageBody, messageBodyIsHtml: true)
		
		present(mailVC, animated: true)
	}
	
	fileprivate func saveImage(_ image: UIImage) {
		guard let userId = Auth.auth().currentUser?.uid else { return }
		topBarView.userProfileButton.isEnabled = false
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
				self.topBarView.userProfileButton.isEnabled = true
				self.presentOkAlert(withMessage: "נכשל לשמור את התמונה אנא נסו שנית")
			}
		}
	}
	fileprivate func saveUserImage(image: UIImage, for url: String, completion: @escaping (Result<URL, Error>) -> Void) {
		let storageManager = GoogleStorageManager.shared
		
		DispatchQueue.global(qos: .userInteractive).async {
			storageManager.uploadImage(data: image.jpegData(compressionQuality: 0.1)!, fileName: url) { _ in
				storageManager.downloadURL(path: url,completion: completion)
			}
		}
	}
	fileprivate func presentDeleteAccountAlert() {
		Spinner.shared.show(self)
		let deleteAlert = UIAlertController(title: StaticStringsManager.shared.getGenderString?[41] ?? "",
											 message: StaticStringsManager.shared.getGenderString?[42] ?? "", preferredStyle: .alert)
		deleteAlert.addTextField { emailTextField in
			emailTextField.placeholder = "הזן אימייל"
			emailTextField.textAlignment = .center
		}
		deleteAlert.addTextField { emailTextField in
			emailTextField.placeholder = "הזן סיסמה"
			emailTextField.textAlignment = .center
		}
		deleteAlert.addAction(UIAlertAction(title: StaticStringsManager.shared.getGenderString?[40] ?? "", style: .default) { _ in
			let email = deleteAlert.textFields?[0].text
			let password = deleteAlert.textFields?[1].text
			
			if let email = email, email.isValidEmail, let password = password {
				GoogleApiManager.shared.deleteUser(email: email, password: password) {
					error in
					Spinner.shared.stop()
					if let error = error {
						self.presentOkAlert(withMessage: error.localizedDescription)
					} else {
						exit(0)
					}
				}
			} else {
				Spinner.shared.stop()
				self.presentOkAlert(withMessage: "נראה כי הפרטים שהוזנו אינם נכונים, אנא נסו שנית")
			}
		})
		deleteAlert.addAction(UIAlertAction(title: "ביטול", style: .cancel))
		present(deleteAlert, animated: true)
	}
}

