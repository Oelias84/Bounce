//
//  TabelViewEmptyView.swift
//  FitApp
//
//  Created by Ofir Elias on 17/04/2021.
//

import UIKit

protocol TableViewEmptyViewDelegate {
	func createNewMealButtonTapped()
}

class TableViewEmptyView: UIView {
	
	private var buttonText: String!
	private var parentHasTabBar: CGFloat?
	
	@IBOutlet var contentView: UIView!
	@IBOutlet weak var button: UIButton!
	
	var delegate: TableViewEmptyViewDelegate?
	
	required override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
		setup()
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
		setup()
	}
	required init(text: String, hasTabBar: CGFloat?) {
		super.init(frame: CGRect.zero)
		parentHasTabBar = hasTabBar
		buttonText = text
		commonInit()
		setup()
	}
	
	@IBAction func buttonAction(_ sender: Any) {
		window?.rootViewController?.presentAlert(withMessage: "האם ברצונך לבצע פעולה זו?", options: "אישור", "ביטול", completion: { [weak self] selection in
			guard let self = self else { return }
			switch selection {
			case 0:
				self.delegate?.createNewMealButtonTapped()
			case 1:
				self.removeFromSuperview()
			default:
				break
			}
		})
	}
}

extension TableViewEmptyView {
	
	private func commonInit() {
		self.alpha = 0
		Bundle.main.loadNibNamed(K.NibName.tableViewEmptyView, owner: self, options: nil)
		addSubview(contentView)
		contentView.frame = CGRect(x: 0, y: 0, width: bounds.size.width,
								   height: bounds.size.height - (parentHasTabBar ?? 0))
		contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		UIView.animate(withDuration: 0.2) {
			self.alpha = 1
		}
	}
	private func setup() {
		button.setTitle(buttonText, for: .normal)
	}
}
