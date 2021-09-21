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
			setupCategoryView()
        }
    }
    var exerciseNumber: Int!
    var indexPath: IndexPath!

    @IBOutlet weak var exerciseTypeView: UIView!
    @IBOutlet weak var exerciseNumberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var cellBackgroundView: UIView! {
		didSet {
			cellBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backgroundTapped)))
		}
	}
    @IBOutlet weak var repeatsLabel: UILabel!
    @IBOutlet weak var setsLabel: UILabel!
    
    var delegate: ExerciseTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellBackgroundView.cellView()
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
    
    private func setupCategoryView() {
        let bundle = Bundle(for: type(of: self))
		let exerciseTypeNib = UINib(nibName: K.NibName.exerciseCategoryView, bundle: bundle).instantiate(withOwner: self, options: nil).first as! ExerciseCategoryView
		exerciseTypeNib.type = exerciseData.exerciseToPresent?.type
        exerciseTypeView.layer.cornerRadius = 10
        exerciseTypeView.addSubview(exerciseTypeNib)
    }
	
	@objc private func backgroundTapped() {
		delegate?.detailButtonTapped(indexPath: indexPath)
	}
}
