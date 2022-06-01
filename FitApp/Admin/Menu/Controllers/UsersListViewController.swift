//
//  UsersListViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 18/05/2022.
//

import UIKit

class UsersListViewController: UIViewController {
	
	private let viewModel = UsersListViewModel()
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var searchControllerView: UISearchBar!
	
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
		
		Spinner.shared.show(view)
		setupView()
		bindViewModel()
	}
	
	@IBAction func closeButtonAction(_ sender: Any) {
		dismiss(animated: true)
	}
	@IBAction func broadcastButtonAction(_ sender: Any) {
		presentTextFieldAlert(withTitle: "מה תרצו לכתוב?", withMessage: "", options: "שלח", "ביטול")
	}
}

//MARK: - Delegates
extension UsersListViewController: UISearchBarDelegate {
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty, text.count > 1 else {
			self.viewModel.filterUsers(with: nil) {}
			self.tableView.reloadData()
			return
		}
		viewModel.filterUsers(with: text) {
			self.tableView.reloadData()
		}
	}
}
extension UsersListViewController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		viewModel.getChatsCount ?? 0
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.adminUserMenuCell) as! AdminUserMenuTableViewCell
		let cellData = viewModel.getChatFor(row: indexPath.row)
		
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
		if let textFieldValue = textFieldValue {
			viewModel.sendBroadcastMessage(text: textFieldValue)
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
	
	private func setupView() {
		searchControllerView.placeholder = "חפשו משתמשים..."
		tableView.register(UINib(nibName: K.NibName.adminUserMenuTableViewCell, bundle: nil), forCellReuseIdentifier: K.CellId.adminUserMenuCell)
	}
	private func bindViewModel() {

		viewModel.filteredUsers.bind {
			users in
			if users != nil {
				DispatchQueue.main.async {
					self.tableView.reloadData()
					Spinner.shared.stop()
				}
			}
		}
	}
	private func moveToUserDetails(userData: Chat) {
		let sender: [String: Chat?] = ["userChat": userData]
		performSegue(withIdentifier: K.SegueId.moveToUserDetails, sender: sender)
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

