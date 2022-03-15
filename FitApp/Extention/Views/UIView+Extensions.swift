//
//  UIView+Extensions.swift
//  MyFItApp
//
//  Created by Ofir Elias on 13/11/2020.
//

import UIKit

extension UIView {
	
	@IBInspectable var cornerRadiusV: CGFloat {
		get {
			return layer.cornerRadius
		}
		set {
			layer.cornerRadius = newValue
			layer.masksToBounds = newValue > 0
		}
	}
	
	@IBInspectable var borderWidthV: CGFloat {
		get {
			return layer.borderWidth
		}
		set {
			layer.borderWidth = newValue
		}
	}
	
	@IBInspectable var borderColorV: UIColor? {
		get {
			return UIColor(cgColor: layer.borderColor!)
		}
		set {
			layer.borderColor = newValue?.cgColor
		}
	}
	
	var parentViewController: UIViewController? {
		var parentResponder: UIResponder? = self
		while parentResponder != nil {
			parentResponder = parentResponder!.next
			if parentResponder is UIViewController {
				return parentResponder as? UIViewController
			}
		}
		return nil
	}
	
	func positionIn(view: UIView) -> CGRect {
		if let superview = superview {
			return superview.convert(frame, to: view)
		}
		return frame
	}
	
	func fixInView(_ container: UIView!) -> Void {
		self.translatesAutoresizingMaskIntoConstraints = false;
		self.frame = container.frame;
		container.addSubview(self);
		NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
		NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
		NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
		NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
	}
	func cellView() {
		layer.masksToBounds = false
		layer.shadowColor = UIColor.blackShadow.cgColor
		layer.shadowOpacity = 0.5
		layer.shadowOffset = CGSize(width: 0, height: 3)
		layer.shadowRadius = 2
		layer.cornerRadius = 15
	}
	
	// OUTPUT 1
	func dropShadow(scale: Bool = true) {
		layer.masksToBounds = false
		layer.shadowColor = UIColor.blackShadow.cgColor
		layer.shadowOpacity = 1
		layer.shadowOffset = CGSize(width: 0, height: 3)
		layer.shadowRadius = 4
	}
	// OUTPUT 2
	func buttonShadow(scale: Bool = true) {
		layer.masksToBounds = false
		layer.shadowColor = UIColor.systemBlue.cgColor
		layer.shadowOpacity = 0.15
		layer.shadowOffset = CGSize(width: 0, height: 3)
		layer.shadowRadius = 4
	}
	// OUTPUT 3
	func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
		layer.masksToBounds = false
		layer.shadowColor = color.cgColor
		layer.shadowOpacity = opacity
		layer.shadowOffset = offSet
		layer.shadowRadius = radius
		
		layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
		layer.shouldRasterize = true
		layer.rasterizationScale = scale ? UIScreen.main.scale : 1
	}
	
	//MARK: - Keyboard Listener
	func raiseScreenWhenKeyboardAppears() {
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	func removeKeyboardListener() {
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self)
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self)
	}
	func addScreenTappGesture() {
		addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissView)))
	}
	@objc func keyboardWillShow(notification: NSNotification) {
		if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
			if frame.origin.y == 0 {
				frame.origin.y -= keyboardSize.height
			}
		}
	}
	@objc func keyboardWillHide(notification: NSNotification) {
		if frame.origin.y != 0 {
			frame.origin.y = 0
		}
	}
	@objc func dismissView() {
		endEditing(true)
	}
}

extension UIView {

	func fadeIn(_ duration: TimeInterval? = 0.2, onCompletion: (() -> Void)? = nil) {
		self.alpha = 0
		self.isHidden = false
		UIView.animate(withDuration: duration!,
					   animations: { self.alpha = 1 },
					   completion: { (value: Bool) in
						  if let complete = onCompletion { complete() }
					   }
		)
	}

	func fadeOut(_ duration: TimeInterval? = 0.2, onCompletion: (() -> Void)? = nil) {
		UIView.animate(withDuration: duration!,
					   animations: { self.alpha = 0 },
					   completion: { (value: Bool) in
						   self.isHidden = true
						   if let complete = onCompletion { complete() }
					   }
		)
	}

}
