//
//  HomeViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 28/11/2020.
//

import UIKit

class HomeViewController: UIViewController {
    
    private let carbsShapeLayer = CAShapeLayer()
    private let fatShapeLayer = CAShapeLayer()
    private let proteinShapeLayer = CAShapeLayer()
    
    var cards = 120
    var fat = 300
    var protein = 50

    @IBOutlet weak var progressView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
        
        createCircle(shape: carbsShapeLayer, radius: 100, color: UIColor.red.cgColor)
        createCircle(shape: fatShapeLayer, radius: 70, color: UIColor.blue.cgColor)
        createCircle(shape: proteinShapeLayer, radius: 40, color: UIColor.green.cgColor)
        viewTapped()
    }
}

extension HomeViewController {
    
    func createCircle(shape: CAShapeLayer, radius: CGFloat, color: CGColor){
        let center = CGPoint(x: progressView.frame.size.width / 2, y: progressView.frame.size.height / 2)
        let circularPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi , clockwise: true)
        
        shape.path = circularPath.cgPath
        shape.strokeColor = color
        shape.fillColor = UIColor.clear.cgColor
        shape.lineWidth = 15
        shape.lineCap = .round
        shape.strokeEnd = 0
        
        progressView.layer.addSublayer(shape)
    }
    
    @objc func viewTapped() {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        
        basicAnimation.toValue = 1
        basicAnimation.duration = 1.5
        basicAnimation.fillMode = .forwards
        basicAnimation.isRemovedOnCompletion = false
        
        carbsShapeLayer.add(basicAnimation, forKey: "carbs")
        fatShapeLayer.add(basicAnimation, forKey: "fat")
        proteinShapeLayer.add(basicAnimation, forKey: "protein")
    }
}
