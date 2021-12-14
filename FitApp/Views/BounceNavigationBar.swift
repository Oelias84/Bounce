//
//  BounceNavigationBar.swift
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

final class BounceNavigationBar: UIView {
	
	private static let NIB_NAME = "NavigationBar"
	
	@IBOutlet private var view: UIView!
	@IBOutlet weak var userProfileImage: UIImageView! {
		didSet{
			userProfileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userProfileImageTapped)))
		}
	}
	@IBOutlet weak var backButton: UIButton!
	@IBOutlet private weak var messageButton: UIButton!
	@IBOutlet private weak var nameTitleLabel: UILabel!
	@IBOutlet private weak var dayWelcomeLabel: UILabel!
	
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
extension BounceNavigationBar {
	
	private func initWithNib() {
		Bundle.main.loadNibNamed(BounceNavigationBar.NIB_NAME, owner: self, options: nil)
		view.translatesAutoresizingMaskIntoConstraints = false
		addSubview(view)
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
	@objc private func userProfileImageTapped() {
		delegate?.userProfileImageDidTapp()
	}
}
