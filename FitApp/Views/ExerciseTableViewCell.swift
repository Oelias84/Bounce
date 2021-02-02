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
    
    var exerciseData: WorkoutExercise! {
        didSet {
            setupView()
        }
    }
    var exerciseNumber: Int!
    var indexPath: IndexPath!

    @IBOutlet weak var exerciseTypeView: UIView!
    @IBOutlet weak var exerciseNumberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var repeatsLabel: UILabel!
    @IBOutlet weak var setsLabel: UILabel!
    
    var delegate: ExerciseTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellBackgroundView.cellView()
        commonInit()
    }

    @IBAction func detailButtonAction(_ sender: Any) {
        delegate?.detailButtonTapped(indexPath: indexPath)
    }
    
    private func setupView() {
        
        exerciseNumberLabel.text = "תרגיל #\(exerciseNumber + 1)"
        titleLabel.text = exerciseData.exerciseToPresent?.name
        repeatsLabel.text = exerciseData.repeats
        setsLabel.text = "X" + exerciseData.sets
    }
    
    private func commonInit() {
        let bundle = Bundle(for: type(of: self))
        let typeNib = UINib(nibName: "FeetIndicatorView", bundle: bundle).instantiate(withOwner: self, options: nil).first as! UIView
        exerciseTypeView.layer.cornerRadius = 10
        exerciseTypeView.addSubview(typeNib)
    }
}
