//
//  UsersListViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 18/05/2022.
//

import UIKit
import AVFoundation
import AVKit
import CropViewController

class UsersListViewController: UIViewController {
    
    private var viewModel: UsersListViewModel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var upButtonView: UIButton!
    @IBOutlet weak var filerButtonView: UIButton!
    @IBOutlet weak var filterExpiredButtonView: UIButton!
    @IBOutlet weak var broadcastButtonView: UIButton!
    
    private var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    private let imagePickerController = UIImagePickerController()
    private let searchController = UISearchController(searchResultsController: nil)
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moveToUserDetails" {
            guard let userDetailsVC = segue.destination as? UserDetailsViewController,
                  let sender = sender as? [String: UserDetailsViewModel],
                  let userData = sender["userDetailsViewModel"] else { return }
            
            userDetailsVC.modalPresentationStyle = .fullScreen
            userDetailsVC.navigationItem.largeTitleDisplayMode = .always
            
            userDetailsVC.title = userData.userName ?? "אין שם"
            userDetailsVC.viewModel = userData
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = UsersListViewModel(parentVC: self)
        Spinner.shared.show(view)
        setupView()
        bindViewModel()
        setupSearchBar()
    }
    
    @IBAction func upButtonAction(_ sender: Any) {
        let indexPath = IndexPath(row: 0, column: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
    }
    @IBAction func closeButtonAction(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func broadcastButtonAction(_ sender: Any) {
        if viewModel.isBroadcastSelection == nil {
            presentBroadcastSheet()
        } else {
            //hide searchbar
            self.navigationItem.searchController = nil
            //present text alert
            presentTextFieldAlert(withTitle: "מה תרצו לכתוב?", withMessage: "", options: "שלח", "ביטול")
        }
    }
    @IBAction func filterExpiredButtonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        viewModel.showOnlyActive.toggle()
        viewModel.filterUsers(with: .allUsers)
        
        DispatchQueue.main.async {
            // Update TableView
            self.tableView.reloadData()
            self.filerButtonView.menu = self.viewModel.filterMenu
        }
    }
}

//MARK: - Delegates
extension UsersListViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty, text.count > 1 else {
            self.viewModel.filterUsers(with: .allUsers)
            self.tableView.reloadData()
            return
        }
        viewModel.filterUsers(with: .searchBy(name: text))
    }
}

extension UsersListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.chatsCount ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        upButtonAnimat(indexPath: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.adminUserMenuCell) as! AdminUserMenuTableViewCell
        let cellViewModel = viewModel.userViewModel(row: indexPath.row)
        
        cell.delegate = self
        cell.configure(with: cellViewModel)
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userData = viewModel.userViewModel(row: indexPath.row).userDetailsViewModel
        moveToUserDetails(userData: userData)
    }
}

extension UsersListViewController: PopupAlertViewDelegate {
    
    func okButtonTapped(alertNumber: Int, selectedOption: String?, textFieldValue: String?) {
        if let text = textFieldValue {
            viewModel.sendBroadcastMessage(type: .text(text)) {
                [weak self] error in
                guard let self = self else { return }
                
                if let error = error {
                    self.presentOkAlert(withTitle: "אופס",withMessage: "שליחת ההודעה נכשלה")
                    print("Error:", error)
                    return
                }
                self.ableInteraction()
            }
        }
        dismissBroadcast()
    }
    func cancelButtonTapped(alertNumber: Int) {
        dismissBroadcast()
    }
    func thirdButtonTapped(alertNumber: Int) {
        UserProfile.defaults.showQaAlert = false
    }
}
extension UsersListViewController: PopupAlertViewCameraDelegate {
    
    func cameraButtonTapped(alertNumber: Int) {
        self.presentInputActionSheet()
    }
}
extension UsersListViewController: CropViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true) {
            
