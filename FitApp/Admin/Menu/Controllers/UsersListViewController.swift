//
//  UsersListViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 18/05/2022.
//

import UIKit

class UsersListViewController: UIViewController {
	
	private let viewModel = UsersListViewModel()
	
	@IBOutlet weak var detailsView: UIView!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var searchControllerView: UISearchBar!
	
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
		
		viewModel.filteredUsers.bind { _ in
			UIView.animate(withDuration: 0, delay: 0, options: .curveEaseIn, animations: {
				self.tableView.reloadData()
			}) { _ in
				Spinner.shared.stop()
			}
		}
	}
	private func moveToUserDetails(userData: Chat) {
		guard let userDetailVC = storyboard?.instantiateViewController(withIdentifier: K.ViewControllerId.userDetailsViewController) as? UserDetailsViewController else { return }
		
		userDetailVC.title = userData.displayName ?? "אין שם"
		userDetailVC.viewModel = UserDetailsViewModel(userData: userData)
		navigationController?.pushViewController(userDetailVC, animated: true)
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

