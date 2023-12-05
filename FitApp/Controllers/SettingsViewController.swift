//
//  SettingsViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 23/01/2021.
//

import UIKit
import SwiftUI
import FirebaseAuth
import CropViewController



class SettingsViewController: UIViewController {
    
    var viewModel = SettingsViewModel()

    private let imagePickerController = UIImagePickerController()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topBarView: BounceNavigationBarView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.SegueId.moveToSettingsOptions {
            
            let settingsOptionsVC = segue.destination as! SettingsOptionsTableViewController
            settingsOptionsVC.contentType = viewModel.getContentType
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
        
        viewModel.setupTableViewData() {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
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
        viewModel.getNumberOfSections
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel.getTitleFor(section)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.getNumberOfRows(in: section)
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
        stepperCell.settingsCellData = viewModel.getCellViewModelFor(indexPath)
        
        switch indexPath.section {
        case 0, 1:
            //Activity and LifeStyle
            //Nutrition
            stepperCell.settingsCellData = viewModel.getCellViewModelFor(indexPath)
        case 2:
            //Fitness
            stepperCell.settingsCellData = viewModel.getCellViewModelFor(indexPath)
            stepperCell.infoButton.isHidden = !(indexPath.row == 2)
        case 3:
            //System
            switch indexPath.row {
            case 0:
                stepperCell.settingsCellData = viewModel.getCellViewModelFor(indexPath)
            default:
                stepperCell.titleLabel.textColor = .red
                stepperCell.labelStackView.isHidden = true
                stepperCell.settingsCellData = viewModel.getCellViewModelFor(indexPath)
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
            self.viewModel.inCameraMode = false
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

extension SettingsViewController: SettingsCheckboxTableViewCellDelegate {
    
    func informationButtonAction() {
        presentOkAlert(withTitle: StaticStringsManager.shared.getGenderString?[32] ?? "" ,withMessage: "Enter a massage here")
    }
    func checkboxButtonAction(_ sender: UIButton) {
        if UserProfile.defaults.naturalMenu == nil {
            UserProfile.defaults.naturalMenu = true
        } else {
            UserProfile.defaults.naturalMenu!.toggle()
        }
        UserProfile.updateServer()
    }
}
extension SettingsViewController: SettingsStepperViewCellDelegate {
    
    func valueChanged(_ newValue: Double, cell: UITableViewCell) {
        
        if let cellIndex = tableView.indexPath(for: cell) {
            
            switch cellIndex.section {
            case 0:
                break
            case 1: //Nutrition
                if IOSKeysManager.shared.isFeatureOpen(.neutralMenu) {
                    switch cellIndex.row {
                    case 1:
                        mealStepperAction(newValue)
                    default:
                        break
                    }
                } else {
                    switch cellIndex.row {
                    case 0:
                        mealStepperAction(newValue)
                    default:
                        break
                    }
                }
            case 2: //Fitness Level
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
                self.viewModel.inCameraMode = true
            }
        }
    }
    func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - Functions
extension SettingsViewController {
    //setup
    private func setupTopBar() {
        
        topBarView.delegate = self
        topBarView.nameTitle = "הגדרות"
        topBarView.isCameraButton = true
        topBarView.isBackButtonHidden = false
        topBarView.isMotivationHidden = true
        topBarView.isDayWelcomeHidden = true
        topBarView.isProfileButtonHidden = false
    }
    private func registerCells() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: K.NibName.settingsTableViewCell, bundle: nil), forCellReuseIdentifier: K.CellId.settingCell)
        tableView.register(UINib(nibName: K.NibName.settingsCheckboxTableViewCell, bundle: nil), forCellReuseIdentifier: K.CellId.checkboxCell)
    }
    
    private func mealStepperAction(_ value: Double) {
        UserProfile.defaults.mealsPerDay = Int(value)
        UserProfile.updateServer()
    }
    private func workoutStepperAction(_ value: Double) {
        Spinner.shared.show()
        // Update local data
        UserProfile.defaults.weaklyWorkouts = Int(value)
        // Removing saved data
        WorkoutManager.shared.removePreferredWorkoutData {
            // Reloading manager data
            WorkoutManager.shared.loadData()
            // Update server
            UserProfile.updateServer()
            // Remove Spinner
            Spinner.shared.stop()
        }
    }
    private func externalWorkoutAction(_ value: Double) {
        UserProfile.defaults.externalWorkout = Int(value)
        UserProfile.updateServer()
    }
    
    private func systemTappedAt(_ row: Int) {
        switch row {
        case 0:
            LocalNotificationManager.shared.checkUserPermissions { hasPermission in
                if hasPermission {
                    self.moveToOptoinsVC(for: .notifications)
                }
            }
        case 1:
            presentLogoutAlert()
        case 2:
            presentDeleteAccountAlert()
        default:
            break
        }
    }
    private func personalDetailsTappedAt() {
        let contentView = ActivityLevelAlertView() {
            self.viewModel.setupTableViewData() {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        contentView.showPopup()
    }
    private func nutritionDetailsTappedAt(_ row: Int) {
        if IOSKeysManager.shared.isFeatureOpen(.neutralMenu) {
            switch row {
            case 0:
                moveToOptoinsVC(for: .nutritios)
            case 2:
                moveToOptoinsVC(for: .mostHungry)
            default:
                break
            }
        } else {
            switch row {
            case 1:
                moveToOptoinsVC(for: .mostHungry)
            default:
                break
            }
        }
    }
    private func fitnessLevelDetailsTappedAt(_ row: Int) {
        switch row {
        case 0:
            moveToOptoinsVC(for: .fitnessLevel)
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
    private func saveUserImage(image: UIImage, for url: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let storageManager = GoogleStorageManager.shared
        
        DispatchQueue.global(qos: .userInteractive).async {
            storageManager.uploadImage(data: image.jpegData(compressionQuality: 0.1)!, fileName: url) { _ in
                storageManager.downloadURL(path: url,completion: completion)
            }
        }
    }
    private func presentDeleteAccountAlert() {
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
    
    private func moveToOptoinsVC(for contentType: SettingsContentType) {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: K.StoryboardName.settings, bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: K.ViewControllerId.SettingsOptionsTableViewController) as! SettingsOptionsTableViewController
            vc.contentType = contentType
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
