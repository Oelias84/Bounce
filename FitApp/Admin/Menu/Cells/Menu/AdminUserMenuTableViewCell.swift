//
//  AdminMenuTableViewCell.swift
//  FitApp
//
//  Created by Ofir Elias on 18/05/2022.
//

import UIKit
import Combine

class AdminUserMenuTableViewCell: UITableViewCell {
	
	private var chat: Chat!
	private var cancellable: AnyCancellable?
	private var animator: UIViewPropertyAnimator?
	
	@IBOutlet weak var userImageView: UIImageView!
	@IBOutlet weak var userNameLabel: UILabel!
	@IBOutlet weak var messageButton: UIButton!
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	override public func prepareForReuse() {
		super.prepareForReuse()
		
		userImageView.image = nil
		userImageView.alpha = 0.0
		animator?.stopAnimation(true)
		cancellable?.cancel()
	}
	
	@IBAction private func messageButtonAction(_ sender: Any) {
		moveToChatContainerVC(chatData: chat)
	}
}

extension AdminUserMenuTableViewCell {
	
	public func configure(with chat: Chat) {
		self.chat = chat
		
		if let userName = chat.displayName {
			userNameLabel.text =  userName
			userNameLabel.textColor = .black
		} else {
			userNameLabel.text = "שם לא נמצא"
			userNameLabel.textColor = .red
		}
		cancellable = loadImage(for: chat).sink {
			[unowned self] image in
			self.showImage(image: image)
		}
		isLastMessageReadFor(chat: chat) ? messageButton.setImage(UIImage(systemName: "message"), for: .normal)
		: messageButton.setImage(UIImage(systemName: "message.fill"), for: .normal)
	}
	
	fileprivate func showImage(image: UIImage?) {
		userImageView.alpha = 0.0
		animator?.stopAnimation(false)
		userImageView.image = image
		animator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
			self.userImageView.alpha = 1.0
		})
	}
	fileprivate func loadImage(for chat: Chat) -> AnyPublisher<UIImage?, Never> {
		return Just(chat.imagePath)
		.flatMap({ poster -> AnyPublisher<UIImage?, Never> in
			guard let url = chat.imagePath else { return Just(UIImage(systemName:"person.circle")).eraseToAnyPublisher() }
			return ImageLoader.shared.loadImage(from: url)
		})
		.eraseToAnyPublisher()
	}
	fileprivate func isLastMessageReadFor(chat: Chat) -> Bool {
		guard let lastSeen = chat.lastSeenMessageDate, let lastMessage = chat.latestMessage?.sentDate else { return false }
		return lastSeen > lastMessage
	}
	fileprivate func moveToChatContainerVC(chatData: Chat) {
		let storyboard = UIStoryboard(name: K.StoryboardName.chat, bundle: nil)
		let chatContainerVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.ChatContainerViewController) as ChatContainerViewController
		
		chatContainerVC.chatViewController = ChatViewController(viewModel: ChatViewModel(chat: chatData))
		chatContainerVC.modalPresentationStyle = .fullScreen
		parentViewController?.present(chatContainerVC, animated: true)
	}
}
