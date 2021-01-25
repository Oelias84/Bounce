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
    
    func commonInit() {
        Bundle.main.loadNibNamed(K.NibName.dishView, owner: self)
        view.fixInView(self)
        
        dishPickerView.delegate = self
        dishPickerView.dataSource = self
        dishNameTextField.inputView = dishPickerView
        dishNameTextField.delegate = self
		dishNameTextField.layer.cornerRadius = 4
		dishNameTextField.layer.borderWidth = 1
		dishNameTextField.layer.borderColor = UIColor.systemBlue.cgColor
        dishPickerView.backgroundColor = .white
        setupToolBar()
    }
    func configureData() {
        amountLabel.text = "x\(dish.amount)"
        dishTypeLabel.text = dish.printDishType
        dishNameTextField.text = dish.getDishName
        checkBoxButton.isSelected = dish.isDishDone
    }
}

extension DishView: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        dishes.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dishes[row].name
    }
    func setupToolBar() {
        let toolBar = UIToolbar()
        let confirm = UIBarButtonItem(title: "אישור", style: .plain, target: self, action: #selector(confirmTapped))
		let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
		let cancel = UIBarButtonItem(title: "ביטול", style: .done, target: self, action: #selector(closeTapped))
		
		toolBar.sizeToFit()
        toolBar.setItems([confirm, spacer, cancel], animated: true)
        toolBar.isUserInteractionEnabled = true
        dishNameTextField.inputAccessoryView = toolBar
    }
    @objc func confirmTapped() {
        dish.setName(name: dishes[dishPickerView.selectedRow(inComponent: 0)].name)
        dishNameTextField.text = dishes[dishPickerView.selectedRow(inComponent: 0)].name
        print(dish.getDishName)
        view.endEditing(true)
        delegate?.didCheck(dish: dish)
    }
	@objc func closeTapped() {
		view.endEditing(true)
	}
}

extension DishView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let dishName = textField.text
        if let arrayIndexForDishName = dishes.firstIndex(where: {$0.name == dishName}) {
            dishPickerView.selectRow(arrayIndexForDishName, inComponent: 0, animated: false)
        } else {
            
        }
    }
}
