//
//  ChatTableViewCell.swift
//  FitApp
//
//  Created by Ofir Elias on 09/02/2021.
//

import UIKit
import SDWebImage

class ChatTableViewCell: UITableViewCell {
	
	var chat: Chat! {
		didSet {
			setupCell()
		}
	}
	
	@IBOutlet weak var userImageView: UIImageView!
	@IBOutlet weak var userNameLabel: UILabel!
	@IBOutlet weak var usrMessageLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	func setupCell() {
		userNameLabel.text = chat.name
		usrMessageLabel.text = chat.latestMessage.text
		
		let path = "\(chat.otherUserEmail)_profile_picture.jpeg"
		
		GoogleStorageManager.shared.downloadImageURL(from: .profileImage, path: path) { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let url):
				DispatchQueue.main.async {
					self.userImageView.sd_setImage(with: url)
				}
			case .failure(let error):
				DispatchQueue.main.async {
					self.userImageView.image = UIImage().imageWith(name: self.chat.name)
				}
				print("fail to get image url", error)
			}
		}
	}
}
