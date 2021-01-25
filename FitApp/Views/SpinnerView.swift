//
//  SpinnerView.swift
//  FitApp
//
//  Created by iOS Bthere on 06/01/2021.
//

import Foundation
import UIKit

fileprivate var aView: UIView?

extension UIViewController {
    
    func showSpinner() {
        aView = UIView(frame: self.view.bounds)
        aView?.backgroundColor = UIColor(white: 1, alpha: 0.2)
        let ai = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        ai.center = aView!.center
        ai.startAnimating()
        aView?.addSubview(ai)
        self.view.addSubview(aView!)
    }
	
    func stopSpinner() {
        aView?.removeFromSuperview()
        aView = nil
    }
}
