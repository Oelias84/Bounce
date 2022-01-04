//
//  ChatContainerViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 04/01/2022.
//

import UIKit
import Foundation
import InputBarAccessoryView

class ChatContainerViewController: UIViewController {
	
	var chatData: Chat!
	var isNewChat: Bool!
	var chatViewController: ChatViewController!
	
	@IBOutlet weak var topBarView: BounceNavigationBarView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupChat()
		setupTopBarView()
	}
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		let headerHeight: CGFloat = 236
		chatViewController.view.frame = CGRect(x: 0, y: headerHeight, width: view.bounds.width, height: view.bounds.height - headerHeight)
	}
	
	/// Required for the `MessageInputBar` to be visible
	override var canBecomeFirstResponder: Bool {
		return chatViewController.canBecomeFirstResponder
	}
	/// Required for the `MessageInputBar` to be visible
	override var inputAccessoryView: UIView? {
		return chatViewController.inputAccessoryView
	}
}

extension ChatContainerViewController: BounceNavigationBarDelegate {
	
	func backButtonTapped() {
		navigationController?.popViewController(animated: true)
	}
}
extension ChatContainerViewController {
	
	private func setupTopBarView() {
		topBarView.delegate = self
		topBarView.nameTitle = "דברי אלינו"
		topBarView.isDayWelcomeHidden = true
		topBarView.isMotivationHidden = true
		topBarView.isBackButtonHidden = false
		topBarView.isMessageButtonHidden = true
	}
	private func setupChat() {
		chatViewController = ChatViewController()
		chatViewController.chatId = chatData.id
		chatViewController.otherUserEmail = chatData.otherUserEmail
		chatViewController.otherTokens = chatData.otherUserTokens

		chatViewController.willMove(toParent: self)
		addChild(chatViewController)
		view.addSubview(chatViewController.view)
		chatViewController.didMove(toParent: self)
	}
}
