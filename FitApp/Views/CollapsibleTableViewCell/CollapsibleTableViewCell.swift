//
//  ExpendableTableViewCell.swift
//  FitApp
//
//  Created by Ofir Elias on 20/12/2021.
//

import UIKit
import Foundation

class CollapsibleTableViewCell: UITableViewCell {
		
	@IBOutlet weak var cellBackgroundView: UIView!
	@IBOutlet weak var articleTextLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		setupView()
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
	}
	private func setupView() {
		
		selectionStyle = .none
		cellBackgroundView.cellView()
		articleTextLabel.numberOfLines = 0
	}
}
