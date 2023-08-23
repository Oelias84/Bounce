//
//  UserDetailTableViewCell.swift
//  FitApp
//
//  Created by Ofir Elias on 29/05/2022.
//

import UIKit

class UserDetailTableViewCell: UITableViewCell {
	
	@IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
		
		label.text = nil
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
