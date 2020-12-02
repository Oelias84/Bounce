//
//  ExerciseTableViewCell.swift
//  FitApp
//
//  Created by iOS Bthere on 30/11/2020.
//

protocol ExerciseTableViewCellDelegate {
    func detailButtonTapped(indexPath: IndexPath)
}

import UIKit

class ExerciseTableViewCell: UITableViewCell {
    
    var exerciseData: Exercise! {
        didSet {
            titleLabel.text = exerciseData.name
            descriptionLabel.text = exerciseData.exerciseDescription
        }
    }
    var indexPath: IndexPath!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var cellBackgroundView: UIView!
    
    var delegate: ExerciseTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    @IBAction func detailButtonAction(_ sender: Any) {
        delegate?.detailButtonTapped(indexPath: indexPath)
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
