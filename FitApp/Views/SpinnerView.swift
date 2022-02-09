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
	private var hud: JGProgressHUD!
	
	init() {
		hud = JGProgressHUD()
	}
	
	func show(_ view: UIView) {
		DispatchQueue.main.async {
			hud.backgroundColor = #colorLiteral(red: 0.6394728422, green: 0.659519434, blue: 0.6805263758, alpha: 0.2546477665)
			hud.textLabel.text = "טוען"
			hud.show(in: view)
		}
	}
	
	func stop() {
		DispatchQueue.main.async {
			hud.dismiss()
		}
	}
}
