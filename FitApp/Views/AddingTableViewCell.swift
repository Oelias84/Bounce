//
//  AddingTableViewCell.swift
//  FitApp
//
//  Created by Ofir Elias on 09/06/2021.
//

import UIKit

protocol AddingTableViewCellDelegate: AnyObject {
	
	func didTapped()
}

class AddingTableViewCell: UITableViewCell {
	
	@IBOutlet weak var plusButton: UIButton!
	
	weak var delegate: AddingTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
	@IBAction func plusButtonTapped(_ sender: Any) {
		delegate?.didTapped()
	}
}
