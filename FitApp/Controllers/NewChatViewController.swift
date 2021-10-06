//
//  NewChatViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 05/02/2021.
//

import UIKit

class NewChatViewController: UITableViewController {
	
	private var chatUsers = [ChatUser]()
	private var flitteredChatUsers: [ChatUser]? {
		didSet {
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}
	}
	
	private var isManager = UserProfile.defaults.isManager ?? false
	
	private var hasFetched = false
	
	public var completion: ((ChatUser) -> Void)?
	
	private let searchBar: UISearchBar = {
		let searchBar = UISearchBar()
		searchBar.placeholder = "חפש משתמשים..."
		return searchBar
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
		fetchUsers()
		setDelegates()
	}
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		noResultsLabel.frame = CGRect(x: view.frame.width/2,
									  y: (view.frame.height-200/2),
									  width: view.frame.width/2, height: 200)
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		flitteredChatUsers?.count ?? 0
	}
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		cell.textLabel?.text = flitteredChatUsers?[indexPath.row].name
		return cell
	}
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		guard let targetUserData = flitteredChatUsers?[indexPath.row] else { return }
		
		dismiss(animated: true) {
			[weak self] in
			guard let self = self else { return }
			self.completion?(targetUserData)
		}
	}
}

//MARK: - functions
extension NewChatViewController {
	
	
	private func setupView() {
		navigationController?.navigationBar.topItem?.titleView = searchBar
		view.addSubview(noResultsLabel)
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelButtonAction))
		setupBroadcastMessages()
	}
	private func setDelegates() {
		searchBar.delegate = self
		tableView.delegate = self
		tableView.dataSource = self
	}
	private func fetchUsers() {
		GoogleDatabaseManager.shared.getChatUsers {
			[weak self] results in
			guard let self = self else { return }
			
			switch results {
			case .success(let users):
				self.chatUsers = users.filter { $0.name != "Support User" }
				self.flitteredChatUsers = self.chatUsers
			case .failure(let error):
				print("Failed to fetch users", error)
			}
		}
	}
	private func filterUsers(with term: String) {
		
		Spinner.shared.stop()
		let results = self.chatUsers.filter({
			let name = $0.name.lowercased()
			return name.hasPrefix(term.lowercased())
		})
		
		flitteredChatUsers = results
	}
	
	private func setupBroadcastMessages() {
		navigationController?.navigationBar.topItem?.titleView = searchBar
		let button = UIBarButtonItem(title: nil, style: .done, target: self, action: #selector(broadcastMessagesButtonAction))
		button.image = UIImage(systemName: "bubble.left.and.bubble.right.fill")
		navigationItem.leftBarButtonItem = button
	}
	
	@objc private func cancelButtonAction() {
		dismiss(animated: true)
	}
	@objc private func broadcastMessagesButtonAction() {
		let messageAlert = UIAlertController(title: "הודעת תפוצה", message: "הקלד כאן את ההודעה אותה תרצה לשלוח לכל המשתמשים", preferredStyle: .alert)
		
		messageAlert.addTextField { textField in
			textField.placeholder = "טקסט..."
		}
		messageAlert.addAction(UIAlertAction(title: "שלח", style: .default) { _ in
			guard let textField = messageAlert.textFields?[0], let text = textField.text, !text.isEmpty else { return }
			
			MessagesManager.shared.postBroadcast(text: text, chatUsers: self.self.chatUsers)
			self.dismiss(animated: true)
		})
		messageAlert.addAction(UIAlertAction(title: "ביטול", style: .cancel))
		present(messageAlert, animated: true)
	}
}

//MARK: - Delegates
extension NewChatViewController: UISearchBarDelegate {
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty, text.count > 1 else {
			flitteredChatUsers = chatUsers
			return
		}
		
		filterUsers(with: text)
	}
}
