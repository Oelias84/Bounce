//
//  CommentTableViewCell.swift
//  FitApp
//
//  Created by Ofir Elias on 08/06/2021.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
	
	var comment: Comment! {
		didSet {
			setupCell()
		}
	}
	
	@IBOutlet weak var titleTextLabel: UILabel!
	@IBOutlet weak var cellBackgroundView: UIView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		setupView()
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
	}
	
	func setupCell() {
		titleTextLabel.text = comment.title
	}
	private func setupView() {
		
		cellBackgroundView.cellView()
		selectionStyle = .none
	}
}
