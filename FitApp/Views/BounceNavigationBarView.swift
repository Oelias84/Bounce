//
//  BounceNavigationBarView.swift
//  FitApp
//
//  Created by Ofir Elias on 13/12/2021.
//

import Foundation
import UIKit

protocol BounceNavigationBarDelegate: AnyObject {
	
	func backButtonTapped()
	func messageButtonTapped()
	func userProfileImageDidTapp()
}

final class BounceNavigationBarView: UIView {
	
	
	@IBOutlet private var view: UIView!
	@IBOutlet weak var backButton: UIButton!
	@IBOutlet weak var userProfileImage: UIImageView! {
		didSet{
			userProfileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userProfileImageTapped)))
		}
	}
	@IBOutlet private weak var messageButton: UIButton!
	@IBOutlet private weak var nameTitleLabel: UILabel!
	@IBOutlet private weak var dayWelcomeLabel: UILabel!
	@IBOutlet weak var backgroundImage: UIImageView! {
		didSet {
			backgroundImage.dropShadow()
		}
	}
	
	weak var delegate: BounceNavigationBarDelegate?
	
	var nameTitle: String = "" {
		didSet {
			nameTitleLabel.text = nameTitle
		}
	}
	var dayWelcome: String = "" {
		didSet {
			dayWelcomeLabel.text = dayWelcome
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
	
	override func awakeFromNib() {
		initWithNib()
	}
	
	@IBAction func backButtonTapped(_ sender: Any) {
		delegate?.backButtonTapped()
	}
	@IBAction func messageButtonTapped(_ sender: Any) {
		delegate?.messageButtonTapped()
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
		if let image = UserProfile.defaults.profileImageImageUrl?.showImage {
			userProfileImage.image = image.circleMasked
		}
	}
	@objc private func backButtonImageTapped() {
		delegate?.backButtonTapped()
	}
	@objc private func userProfileImageTapped() {
		delegate?.userProfileImageDidTapp()
	}
}
