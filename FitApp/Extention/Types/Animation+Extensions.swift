//
//  Animation+Extensions.swift
//  FitApp
//
//  Created by Ofir Elias on 22/05/2023.
//


import UIKit

extension CAPropertyAnimation {
    
    static func scaleAnimation(fromValue: Any?, toValue: Any?) -> CAPropertyAnimation {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = fromValue
        scaleAnimation.toValue = toValue
        scaleAnimation.isRemovedOnCompletion = false
        scaleAnimation.fillMode = CAMediaTimingFillMode.forwards
        scaleAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.030, 1.035, 0.095, 1.055)
        scaleAnimation.duration = 0.5
        return scaleAnimation
    }
    
    static func colorAnimation(fromValue: Any?, toValue: Any?) -> CAPropertyAnimation {
        let colorAnimation = CABasicAnimation(keyPath: "backgroundColor")
        colorAnimation.fromValue = UIColor.clear.cgColor
        colorAnimation.toValue = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.6).cgColor
        colorAnimation.isRemovedOnCompletion = false
        colorAnimation.fillMode = CAMediaTimingFillMode.forwards
        colorAnimation.duration = 0.3
        return colorAnimation
    }
}
