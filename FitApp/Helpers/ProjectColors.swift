//
//  ProjectColors.swift
//  FitApp
//
//  Created by Ofir Elias on 08/12/2021.
//

import UIKit
import Foundation

struct ProjectColors {
	
	static func gradientColorView(_ view: UIView) -> CAGradientLayer {
		let gradient = CAGradientLayer()
		let view = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
		
		gradient.frame = view.bounds
		gradient.colors = [UIColor.projectTail.cgColor, UIColor.projectGreen.cgColor, UIColor.projectTurquoise.cgColor]
		view.layer.insertSublayer(gradient, at: 0)
		return gradient
	}
}
