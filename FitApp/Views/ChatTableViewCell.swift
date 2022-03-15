//
//  ChatTableViewCell.swift
//  FitApp
//
//  Created by Ofir Elias on 09/02/2021.
//

import UIKit
import Combine

class ChatTableViewCell: UITableViewCell {
	
	private var cancellable: AnyCancellable?
	private var animator: UIViewPropertyAnimator?
	private weak var googleDatabaseManager = GoogleDatabaseManager.shared
	
	@IBOutlet weak var userImageView: UIImageView!
	@IBOutlet weak var userNameLabel: UILabel!
	@IBOutlet weak var usrMessageLabel: UILabel!
	@IBOutlet weak var lastSentMessageTime: UILabel!
	
	@IBOutlet weak var unreadMessageCounterView: UIView!

	override func awakeFromNib() {
		super.awakeFromNib()
	}
	override public func prepareForReuse() {
		super.prepareForReuse()
		
		userImageView.image = nil
		userImageView.alpha = 0.0
		unreadMessageCounterView.isHidden = false
		animator?.stopAnimation(true)
		cancellable?.cancel()
	}
}

extension ChatTableViewCell {
	
	public func configure(with chat: Chat) {

		userNameLabel.text = chat.displayName
		usrMessageLabel.text = "\(chat.latestMessage?.content ?? "")"
		lastSentMessageTime.text = chat.latestMessage?.sentDate.timeString
		unreadMessageCounterView.isHidden = isLastMessageReadFor(chat: chat)
		
		cancellable = loadImage(for: chat).sink {
			[unowned self] image in
			self.showImage(image: image)
		}
	}
	
	private func showImage(image: UIImage?) {
		userImageView.alpha = 0.0
		animator?.stopAnimation(false)
		userImageView.image = image
		animator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
			self.userImageView.alpha = 1.0
		})
	}
	private func loadImage(for chat: Chat) -> AnyPublisher<UIImage?, Never> {
		return Just(chat.imagePath)
		.flatMap({ poster -> AnyPublisher<UIImage?, Never> in
			guard let url = chat.imagePath else { return Just(UIImage(systemName:"person.circle")).eraseToAnyPublisher() }
			return ImageLoader.shared.loadImage(from: url)
		})
		.eraseToAnyPublisher()
	}
	private func isLastMessageReadFor(chat: Chat) -> Bool {
		guard let lastSeen = chat.lastSeenMessageDate, let lastMessage = chat.latestMessage?.sentDate else { return false }
		return lastSeen > lastMessage
	}
}
