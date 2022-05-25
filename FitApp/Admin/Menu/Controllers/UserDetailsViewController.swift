//
//  UserDetailsViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 25/05/2022.
//

import UIKit

class UserDetailsViewController: UIViewController {
	
	var viewModel: UserDetailsViewModel!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
    }
	
	@IBAction func chatButtonAction(_ sender: UIBarButtonItem) {
		moveToChatContainerVC(chatData: viewModel.getUserChat)
	}
	@IBAction func weightsButtonAction(_ sender: UIButton) {
		moveToWeightProgressVC(chatData: viewModel.getUserChat)
	}
}

//MARK: - Functions
extension UserDetailsViewController {
	
	private func moveToChatContainerVC(chatData: Chat) {
		let storyboard = UIStoryboard(name: K.StoryboardName.chat, bundle: nil)
		let chatContainerVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.ChatContainerViewController) as ChatContainerViewController
		
		chatContainerVC.chatViewController = ChatViewController(viewModel: ChatViewModel(chat: chatData))
		chatContainerVC.modalPresentationStyle = .fullScreen
		present(chatContainerVC, animated: true)
	}
	private func moveToWeightProgressVC(chatData: Chat) {
		let storyboard = UIStoryboard(name: K.StoryboardName.weightProgress, bundle: nil)
		let weightProgressVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.weightViewController) as WeightProgressViewController
		
		weightProgressVC.isFromAdmin = true
		weightProgressVC.weightViewModel = WeightViewModel(userUID: chatData.userId)
		weightProgressVC.modalPresentationStyle = .fullScreen
		present(weightProgressVC, animated: true)
	}
}
////MARK: - Delegates
//extension <#code#>: <#code#>  {
//	<#code#>
//}
