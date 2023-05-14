//
//  SpinnerView.swift
//  FitApp
//
//  Created by iOS Bthere on 06/01/2021.
//

import Foundation
import JGProgressHUD
import UIKit

struct Spinner {
	
	static let shared = Spinner()
	private var hud: JGProgressHUD! = JGProgressHUD()

	func show(_ topVC: UIViewController? = nil) {
		DispatchQueue.main.async {
			hud.backgroundColor = #colorLiteral(red: 0.6394728422, green: 0.659519434, blue: 0.6805263758, alpha: 0.2546477665)
			hud.textLabel.text = "טוען"
						
			topVC?.modalPresentationStyle = .overFullScreen
			
			if topVC == nil {
				let keyWindow = UIApplication.shared.connectedScenes
						.filter({$0.activationState == .foregroundActive})
						.compactMap({$0 as? UIWindowScene})
						.first?.windows
						.filter({$0.isKeyWindow}).first
				
				guard var topViewController = keyWindow?.rootViewController else { return }
				var tempPresentedViewController = topViewController.presentedViewController
				topViewController.modalPresentationStyle = .overFullScreen
				
				while tempPresentedViewController != nil {
					topViewController = tempPresentedViewController!
					tempPresentedViewController = topViewController.presentedViewController
				}
				
				hud.show(in: topViewController.view)
			} else {
				hud.show(in: topVC!.view)
			}
		}
	}
	
	func stop(completion: (()->())? = nil) {
		DispatchQueue.main.async {
			hud.dismiss()
		}
		DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
			completion?()
		}
	}
	
	func present(topVC: UIViewController? = nil) {

	 }
}