            //Image Picker
            if let image = info[.originalImage] as? UIImage {
                self.presentCropViewController(image: image, type: .default)
                
                //Video Picker
            } else if let videoUrl = info[.mediaURL] as? URL  {
                guard let placeholder = MessagesManager.generateThumbnailFrom(videoURL: videoUrl) else { return }
                let media = Media(url: videoUrl, image: nil, placeholderImage: placeholder, size: .zero)
                
                self.disableInteraction()
                self.viewModel.sendBroadcastMessage(type: .video(media)) {
                    [weak self] error in
                    guard let self = self else { return }
                    if let error = error {
                        self.presentOkAlert(withTitle: "אופס",withMessage: "שליחת תמונה נכשלה")
                        print("Error:", error)
                        return
                    }
                    self.ableInteraction()
                    self.dismissBroadcast()
                }
            }
        }
    }
    
    //If image crop used
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        cropViewController.dismiss(animated: true) {
            let media = Media(url: nil, image: image, placeholderImage: image, size: .zero)
            
            self.disableInteraction()
            self.viewModel.sendBroadcastMessage(type: .photo(media)) {
                [weak self] error in
                guard let self = self else { return }
                
                if let error = error {
                    self.presentOkAlert(withTitle: "אופס",withMessage: "שליחת וידאו נכשלה")
                    print("Error:", error)
                    return
                }
                self.ableInteraction()
                self.dismissBroadcast()
            }
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
extension UsersListViewController: AdminUserMenuTableViewCellDelegate {
    
    func broadcastButtonTapped(userViewModel: UserViewModel) {
        
        viewModel.addOrRemoveSelectedUser(userViewModel)
    }
}

//MARK: - Functions
extension UsersListViewController {
    
    private func dismissBroadcast() {
        viewModel.removeBrodcastSelection()
        changeBrodcastButtonState()
        viewModel.isBroadcastSelection = nil
        
        DispatchQueue.main.async {
            self.setupSearchBar()
            self.tableView.reloadData()
        }
    }
    private func setupView() {
        imagePickerController.delegate = self
        filterExpiredButtonView.setTitleColor(.blue, for: .normal)
        filterExpiredButtonView.isSelected = viewModel.showOnlyActive
        
        if #available(iOS 14.0, *) {
            filerButtonView.menu = viewModel.filterMenu
            filerButtonView.showsMenuAsPrimaryAction = true
        } else {
            //Sheet
        }
        tableView.register(UINib(nibName: K.NibName.adminUserMenuTableViewCell, bundle: nil), forCellReuseIdentifier: K.CellId.adminUserMenuCell)
    }
    private func bindViewModel() {
        viewModel.filteredUsers.bind {
            users in
            if users != nil {
                DispatchQueue.main.async {
                    self.title = "\(self.viewModel.chatsCount ?? 0) משתמשים"
                    self.tableView.reloadData()
                    Spinner.shared.stop()
                }
            } else {
                Spinner.shared.stop()
            }
        }
    }
    private func setupSearchBar() {
        searchController.searchBar.placeholder = "חיפוש משתמשים"
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.definesPresentationContext = false
        
        navigationItem.searchController = searchController
    }
    private func upButtonAnimat(indexPath: IndexPath) {
        if indexPath.row > 20 {
            upButtonView.isHidden = false
            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut) {
                self.upButtonView.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut) {
                self.upButtonView.alpha = 0
            } completion: { didfinish in
                self.upButtonView.isHidden = didfinish
            }
        }
    }
    private func changeBrodcastButtonState() {
        DispatchQueue.main.async {
            if self.viewModel.isBroadcastSelection != nil {
                self.broadcastButtonView.setImage(nil, for: .normal)
                self.broadcastButtonView.setTitle("להודעה", for: .normal)
                self.broadcastButtonView.setTitleColor(.blue, for: .normal)
            } else {
                self.broadcastButtonView.setImage(UIImage(systemName: "bubble.left.and.bubble.right.fill"), for: .normal)
                self.broadcastButtonView.setTitle(nil, for: .normal)
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func moveToUserDetails(userData: UserDetailsViewModel) {
        let sender: [String: UserDetailsViewModel?] = ["userDetailsViewModel": userData]
        performSegue(withIdentifier: K.SegueId.moveToUserDetails, sender: sender)
    }
    
    private func presentBroadcastSheet() {
        let sheetAlert = UIAlertController(title: "Broadcast", message: nil, preferredStyle: .actionSheet)
        
        let allFillterdOption = UIAlertAction(title: "רשימה ממוינת", style: .default) { _ in
            self.viewModel.isBroadcastSelection = .allFilterd
            self.changeBrodcastButtonState()
        }
        let selectionOption = UIAlertAction(title: "בחירת משתמשים", style: .default) { _ in
            self.viewModel.isBroadcastSelection = .selective
            self.changeBrodcastButtonState()
        }
        
        let cancellButton = UIAlertAction(title: "ביטול", style: .cancel)
        
        sheetAlert.addAction(allFillterdOption)
        sheetAlert.addAction(selectionOption)
        sheetAlert.addAction(cancellButton)
        
        present(sheetAlert, animated: true)
    }
    private func presentTextFieldAlert(withTitle title: String? = nil, withMessage message: String, options: (String)...) {
        let storyboard = UIStoryboard(name: K.NibName.popupAlertView, bundle: nil)
        let customAlert = storyboard.instantiateViewController(identifier: K.NibName.popupAlertView) as! PopupAlertView
        
        customAlert.providesPresentationContextTransitionStyle = true
        customAlert.definesPresentationContext = true
        customAlert.modalPresentationStyle = .overCurrentContext
        customAlert.modalTransitionStyle = .crossDissolve
        
        customAlert.delegate = self
        customAlert.cameraDelegate = self
        
        customAlert.titleText = title
        customAlert.popupType = .textBox
        customAlert.messageText = message
        customAlert.okButtonText = options[0]
        customAlert.cancelButtonText = options[1]
        customAlert.cameraButtonIsHidden = false
        
        if options.count == 3 {
            customAlert.doNotShowText = options.last
        }
        
        present(customAlert, animated: true, completion: nil)
    }
}
extension UsersListViewController {
    @objc private func presentInputActionSheet() {
        let actionSheet = UIAlertController(title: "ייבוא מדיה",
                                            message: "בחר סוג מדיה",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "תמונה", style: .default, handler: { [weak self] _ in
            self?.presentImagePickerActionSheet(imagePicker: self!.imagePickerController) {_ in}
        }))
        actionSheet.addAction(UIAlertAction(title: "וידאו", style: .default, handler: { [weak self]  _ in
            self?.presentVideoInputActionSheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "ביטול", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }
    private func presentVideoInputActionSheet() {
        let actionSheet = UIAlertController(title: "יבוא וידאו",
                                            message: "מהיכן תרצה לייבא?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "מצלמה", style: .default, handler: { [weak self] _ in
            
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true
            self?.present(picker, animated: true)
            
        }))
        actionSheet.addAction(UIAlertAction(title: "גלריה", style: .default, handler: { [weak self] _ in
            
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            self?.present(picker, animated: true)
            
        }))
        actionSheet.addAction(UIAlertAction(title: "ביטול", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    private func presentImageFor(_ urlString: String) {
        DispatchQueue.global(qos: .userInteractive).async {
            self.viewModel.getMediaUrlFor(urlString) {
                [weak self] url in
                guard let self = self else {
                    self?.disableInteraction()
                    return
                }
                self.ableInteraction()
                
                DispatchQueue.main.async {
                    if let url = url {
                        let photoViewer = PhotoViewerViewController(with: url)
                        self.parent?.present(photoViewer, animated: true)
                    } else {
                        self.presentOkAlert(withTitle: "אופס!", withMessage: "נראה שאין אפשרות להציג תמונה זאת", buttonText: "סגירה")
                    }
                }
            }
        }
    }
    private func presentVideoFor(_ urlString: String) {
        DispatchQueue.global(qos: .userInteractive).async {
            self.viewModel.getMediaUrlFor(urlString) {
                [weak self] url in
                guard let self = self else {
                    self?.disableInteraction()
                    return
                }
                
                self.ableInteraction()
                DispatchQueue.main.async {
                    if let url = url {
                        let videoVC = AVPlayerViewController()
                        
                        videoVC.player = AVPlayer(url: url)
                        self.parent?.present(videoVC, animated: true)
                        videoVC.player?.play()
                    } else {
                        self.presentOkAlert(withTitle: "אופס!", withMessage: "נראה שהסירטון אינו זמין לצפייה", buttonText: "סגירה")
                    }
                }
            }
        }
    }
    private func disableInteraction() {
        Spinner.shared.show()
    }
    private func ableInteraction() {
        Spinner.shared.stop()
    }
}
