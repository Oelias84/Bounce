//
//  ExerciseTableViewCell.swift
//  FitApp
//
//  Created by iOS Bthere on 30/11/2020.
//

import UIKit

class ExerciseTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var cellBackgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func DetailButtonAction(_ sender: Any) {
        
    }
}

extension ExerciseTableViewCell {
    
    func setupView() {
        cellBackgroundView.layer.cornerRadius = 10
        cellBackgroundView.layer.shadowOpacity = 0.18
        cellBackgroundView.layer.shadowColor = UIColor.systemBlue.cgColor
        cellBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 12)
        cellBackgroundView.layer.shadowRadius = 16
    }
}
