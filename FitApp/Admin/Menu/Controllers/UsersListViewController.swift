//
//  UsersListViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 18/05/2022.
//

import UIKit

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
            
            // Update Menu
            if #available(iOS 14.0, *) {
                self.filerButtonView.menu = self.viewModel.filterMenu
            } else {
                // Fallback on earlier versions
            }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.adminUserMenuCell) as! AdminUserMenuTableViewCell
        let cellViewModel = viewModel.userViewModel(row: indexPath.row)
        
        cell.delegate = self
        upButtonAnimat(indexPath: indexPath)
        cell.configure(with: cellViewModel)
        animateCellBroadcastButton(for: cell)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userData = viewModel.userViewModel(row: indexPath.row).userDetailsViewModel
        moveToUserDetails(userData: userData)
    }
    
    func animateCellBroadcastButton(for cell: AdminUserMenuTableViewCell) {
        if self.viewModel.isBroadcastSelection == .selective {
            UIView.animate(withDuration: 0.2) {
                cell.broadcastButton.isHidden = false
            }
            UIView.animate(withDuration: 0.1, delay: 0.1) {
                cell.broadcastButton.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.1) {
                cell.broadcastButton.alpha = 0
            }
            UIView.animate(withDuration: 0.3) {
                cell.broadcastButton.isHidden = true
            }
        }
    }
}

extension UsersListViewController: PopupAlertViewDelegate {
    
    func okButtonTapped(alertNumber: Int, selectedOption: String?, textFieldValue: String?) {
        if let text = textFieldValue {
            viewModel.sendBroadcastMessage(text: text)
        }
        viewModel.removeBrodcastSelection()
        changeBrodcastButtonState()
        viewModel.isBroadcastSelection = nil
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    func cancelButtonTapped(alertNumber: Int) {
        viewModel.removeBrodcastSelection()
        changeBrodcastButtonState()
        viewModel.isBroadcastSelection = nil
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    func thirdButtonTapped(alertNumber: Int) {
        UserProfile.defaults.showQaAlert = false
    }
}

//MARK: - Functions
extension UsersListViewController {
    
    private func setupView() {
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
        navigationItem.searchController = searchController
        definesPresentationContext = true
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
    }
    
    private func moveToUserDetails(userData: UserDetailsViewModel) {
        let sender: [String: UserDetailsViewModel?] = ["userDetailsViewModel": userData]
        performSegue(withIdentifier: K.SegueId.moveToUserDetails, sender: sender)
    }
    
    private func presentBroadcastSheet() {
        let sheetAlert = UIAlertController(title: "Broad Cast", message: nil, preferredStyle: .actionSheet)
        
        let allFillterdOption = UIAlertAction(title: "כל המשתמשים", style: .default) { _ in
            self.viewModel.isBroadcastSelection = .allFilterd
            self.viewModel.brodcartAllUsers()
            self.changeBrodcastButtonState()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        let selectionOption = UIAlertAction(title: "בחירת משתמשים", style: .default) { _ in
            self.viewModel.isBroadcastSelection = .selective
            self.changeBrodcastButtonState()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
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
        customAlert.titleText = title
        customAlert.popupType = .textBox
        customAlert.messageText = message
        customAlert.okButtonText = options[0]
        customAlert.cancelButtonText = options[1]
        
        if options.count == 3 {
            customAlert.doNotShowText = options.last
        }
        
        present(customAlert, animated: true, completion: nil)
    }
}

extension UsersListViewController: AdminUserMenuTableViewCellDelegate {
    
    func broadcastButtonTapped(userViewModel: UserViewModel) {
        viewModel.addOrRemoveSelectedUser(userViewModel)
    }
}
