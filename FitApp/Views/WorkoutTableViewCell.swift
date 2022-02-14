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
	var workoutType: workoutType!
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
			if let set = Int(exercise.sets) {
				numberOfSets += set
			}
		}
		
		exerciseLabel.text = "\(numberOfExercise) תרגילים"
		setsLabel.text = "\(numberOfSets) סטים"
		timeLabel.text = workout.time
		workoutTitleLabel.text = workoutType == .home ? "אימון בית \(workoutNumber!)" : "אימון חד״כ \(workoutNumber!)"
        workoutDescriptionLabel.text = workout.name
        selectionStyle = .none
    }
}
