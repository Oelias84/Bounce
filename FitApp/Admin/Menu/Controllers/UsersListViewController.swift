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
	
	private var isSearchBarEmpty: Bool {
		return searchController.searchBar.text?.isEmpty ?? true
	}
	private let searchController = UISearchController(searchResultsController: nil)
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "moveToUserDetails" {
			if let userDetailsVC = segue.destination as? UserDetailsViewController {
				
				guard let sender = sender as? [String: Chat], let userData = sender["userChat"] else { return }
				userDetailsVC.modalPresentationStyle = .fullScreen
				userDetailsVC.navigationItem.largeTitleDisplayMode = .always
				
				userDetailsVC.title = userData.displayName ?? "אין שם"
				userDetailsVC.viewModel = UserDetailsViewModel(userData: userData)
			}
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
	@objc func yourMethodName() {
		print("Cancel button tap")
	}
	
	@IBAction func upButtonAction(_ sender: Any) {
		let indexPath = IndexPath(row: 0, column: 0)
		tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
	}
	@IBAction func closeButtonAction(_ sender: Any) {
		dismiss(animated: true)
	}
	@IBAction func broadcastButtonAction(_ sender: Any) {
		presentTextFieldAlert(withTitle: "מה תרצו לכתוב?", withMessage: "", options: "שלח", "ביטול")
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
		viewModel.getChatsCount ?? 0
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.adminUserMenuCell) as! AdminUserMenuTableViewCell
		let cellData = viewModel.getChatFor(row: indexPath.row)
		
		upButtonAnimat(indexPath: indexPath)
		cell.configure(with: cellData)
		return cell
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let userData = viewModel.getChatFor(row: indexPath.row)
		moveToUserDetails(userData: userData)
	}
}

extension UsersListViewController: PopupAlertViewDelegate {
	
	func okButtonTapped(alertNumber: Int, selectedOption: String?, textFieldValue: String?) {
		if let text = textFieldValue {
			viewModel.sendBroadcastMessage(text: text)
		}
	}
	func cancelButtonTapped(alertNumber: Int) {
		return
	}
	func thirdButtonTapped(alertNumber: Int) {
		UserProfile.defaults.showQaAlert = false
	}
}

//MARK: - Functions
extension UsersListViewController {
	
	fileprivate func setupView() {
		if #available(iOS 14.0, *) {
			filerButtonView.menu = viewModel.filterMenu
			filerButtonView.showsMenuAsPrimaryAction = true
		} else {
			//Sheet
		}
		tableView.register(UINib(nibName: K.NibName.adminUserMenuTableViewCell, bundle: nil), forCellReuseIdentifier: K.CellId.adminUserMenuCell)
	}
	fileprivate func bindViewModel() {
		viewModel.filteredUsers.bind {
			users in
			if users != nil {
				DispatchQueue.main.async {
					self.title = "\(self.viewModel.getChatsCount ?? 0) משתמשים"
					self.tableView.reloadData()
					Spinner.shared.stop()
				}
			} else {
				Spinner.shared.stop()
			}
		}
	}
	fileprivate func setupSearchBar() {
		searchController.searchBar.placeholder = "חיפוש משתמשים"
		searchController.searchResultsUpdater = self
		searchController.obscuresBackgroundDuringPresentation = false
		navigationItem.searchController = searchController
		definesPresentationContext = true
	}
	fileprivate func moveToUserDetails(userData: Chat) {
		let sender: [String: Chat?] = ["userChat": userData]
		performSegue(withIdentifier: K.SegueId.moveToUserDetails, sender: sender)
	}
	fileprivate func upButtonAnimat(indexPath: IndexPath) {
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
	
	fileprivate func presentTextFieldAlert(withTitle title: String? = nil, withMessage message: String, options: (String)...) {
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

