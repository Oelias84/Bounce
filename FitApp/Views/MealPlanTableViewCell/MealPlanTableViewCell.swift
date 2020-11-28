//
//  MealPlanTableViewCell.swift
//  FitApp
//
//  Created by iOS Bthere on 27/11/2020.
//

protocol MealPlanTableViewCellDelegate {
    func detailTapped(cell: IndexPath)
}

import UIKit

class MealPlanTableViewCell: UITableViewCell {
    
    var indexPath: IndexPath!

    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var mealNameLabel: UILabel!
    @IBOutlet weak var mealDescriptionLabel: UILabel!
    @IBOutlet weak var completeMealCheckMarkButton: UIButton!
    @IBOutlet weak var mealDetailStackView: UIView!
    
    @IBOutlet weak var carbsCheckMark: UIButton!
    @IBOutlet weak var proteinCheckMark: UIButton!
    @IBOutlet weak var fatCheckMark: UIButton!
    
    var delegate: MealPlanTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func downButtonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    @IBAction func completeMealCheckMarkAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        carbsCheckMark.isSelected.toggle()
        proteinCheckMark.isSelected.toggle()
        fatCheckMark.isSelected.toggle()
    }
    @IBAction func openDetailsAction(_ sender: UIButton) {
        mealDetailStackView.isHidden.toggle()
        delegate?.detailTapped(cell: indexPath)
    }
    @IBAction func carbsCheckMarkAction(_ sender: UIButton) {
        print("carbsCheckMarkAction")
    }
    @IBAction func proteinCheckMarkAction(_ sender: UIButton) {
        print("proteinCheckMarkAction")
    }
    @IBAction func fatCheckMarkAction(_ sender: UIButton) {
        print("fatCheckMarkAction")
    }
}

extension MealPlanTableViewCell {
    
    func setupView() {
        cellBackgroundView.layer.cornerRadius = 10
        cellBackgroundView.layer.shadowOpacity = 0.18
        cellBackgroundView.layer.shadowColor = UIColor.systemBlue.cgColor
        cellBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 12)
        cellBackgroundView.layer.shadowRadius = 16
    }
}
