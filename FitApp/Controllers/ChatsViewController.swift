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
	@IBOutlet weak var broadcastMessageButton: UIButton!
	@IBOutlet weak var searchControllerView: UISearchBar!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if let navView = navigationController?.view { Spinner.shared.show(navView) }

		chatsViewModel = ChatsViewModel()
		chatsViewModel.chatsViewModelBinder = {
			[weak self] in
			guard let self = self else { return }
			self.updateUI()
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
	
	@IBAction func broadcastMessageButtonAction(_ sender: UIButton) {
		presentTextFieldAlert(withTitle: "מה תרצו לכתוב?", withMessage: "", options: "שלח", "ביטול")
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
extension ChatsViewController: PopupAlertViewDelegate {
	
	func okButtonTapped(alertNumber: Int, selectedOption: String?, textFieldValue: String?) {
		if let textFieldValue = textFieldValue {
			chatsViewModel.sendBroadcastMessage(text: textFieldValue)
		}
	}
	func cancelButtonTapped(alertNumber: Int) {
		return
	}
	func thirdButtonTapped(alertNumber: Int) {
		UserProfile.defaults.showQaAlert = false
	}
}

//MARK: - Delegates
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
	private func presentTextFieldAlert(withTitle title: String? = nil, withMessage message: String, options: (String)...) {
		guard let window = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window else {
			return
		}
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
		window.rootViewController?.present(customAlert, animated: true, completion: nil)
	}
}
