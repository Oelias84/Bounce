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
	
	var chatViewController: ChatViewController!
	
	@IBOutlet weak var topBarView: BounceNavigationBarView!
	@IBOutlet weak var topBarViewHeightConstraint: NSLayoutConstraint!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		Spinner.shared.show(self.view)
		setupChat()
		setupTopBarView()
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		topBarView.setImage()
	}
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		chatViewController.view.frame = CGRect(x: 0, y: topBarViewHeightConstraint.constant, width: view.bounds.width, height: view.bounds.height - topBarViewHeightConstraint.constant)
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
		if UserProfile.defaults.getIsManager {
			dismiss(animated: true)
		} else {
			navigationController?.popViewController(animated: true)
		}
	}
}
extension ChatContainerViewController {
	
	private func setupTopBarView() {
		topBarView.delegate = self
		topBarView.isDayWelcomeHidden = true
		topBarView.isMotivationHidden = true
		topBarView.isBackButtonHidden = false
		topBarView.isMessageButtonHidden = true
		topBarView.nameTitle = UserProfile.defaults.getIsManager ? chatViewController.viewModel.getDisplayName ?? "" : StaticStringsManager.shared.getGenderString?[25] ?? ""
	}
	private func setupChat() {

		chatViewController.willMove(toParent: self)
		addChild(chatViewController)
		view.addSubview(chatViewController.view)
		chatViewController.didMove(toParent: self)
		view.bringSubviewToFront(topBarView)
	}
}
