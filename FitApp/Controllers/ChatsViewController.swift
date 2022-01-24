//
//  ChatsViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 05/02/2021.
//

import UIKit

class ChatsViewController: UIViewController {
	
	private var chatsViewModel: ChatsViewModel!
	private var isManager = UserProfile.defaults.getIsManager

	@IBOutlet weak var topBarView: BounceNavigationBarView!
	@IBOutlet weak var tableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if let navView = navigationController?.view { Spinner.shared.show(navView) }
		chatsViewModel = ChatsViewModel()

		setupTopBar()
		setupTableView()
		alertForDirectingToQA()
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		topBarView.setImage()
		chatsViewModel.bindChatsViewModelToController = {
			Spinner.shared.stop()
			self.updateUI()
		}
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
		
		cell.chat = cellData
		return cell
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let chatData = chatsViewModel.getChatFor(row:indexPath.row)

		chatsViewModel.updateChatState(chat: chatData)
		moveToChatContainerVC(chatData: chatData, isNewChat: chatsViewModel.isNewChat)
	}
}
extension ChatsViewController: BounceNavigationBarDelegate {
	
	func backButtonTapped() {
		navigationController?.popViewController(animated: true)
	}
}
extension ChatsViewController: PopupAlertViewDelegate {
	
	func okButtonTapped(alertNumber: Int, selectedOption: String?, textFieldValue: String?) {
		if let navC = self.tabBarController?.viewControllers?[4] as? UINavigationController {
			let tableC = navC.viewControllers.last as! ArticlesViewController
			
			tableC.openFromChat = true
			self.tabBarController?.selectedIndex = 4
			self.navigationController?.popToRootViewController(animated: false)
		}
	}
	func cancelButtonTapped(alertNumber: Int) {
		return
	}
	func thirdButtonTapped(alertNumber: Int) {
		UserProfile.defaults.showQaAlert = false
	}
}

// MARK: - Functions
extension ChatsViewController {
	
	private func setupTopBar() {
		
		topBarView.nameTitle = "צ׳אטים"
		topBarView.delegate = self
		topBarView.isDayWelcomeHidden = true
		topBarView.isMotivationHidden = true
		topBarView.isBackButtonHidden = false
		topBarView.isMessageButtonHidden = true
	}
	private func updateUI() {
		DispatchQueue.main.async {
			[unowned self] in
			Spinner.shared.stop()
			self.tableView.reloadData()
		}
	}
	private func setupTableView() {
		tableView.register(UINib(nibName: K.NibName.chatTableViewCell, bundle: nil), forCellReuseIdentifier: K.CellId.chatCell)
		if isManager {
			navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(addChatDidTapped))
		}
	}
	private func alertForDirectingToQA() {
		if UserProfile.defaults.showQaAlert == nil {
			presentAlert(withTitle: "רק רצינו לספר לך", withMessage: "הכנו מאמר שאלות תשובות נפוצות וכדאי לך לעבור עליו, אם את לא מוצאת תשובה, אנחנו פה לעזור לך :)", options: "אישור", "ביטול", "אל תציג שוב")
		}
	}
	private func createNewChat(result: ChatUser) {
		let name = result.name
		let email = result.email
		let chatVC = ChatViewController()//(with: email, id: nil, token: result.tokens)
		
		chatVC.otherUserEmail = email
		chatVC.otherTokens = result.tokens
		
		chatVC.isNewChat = true
		chatVC.title = name
		navigationController?.pushViewController(chatVC, animated: true)
	}
	private func moveToChatContainerVC(chatData: Chat, isNewChat: Bool) {
		let storyboard = UIStoryboard(name: K.StoryboardName.chat, bundle: nil)
		let chatContainerVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.ChatContainerViewController) as ChatContainerViewController
		chatContainerVC.chatData = chatData
		chatContainerVC.isNewChat = isNewChat
		navigationController?.pushViewController(chatContainerVC, animated: true)
	}
	private func presentAlert(withTitle title: String? = nil, withMessage message: String, options: (String)...) {
		guard let window = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window else {
			return
		}
		let storyboard = UIStoryboard(name: "PopupAlertView", bundle: nil)
		let customAlert = storyboard.instantiateViewController(identifier: "PopupAlertView") as! PopupAlertView
		
		customAlert.providesPresentationContextTransitionStyle = true
		customAlert.definesPresentationContext = true
		customAlert.modalPresentationStyle = .overCurrentContext
		customAlert.modalTransitionStyle = .crossDissolve

		customAlert.delegate = self
		customAlert.titleText = title
		customAlert.messageText = message
		customAlert.okButtonText = options[0]
		customAlert.cancelButtonText = options[1]
		
		if options.count == 3 {
			customAlert.doNotShowText = options.last
		}
		window.rootViewController?.present(customAlert, animated: true, completion: nil)
	}
	
	@objc private func addChatDidTapped() {
		let chatVC = storyboard?.instantiateViewController(identifier: K.ViewControllerId.NewChatViewController) as! NewChatViewController
		let nav = UINavigationController(rootViewController: chatVC)
		
		chatVC.completion = { [weak self]
			result in
			guard let self = self else { return }
			self.createNewChat(result: result)
		}
		
		nav.modalTransitionStyle = .coverVertical
		nav.modalPresentationStyle = .fullScreen
		present(nav, animated: true)
	}
}
