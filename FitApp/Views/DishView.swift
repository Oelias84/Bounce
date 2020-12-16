//
//  DishView.swift
//  FitApp
//
//  Created by iOS Bthere on 16/12/2020.
//

import UIKit

class DishView: UIView {

    let kCONTENT_XIB_NAME = "DishView"
    
    @IBOutlet weak var dishTypeLabel: UILabel!
    @IBOutlet weak var dishNameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var checkBoxButton: UIButton!
    
    @IBOutlet var view: UIView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self)
        view.fixInView(self)
    }
    
    @IBAction func checkBoxButtonAction(_ sender: Any) {
        
    }
}
