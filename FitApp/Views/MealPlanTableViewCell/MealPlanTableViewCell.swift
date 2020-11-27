//
//  MealPlanTableViewCell.swift
//  FitApp
//
//  Created by iOS Bthere on 27/11/2020.
//

import UIKit

class MealPlanTableViewCell: UITableViewCell {

    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var mealNameLabel: UILabel!
    @IBOutlet weak var mealDescriptionLabel: UILabel!
    @IBOutlet weak var completeMealCheckMarkButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    @IBAction func completeMealCheckMarkAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
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
