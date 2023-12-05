//
//  NotificationSwitchTableViewCell.swift
//  FitApp
//
//  Created by Ofir Elias on 22/03/2023.
//

import UIKit

protocol NotificationSwitchTableViewCellDelegate {
    func notificationSwitchAction(_ sender: UISwitch)
}

class NotificationSwitchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var notificationTextLabel: UILabel!
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    var delegate: NotificationSwitchTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func notificationSwitchAction(_ sender: UISwitch) {
        sender.isSelected = !sender.isSelected
        delegate?.notificationSwitchAction(sender)
    }
}
