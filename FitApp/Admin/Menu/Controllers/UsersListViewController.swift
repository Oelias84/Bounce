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

    override func viewDidLoad() {
        super.viewDidLoad()

		setupView()
		bindViewModel()
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
}

//MARK: - Functions
extension UsersListViewController {
	
	private func setupView() {
		searchControllerView.placeholder = "חפשו משתמשים..."
		tableView.register(UINib(nibName: K.NibName.adminUserMenuTableViewCell, bundle: nil), forCellReuseIdentifier: K.CellId.adminUserMenuCell)
	}
	private func bindViewModel() {
		
		viewModel.filteredUsers.bind { users in
			self.tableView.reloadData()
		}
	}
}

