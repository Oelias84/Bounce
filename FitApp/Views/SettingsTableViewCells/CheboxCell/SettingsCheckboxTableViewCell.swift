//
//  SettingsCheckboxTableViewCell.swift
//  FitApp
//
//  Created by Ofir Elias on 20/03/2023.
//

import UIKit

protocol SettingsCheckboxTableViewCellDelegate {
    
    func checkboxButtonAction(_ sender: UIButton)
    func informationButtonAction()
}

class SettingsCheckboxTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellTextLabel: UILabel!
    @IBOutlet weak var checkboxButton: UIButton!
    @IBOutlet weak var informationButton: UIButton!
    
    var delegate: SettingsCheckboxTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func checkboxButtonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.checkboxButtonAction(sender)
    }
    @IBAction func informationButtonAction(_ sender: UIButton) {
        delegate?.informationButtonAction()
    }
}
