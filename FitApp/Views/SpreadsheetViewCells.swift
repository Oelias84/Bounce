//
//  SpreadsheetView.swift
//  FitApp
//
//  Created by Ofir Elias on 13/01/2022.
//

import UIKit
import SpreadsheetView

class HeaderCell: Cell {
	
	let label = UILabel()
	let sortArrow = UILabel()

	override var frame: CGRect {
		didSet {
			label.frame = bounds.insetBy(dx: 4, dy: 2)
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)

		label.frame = bounds
		label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		label.textAlignment = .center
		label.numberOfLines = 2
		contentView.addSubview(label)

		sortArrow.text = ""
		label.font = UIFont(name: "Assistant-SemiBold", size: 16)!
		label.textColor = .projectLightGreen
		sortArrow.textAlignment = .center
		contentView.addSubview(sortArrow)
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}

class TextCell: Cell {
	
	let label = UILabel()

	override var frame: CGRect {
		didSet {
			label.frame = bounds.insetBy(dx: 4, dy: 2)
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		
		label.frame = bounds
		label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		label.font = UIFont(name: "Assistant-Regular", size: 12)!
		label.textAlignment = .center
		label.numberOfLines = 2

		contentView.addSubview(label)
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}
