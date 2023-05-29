//
//  View+Extesions.swift
//  FitApp
//
//  Created by Ofir Elias on 22/05/2023.
//

import UIKit
import Foundation
import SwiftUI



extension View {

    func showPopup() {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let keyWindow = scene?.windows.filter {$0.isKeyWindow}.first
        
        if var topController = keyWindow?.rootViewController {
            while let presentedVC = topController.presentedViewController {
                topController = presentedVC
            }
            
            let host = UIHostingController(rootView: self)
            
            host.view.backgroundColor = .clear
            host.modalPresentationStyle = .overCurrentContext
            host.view.layer.add(CAPropertyAnimation.scaleAnimation(fromValue: 0, toValue: 1), forKey: "ScaleAnimation")
            
            topController.present(host, animated: false)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                host.view.layer.add(CAPropertyAnimation.colorAnimation(fromValue: UIColor.clear,
                                                                       toValue: UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.3)), forKey: "BackgroundColorAnimation")
            }
        }
    }
    
    func dismissPopup(withAnimation: Bool = true, complition: (()->Void)? = nil) {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let keyWindow = scene?.windows.filter {$0.isKeyWindow}.first
        
        if var topController = keyWindow?.rootViewController {
            while let presentedVC = topController.presentedViewController {
                topController = presentedVC
            }
            
            if withAnimation {
                CATransaction.begin()
                
                CATransaction.setCompletionBlock {
                    topController.dismiss(animated: false, completion: complition)
                }
                
                topController.view.layer.add(CAPropertyAnimation.scaleAnimation(fromValue: 1, toValue: 0), forKey: "ScaleAnimation")
                topController.view.layer.add(CAPropertyAnimation.colorAnimation(fromValue: UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.3),
                                                                                toValue: UIColor.clear), forKey: "BackgroundColorAnimation")
                
                UIView.animate(withDuration: 0.45, delay: 0, options: .curveEaseOut) {
                    topController.view.alpha = 0.0
                }
                CATransaction.commit()
            } else {
                topController.dismiss(animated: false, completion: complition)
            }
        }
    }
}
