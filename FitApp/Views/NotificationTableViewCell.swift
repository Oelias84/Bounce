//
//  NotificationTableViewCell.swift
//  FitApp
//
//  Created by Ofir Elias on 09/05/2021.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
	
	var notification: Notification! {
		didSet {
			configureCell()
		}
	}

	@IBOutlet weak var timeLabel: UILabel!
	@IBOutlet weak var notificationTitle: UILabel!
	@IBOutlet weak var notificationImageView: UIImageView!
	
    override func awakeFromNib() {
        super.awakeFromNib()
		
    }
	
	override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
	}
	
	private func configureCell() {
		selectionStyle = .none
		timeLabel.text = Calendar.current.date(from: notification.dateTime)?.timeString
		notificationTitle.text = self.notification.title
		if notification.title == "זמן להישקל" {
			notificationImageView.image = UIImage(named: "ScaleIcon")?.withTintColor(.systemGreen)
		} else {
			notificationImageView.image = UIImage(named: "WaterIcon")
		}
	}
}
