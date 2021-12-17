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
	
	@IBOutlet private weak var backButton: UIButton!
	@IBOutlet private weak var messageButton: UIButton!
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
	
	@IBAction func userProfileButtonTapped(_ sender: Any) {
		delegate?.userProfileImageDidTapp()
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
			userProfileButton.setImage(image.circleMasked, for: .normal)
		}
		userProfileButton.imageView?.contentMode = .scaleAspectFit
		userProfileButton.imageEdgeInsets = UIEdgeInsets(top: 37, left: 37, bottom: 37, right: 37)
	}
}
