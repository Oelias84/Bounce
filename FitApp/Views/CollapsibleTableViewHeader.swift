


import UIKit
import Foundation

protocol CollapsibleTableViewHeaderDelegate {
	
	func toggleSection(header: CollapsibleTableViewHeader, section: Int)
}

class CollapsibleTableViewHeader: UITableViewHeaderFooterView {
		
	@IBOutlet weak var cellView: UIView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var arrowImage: UIImageView!
	
	var section: Int = 0
	var delegate: CollapsibleTableViewHeaderDelegate?

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHeader)))
	}
	override func layoutSubviews() {
		super.layoutSubviews()
		
		cellView.cellView()
	}
	
	@objc func tapHeader(gestureRecognizer: UITapGestureRecognizer) {
		guard let cell = gestureRecognizer.view as? CollapsibleTableViewHeader else {
			return
		}
		delegate?.toggleSection(header: self, section: cell.section)
	}
	func setCollapsed(collapsed: Bool) {
		// Animate the arrow rotation (see Extensions.swf)
		arrowImage.transform = CGAffineTransform(rotationAngle: collapsed ? 0.0 : .pi * 0.5)
	}
}
