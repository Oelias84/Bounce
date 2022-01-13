//
//  DishView.swift
//  FitApp
//
//  Created by iOS Bthere on 16/12/2020.
//

import UIKit

protocol DishViewDelegate {
    
    func didCheck(dish: Dish)
}

class DishView: UIView {
    
    var dish: Dish! {
        didSet {
            configureData()
        }
    }
    var dishes: [ServerDish]!
    private let dishPickerView = UIPickerView()

    @IBOutlet weak var dishTypeLabel: UILabel!
    @IBOutlet weak var dishNameTextField: UITextField!
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
	
    @IBAction func checkBoxButtonAction(_ sender: UIButton) {
        checkBoxButton.isSelected = !sender.isSelected
        dish.isDishDone.toggle()
        delegate?.didCheck(dish: dish)
    }
}

extension DishView {
	
    @objc func confirmTapped() {
        dish.setName(name: dishes[dishPickerView.selectedRow(inComponent: 0)].name)
        dishNameTextField.text = dishes[dishPickerView.selectedRow(inComponent: 0)].name
		
        view.endEditing(true)
        delegate?.didCheck(dish: dish)
    }
	@objc func closeTapped() {
		view.endEditing(true)
	}
	private func commonInit() {
		Bundle.main.loadNibNamed(K.NibName.dishView, owner: self)
		view.fixInView(self)
		
		dishNameTextField.delegate = self
		dishPickerView.backgroundColor = .white
	}
	private func configureData() {
		amountLabel.text = "x\(dish.amount)"
		dishTypeLabel.text = dish.printDishType
		dishNameTextField.text = dish.getDishName
		dishNameTextField.inputView = UIView(frame: .zero)
		checkBoxButton.isSelected = dish.isDishDone
	}
}

extension DishView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
		let storyboard = UIStoryboard(name: K.StoryboardName.mealPlan, bundle: nil)
		let dishesListVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.dishesListViewController) as DishesTableViewController
		
		dishesListVC.delegate = self
		dishesListVC.originalDish = dish
		dishesListVC.state = .normal
		self.parentViewController?.present(dishesListVC, animated: true)
    }
}

extension DishView: DishesTableViewControllerDelegate {
	
	func didPickDish(name: String?) {
		
		if let name = name {
			dish.setName(name: name)
			dishNameTextField.text = name
			delegate?.didCheck(dish: dish)
		}
		dishNameTextField.endEditing(true)
	}
}
