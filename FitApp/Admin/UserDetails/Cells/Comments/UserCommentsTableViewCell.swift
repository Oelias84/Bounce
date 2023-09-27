//
//  UserCommentsTableViewCell.swift
//  FitApp
//
//  Created by Ofir Elias on 03/07/2022.
//

import UIKit

class UserCommentsTableViewCell: UITableViewCell {
	
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var commentTextLabel: UILabel!
    @IBOutlet weak var isReadIndicatorView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
