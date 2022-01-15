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
	private var presentingVC: UIViewController?
	
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
	required init(text: String, hasTabBar: CGFloat?, presentingVC: UIViewController) {
		super.init(frame: CGRect.zero)
		self.presentingVC = presentingVC
		parentHasTabBar = hasTabBar
		buttonText = text
		commonInit()
		setup()
	}
	
	@IBAction func buttonAction(_ sender: Any) {
		presentAlert(withMessage: "האם ברצונך לבצע פעולה זו?", options: "אישור", "ביטול")
	}
}

extension TableViewEmptyView: PopupAlertViewDelegate {
	
	func okButtonTapped(alertNumber: Int, selectedOption: String?, textFieldValue: String?) {
		self.delegate?.createNewMealButtonTapped()
	}
	func cancelButtonTapped(alertNumber: Int) {
		self.removeFromSuperview()
	}
	func thirdButtonTapped(alertNumber: Int) {
		return
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
	private func presentAlert(withTitle title: String? = nil, withMessage message: String, options: (String)...) {
		guard let window = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window else {
			return
		}
		let storyboard = UIStoryboard(name: "PopupAlertView", bundle: nil)
		let customAlert = storyboard.instantiateViewController(identifier: "PopupAlertView") as! PopupAlertView
		
		customAlert.providesPresentationContextTransitionStyle = true
		customAlert.definesPresentationContext = true
		customAlert.modalPresentationStyle = .overCurrentContext
		customAlert.modalTransitionStyle = .crossDissolve
		
		customAlert.delegate = self
		customAlert.titleText = title
		customAlert.messageText = message
		customAlert.okButtonText = options[0]
		
		switch options.count {
		case 1:
			customAlert.cancelButtonIsHidden = true
		case 2:
			customAlert.cancelButtonText = options[1]
		case 3:
			customAlert.cancelButtonText = options[1]
			customAlert.doNotShowText = options.last
		default:
			break
		}
		
		window.rootViewController?.present(customAlert, animated: true, completion: nil)
	}
}
