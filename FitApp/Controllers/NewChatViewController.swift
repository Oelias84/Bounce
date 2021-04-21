//
//  NewChatViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 05/02/2021.
//

import UIKit

class NewChatViewController: UIViewController {
	
	private var chatUsers = [[String:String]]()
	private var results = [[String:String]]()
	private var isManager = false
	private var hasFetched = false
	
	public var completion: (([String:String]) -> Void)?
	
	private let searchBar: UISearchBar = {
		let searchBar = UISearchBar()
		searchBar.placeholder = "חפש משתמשים..."
		return searchBar
	}()
	
	private let tableView: UITableView = {
		let tableView = UITableView()
		tableView.isHidden = true
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		return tableView
	}()
	
	private let noResultsLabel: UILabel = {
		let label = UILabel()
		label.isHidden = true
		label.text = "אין תוצאות"
		label.textAlignment = .center
		label.textColor = .green
		label.font = .systemFont(ofSize: 22, weight: .medium)
		return label
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupView()
		setDelegates()
	}
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		tableView.frame = view.bounds
		noResultsLabel.frame = CGRect(x: view.frame.width/2,
									  y: (view.frame.height-200/2),
									  width: view.frame.width/2, height: 200)
	}
	
	@objc func cancelButtonAction() {
		dismiss(animated: true)
	}
}

extension NewChatViewController: UITableViewDataSource, UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		results.count
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		cell.textLabel?.text = results[indexPath.row]["name"]
		return cell
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let targetUserData = results[indexPath.row]
		
		dismiss(animated: true) { [weak self] in
			guard let self = self else { return }
			self.completion?(targetUserData)
		}
	}
}

extension NewChatViewController {
	
	private func setupView() {
		navigationController?.navigationBar.topItem?.titleView = searchBar
		view.addSubview(noResultsLabel)
		view.addSubview(tableView)
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelButtonAction))
	}
	private func updateUI() {
		if results.isEmpty {
			self.noResultsLabel.isHidden = false
			self.tableView.isHidden = true
		} else {
			self.noResultsLabel.isHidden = true
			self.tableView.isHidden = false
			DispatchQueue.main.async { [weak self] in
				guard let self = self else { return }
				self.tableView.reloadData()
			}
		}
	}
	private func setDelegates() {
		searchBar.delegate = self
		tableView.delegate = self
		tableView.dataSource = self
	}
	private func addSupport() {
		let nutritionSupport: [String:String] = [
			"email": "support-mail-com",
			"name": "תזונה"
		]
		let fitnessSupport: [String:String] = [
			"email": "support-mail-com",
			"name": "כושר"
		]
		self.results.append(nutritionSupport)
		self.results.append(fitnessSupport)
		updateUI()
	}
}

extension NewChatViewController: UISearchBarDelegate {
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
			return
		}
		searchBar.resignFirstResponder()
		
		self.results.removeAll()
		Spinner.shared.show(view)
		
		self.searchUsers(query: text)
	}
	private func searchUsers(query: String) {
		if hasFetched {
			filterUsers(with: query)
		} else {
			GoogleDatabaseManager.shared.getChatUsers { [weak self] results in
				guard let self = self else { return }
				
				switch results {
				case .success(let users):
					self.chatUsers = users
					self.filterUsers(with: query)
					self.hasFetched = true
				case .failure(let error):
					print("Failed to fetch users", error)
				}
			}
		}
	}
	private func filterUsers(with term: String) {
		guard !hasFetched else {
			return
		}
		Spinner.shared.stop()
		let results: [[String:String]] = self.chatUsers.filter({
			guard let name = $0["name"]?.lowercased() else {
				return false
			}
			return name.hasPrefix(term.lowercased())
		})
		self.results = results
		updateUI()
	}
}


