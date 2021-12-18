//
//  WorkoutTabelViewCell.swift
//  FitApp
//
//  Created by iOS Bthere on 19/01/2021.
//

import UIKit

class WorkoutTableViewCell: UITableViewCell {
    
    var workout: Workout! {
        didSet {
            setupData()
        }
    }
    var workoutNumber: Int!
    
    @IBOutlet weak var workoutTitleLabel: UILabel!
    @IBOutlet weak var workoutDescriptionLabel: UILabel!
    @IBOutlet weak var workoutBackgroundCell: UIView!
    
	@IBOutlet weak var exerciseLabel: UILabel!
	@IBOutlet weak var setsLabel: UILabel!
	@IBOutlet weak var timeLabel: UILabel!

	override func awakeFromNib() {
        super.awakeFromNib()
        
        workoutBackgroundCell.cellView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setupData() {
        
		let numberOfExercise = workout.exercises.count
		var numberOfSets = 0

		workout.exercises.forEach {
			exercise in
			numberOfSets += exercise.sets.count
		}
		
		exerciseLabel.text = "\(numberOfExercise) תרגילים"
		setsLabel.text = "\(numberOfSets * numberOfExercise) סטים"
		
        workoutTitleLabel.text = "אימון #\(workoutNumber!)"
        workoutDescriptionLabel.text = workout.name
        selectionStyle = .none
    }
}
