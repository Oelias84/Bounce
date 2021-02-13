//
//  UIImage+Extensions.swift
//  FitApp
//
//  Created by iOS Bthere on 25/11/2020.
//

import UIKit

extension UIImage {
	
	func imageWithSize(_ size:CGSize) -> UIImage {
		var scaledImageRect = CGRect.zero
		
		let aspectWidth:CGFloat = size.width / self.size.width
		let aspectHeight:CGFloat = size.height / self.size.height
		let aspectRatio:CGFloat = min(aspectWidth, aspectHeight)
		
		scaledImageRect.size.width = self.size.width * aspectRatio
		scaledImageRect.size.height = self.size.height * aspectRatio
		scaledImageRect.origin.x = (size.width - scaledImageRect.size.width) / 2.0
		scaledImageRect.origin.y = (size.height - scaledImageRect.size.height) / 2.0
		
		UIGraphicsBeginImageContextWithOptions(size, false, 0)
		
		self.draw(in: scaledImageRect)
		
		let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return scaledImage!
	}
	
	var isPortrait:  Bool    { return size.height > size.width }
	var isLandscape: Bool    { return size.width > size.height }
	var breadth:     CGFloat { return min(size.width, size.height) }
	var breadthSize: CGSize  { return CGSize(width: breadth, height: breadth) }
	var breadthRect: CGRect  { return CGRect(origin: .zero, size: breadthSize) }
	
	var circleMasked: UIImage? {
		UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
		defer { UIGraphicsEndImageContext() }
		
		guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0, y: isPortrait  ? floor((size.height - size.width) / 2) : 0), size: breadthSize)) else { return nil }
		
		UIBezierPath(ovalIn: breadthRect).addClip()
		UIImage(cgImage: cgImage, scale: 1, orientation: imageOrientation).draw(in: breadthRect)
		
		return UIGraphicsGetImageFromCurrentImageContext()
	}
	
	func imageWith(name: String?) -> UIImage? {
		let frame = CGRect(x: 0, y: 0, width: 50, height: 50)
		let nameLabel = UILabel(frame: frame)
		nameLabel.textAlignment = .center
		nameLabel.backgroundColor = .lightGray
		nameLabel.textColor = .white
		nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
		var initials = ""
		if let initialsArray = name?.components(separatedBy: " ") {
			if let firstWord = initialsArray.first {
				if let firstLetter = firstWord.first {
					initials += String(firstLetter).capitalized }
			}
			if initialsArray.count > 1, let lastWord = initialsArray.last {
				if let lastLetter = lastWord.first { initials += String(lastLetter).capitalized
				}
			}
		}
		nameLabel.text = initials
		UIGraphicsBeginImageContext(frame.size)
		let currentContext = UIGraphicsGetCurrentContext()
		nameLabel.layer.render(in: currentContext!)
		return UIGraphicsGetImageFromCurrentImageContext()
	}
}
