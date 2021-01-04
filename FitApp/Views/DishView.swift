//
//  DishView.swift
//  FitApp
//
//  Created by iOS Bthere on 16/12/2020.
//

import UIKit

protocol DishViewDelegate {
    func didCheck()
}

class DishView: UIView {
    
    var dish: Dish! {
        didSet {
            configureData()
        }
    }
    
    @IBOutlet weak var dishTypeLabel: UILabel!
    @IBOutlet weak var dishNameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var checkBoxButton: UIButton!
    
    @IBOutlet var view: UIView!
    
    var delegate: DishViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(K.NibName.dishView, owner: self)
        view.fixInView(self)
    }
    
    @IBAction func checkBoxButtonAction(_ sender: UIButton) {
        checkBoxButton.isSelected = !sender.isSelected
        dish.isDishDone.toggle()
        delegate?.didCheck()
    }
    
    func configureData() {
        dishTypeLabel.text = dish.printDishType
        dishNameLabel.text = dish.getDishName
        amountLabel.text = "X\(dish.amount)"
        checkBoxButton.isSelected = dish.isDishDone
    }
}
