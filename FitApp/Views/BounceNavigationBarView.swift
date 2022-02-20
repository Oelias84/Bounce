//
//  BounceNavigationBarView.swift
//  FitApp
//
//  Created by Ofir Elias on 13/12/2021.
//

import UIKit
import Foundation

@objc protocol BounceNavigationBarDelegate: AnyObject {
	
	func backButtonTapped()
	@objc optional func cameraButtonTapped()
}

final class BounceNavigationBarView: UIView {
	
	var changeImage: Bool = false
	
	@IBOutlet private var view: UIView!
	
	@IBOutlet private weak var clearView: UIView!
	@IBOutlet private weak var backButton: UIButton!
	@IBOutlet private weak var messageButton: UIButton!
	@IBOutlet private weak var informationButton: UIButton!
	@IBOutlet public weak var userProfileButton: UIButton! {
		didSet {
			if let image = UserProfile.defaults.userProfileImage {
				userProfileButton.setImage(image.circleMasked, for: .normal)
			}
		}
	}
	
	@IBOutlet private weak var nameTitleLabel: UILabel!
	@IBOutlet private weak var dayWelcomeLabel: UILabel!
	@IBOutlet private weak var motivationLabel: UILabel!
	
	@IBOutlet weak var backgroundImage: UIImageView! {
		didSet {
			backgroundImage.dropShadow()
		}
	}
	
	weak var delegate: BounceNavigationBarDelegate?
	
	var nameTitle: String? = "" {
		didSet {
			nameTitleLabel.text = nameTitle
		}
	}
	var dayWelcomeText: String? = "" {
		didSet {
			dayWelcomeLabel.text = dayWelcomeText
		}
	}
	var motivationText: String? = "" {
		didSet {
			motivationLabel.text = motivationText
		}
	}
	var isCameraButton: Bool = false {
		didSet {
			if isCameraButton {
				userProfileButton.setImage(UIImage(systemName: "camera"), for: .normal)
			}
		}
	}
	var isProfileButtonHidden: Bool {
		set {
			userProfileButton.isHidden = newValue
		}
		get {
			return userProfileButton.isHidden
		}
	}
	var isDayWelcomeHidden: Bool {
		set {
			dayWelcomeLabel.isHidden = newValue
		}
		get {
			return dayWelcomeLabel.isHidden
		}
	}
	var isMessageButtonHidden: Bool {
		set {
			messageButton.isHidden = newValue
		}
		get {
			return messageButton.isHidden
		}
	}
	var isBackButtonHidden: Bool {
		set {
			backButton.isHidden = newValue
		}
		get {
			return backButton.isHidden
		}
	}
	var isMotivationHidden: Bool {
		set {
			motivationLabel.isHidden = newValue
		}
		get {
			return motivationLabel.isHidden
		}
	}
	var isClearButtonHidden: Bool {
		set {
			clearView.isHidden = newValue
		}
		get {
			return clearView.isHidden
		}
	}
	var isInformationButtonHidden: Bool {
		set {
			informationButton.isHidden = newValue
		}
		get {
			return informationButton.isHidden
		}
	}
	
	override func layoutSubviews() {
		setImage()
	}
	override func awakeFromNib() {
		initWithNib()
	}
	
	@IBAction func userProfileButtonTapped(_ sender: Any) {
		openSettings()
		if ((delegate as? SettingsViewController) != nil) {
			delegate?.cameraButtonTapped?()
		}
	}
	@IBAction func messageButtonTapped(_ sender: Any) {
		openChat()
	}
	@IBAction func backButtonTapped(_ sender: Any) {
		delegate?.backButtonTapped()
	}
}

//MARK: - Functions
extension BounceNavigationBarView {
	
	private func initWithNib() {
		Bundle.main.loadNibNamed(K.NibName.bounceNavigationBarView, owner: self, options: nil)
		addSubview(view)
		frame = self.bounds
		autoresizingMask = [.flexibleHeight, .flexibleWidth]
		setupLayout()
	}
	private func setupLayout() {
		NSLayoutConstraint.activate(
			[
				view.topAnchor.constraint(equalTo: topAnchor),
				view.leadingAnchor.constraint(equalTo: leadingAnchor),
				view.bottomAnchor.constraint(equalTo: bottomAnchor),
				view.trailingAnchor.constraint(equalTo: trailingAnchor),
			]
		)
		if let permission = UserProfile.defaults.permissionLevel {
			if permission < 10 {
				messageButton.isHidden = true
			}
		}
	}
	private func openChat() {
		let storyboard = UIStoryboard(name: K.StoryboardName.chat, bundle: nil)
		
		if UserProfile.defaults.getIsManager {
			let chatsVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.ChatsViewController) as ChatsViewController
			
			if let vc = delegate as? UIViewController {
				vc.navigationController?.pushViewController(chatsVC, animated: true)
			}
		} else {
			let chatContainerVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.ChatContainerViewController) as ChatContainerViewController
			chatContainerVC.chatViewController = ChatViewController(viewModel: ChatViewModel(chat: nil))
			
			if let vc = delegate as? UIViewController {
				vc.navigationController?.pushViewController(chatContainerVC, animated: true)
			}
		}
	}
	private func openSettings() {
		let storyboard = UIStoryboard(name: K.StoryboardName.settings, bundle: nil)
		let settingsVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.SettingsViewController)
		
		if let delegate = delegate as? HomeViewController {
			
			delegate.navigationController?.pushViewController(settingsVC, animated: true)
		} else if let delegate = delegate as? MealPlanViewController {
			
			delegate.navigationController?.pushViewController(settingsVC, animated: true)
		} else if let delegate = delegate as? WorkoutTableViewController {
			
			delegate.navigationController?.pushViewController(settingsVC, animated: true)
		} else if let delegate = delegate as? WeightProgressViewController {
			
			delegate.navigationController?.pushViewController(settingsVC, animated: true)
		} else if let delegate = delegate as? ArticlesViewController {
			
			delegate.navigationController?.pushViewController(settingsVC, animated: true)
		}
	}
	func setImage() {
		userProfileButton.isEnabled = false
		if !changeImage, let image = UserProfile.defaults.userProfileImage {
			
			DispatchQueue.main.async {
				self.userProfileButton.setImage(image.circleMasked, for: .normal)
				self.userProfileButton.isEnabled = true
			}
		} else if let imageURLString = UserProfile.defaults.profileImageImageUrl, let imageURL = URL(string: imageURLString) {
			let imageView = UIImageView()
			
			imageView.sd_setImage(with: imageURL) {
				[weak self] image, error, type, url  in
				guard let self = self else { return }
				self.userProfileButton.isEnabled = true

				if let image = imageView.image {
					
					UserProfile.defaults.userProfileImage = image
					DispatchQueue.main.async {
						self.userProfileButton.setImage(image.circleMasked, for: .normal)
						self.changeImage = false
					}
				}
			}
		} else {
			self.userProfileButton.isEnabled = true
		}
	}
}
