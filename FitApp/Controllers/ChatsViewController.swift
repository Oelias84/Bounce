//
//  ChatsViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 05/02/2021.
//

import UIKit

final class ChatsViewController: UIViewController {
	
	private var chatsViewModel: ChatsViewModel!
	private var isManager = UserProfile.defaults.getIsManager

	@IBOutlet weak var topBarView: BounceNavigationBarView!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var searchControllerView: UISearchBar!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if let navView = navigationController?.view { Spinner.shared.show(navView) }

		chatsViewModel = ChatsViewModel()
		chatsViewModel.flitteredChats.bind() {
			chats in
			
			if chats != nil {
				self.updateUI()
			}
		}
		
		setupTopBar()
		firstDataLoad()
		setupSearchBar()
		setupTableView()
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		topBarView.setImage()
	}
}

// MARK: - Delegates
extension ChatsViewController: UITableViewDataSource, UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return chatsViewModel.getChatsCount ?? 0
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.chatCell) as! ChatTableViewCell
		let cellData = chatsViewModel.getChatFor(row: indexPath.row)
		
		cell.configure(with: cellData)
		return cell
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let chatData = chatsViewModel.getChatFor(row:indexPath.row)
		
		moveToChatContainerVC(chatData: chatData)
	}
}
extension ChatsViewController: BounceNavigationBarDelegate {
	
	func backButtonTapped() {
		navigationController?.popViewController(animated: true)
	}
}
extension ChatsViewController: UISearchBarDelegate {
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty, text.count > 1 else {
			self.chatsViewModel.filterUsers(with: nil) {}
			self.tableView.reloadData()
			return
		}
		chatsViewModel.filterUsers(with: text) {
			self.tableView.reloadData()
		}
	}
}

// MARK: - Functions
extension ChatsViewController {
	
	private func updateUI() {
		DispatchQueue.main.async {
			Spinner.shared.stop()
			self.tableView.reloadData()
		}
	}
	private func setupTopBar() {
		
		topBarView.nameTitle = "צ׳אטים"
		topBarView.delegate = self
		topBarView.isDayWelcomeHidden = true
		topBarView.isMotivationHidden = true
		topBarView.isBackButtonHidden = false
		topBarView.isMessageButtonHidden = true
	}
	private func setupSearchBar() {
		searchControllerView.placeholder = "חפשו משתמשים..."
		
	}
	private func firstDataLoad() {
		chatsViewModel.getChats {
			self.updateUI()
		}
	}
	private func setupTableView() {
		tableView.register(UINib(nibName: K.NibName.chatTableViewCell, bundle: nil), forCellReuseIdentifier: K.CellId.chatCell)
	}
		
	public func moveToChatContainerVC(chatData: Chat) {
		let storyboard = UIStoryboard(name: K.StoryboardName.chat, bundle: nil)
		let chatContainerVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.ChatContainerViewController) as ChatContainerViewController
		
		chatContainerVC.chatViewController = ChatViewController(viewModel: ChatViewModel(chat: chatData))
		navigationController?.pushViewController(chatContainerVC, animated: true)
	}
}
