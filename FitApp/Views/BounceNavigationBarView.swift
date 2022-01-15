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
	
	@IBOutlet private var view: UIView!
	
	@IBOutlet private weak var clearView: UIView!
	@IBOutlet private weak var backButton: UIButton!
	@IBOutlet private weak var messageButton: UIButton!
	@IBOutlet private weak var informationButton: UIButton!
	@IBOutlet private weak var userProfileButton: UIButton!
	
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
	
	override func awakeFromNib() {
		initWithNib()
	}
	
	@IBAction func userProfileButtonTapped(_ sender: Any) {
		openSettings()
		delegate?.cameraButtonTapped?()
	}
	@IBAction func messageButtonTapped(_ sender: Any) {
		openMessages()
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
		setImage()
	}
	private func openMessages() {
		let chatStoryboard = UIStoryboard(name: K.StoryboardName.chat, bundle: nil)
		let chatsVC = chatStoryboard.instantiateViewController(identifier: K.ViewControllerId.ChatsViewController)
		
		if let vc = delegate as? UIViewController {
			vc.navigationController?.pushViewController(chatsVC, animated: true)
		}
	}
	private func openSettings() {
		
		let storyboard = UIStoryboard(name: K.StoryboardName.settings, bundle: nil)
		let settingsVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.SettingsViewController)
		
		if let vc = delegate as? HomeViewController {
			vc.navigationController?.pushViewController(settingsVC, animated: true)
		}
	}
	func setImage() {
		if let image = UserProfile.defaults.profileImageImageUrl, let url = URL(string: image) {

			DispatchQueue.main.async {
				let imageView = UIImageView()
				imageView.sd_setImage(with: url) {
					[weak self] image, error, type, url  in
					guard let self = self else { return }
					
					if let image = imageView.image {
						Spinner.shared.stop()
						self.userProfileButton.setImage(image.circleMasked, for: .normal)
					}
				}
			}
		}
	}
}

