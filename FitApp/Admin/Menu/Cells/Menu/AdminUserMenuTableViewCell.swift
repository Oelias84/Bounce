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
	@IBOutlet weak var lastSeenImageView: UIImageView!
	@IBOutlet weak var isExpiredImageView: UIImageView!
	
	@IBOutlet weak var userNameLabel: UILabel!
	@IBOutlet weak var messageButton: UIButton!
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	override public func prepareForReuse() {
		super.prepareForReuse()
		
		lastSeenImageView.isHidden = true
		isExpiredImageView.isHidden = true

		userImageView.image = nil
		lastSeenImageView.image = nil
		isExpiredImageView.image = nil
		isExpiredImageView.tintColor = nil
		
		userImageView.alpha = 0.0
		animator?.stopAnimation(true)
		cancellable?.cancel()
	}
	
	@IBAction private func messageButtonAction(_ sender: Any) {
		moveToChatContainerVC()
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
		
		switch chat.programState {
		case .active:
			break
		case .expire:
			let image = UIImage(systemName: "clock.badge.exclamationmark")?.withRenderingMode(.alwaysTemplate)
			isExpiredImageView.isHidden = false
			isExpiredImageView.image = image
			isExpiredImageView.tintColor = .red
		case .expireSoon:
			let image = UIImage(systemName: "clock.badge.exclamationmark")
			isExpiredImageView.isHidden = false
			isExpiredImageView.image = image
		default:
			break
		}
		
		if chat.wasSeenLately {
			lastSeenImageView.isHidden = true
		} else {
			lastSeenImageView.isHidden = false
			lastSeenImageView.image = UIImage(systemName: "person.fill.questionmark")
		}
		
		if chat.isLastMessageReadFor {
			messageButton.setImage(UIImage(systemName: "message"), for: .normal)
		} else {
			messageButton.setImage(UIImage(systemName: "message.fill"), for: .normal)
		}
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
		return Just(chat.imagePath).flatMap { poster -> AnyPublisher<UIImage?, Never> in
			guard let url = chat.imagePath else { return Just(UIImage(systemName:"person.circle")).eraseToAnyPublisher() }
			return ImageLoader.shared.loadImage(from: url)
		}.eraseToAnyPublisher()
	}
	fileprivate func moveToChatContainerVC() {
		let chatVC = ChatViewController(viewModel: ChatViewModel(chat: chat))
		parentViewController?.navigationController?.show(chatVC, sender: nil)
	}
}
