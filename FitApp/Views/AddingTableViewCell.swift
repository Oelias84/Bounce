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
	
	@IBOutlet weak var plusView: UIView! {
		didSet {
			plusView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(plusTapped)))
		}
	}
	
	weak var delegate: AddingTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
	override func draw(_ rect: CGRect) {
		setupView()
	}

	private func setupView() {
		plusView.layer.cornerRadius = (plusView.frame.height/2)
	}
	@objc private func plusTapped(_ sender: UIView) {
		delegate?.didTapped()
	}
}
