//
//  SettingsViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 23/01/2021.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UITableViewController {
	
	private var optionContentType: SettingsContentType!
	
	@IBOutlet weak var activityLabel: UILabel!
	@IBOutlet weak var mealsPerDayLabel: UILabel!
	@IBOutlet weak var mostHungryLabel: UILabel!
	@IBOutlet weak var numberOfWorkoutsLabel: UILabel!
	@IBOutlet weak var fitnessLevelLabel: UILabel!
	@IBOutlet weak var externalWorkoutLabel: UILabel!
	
	@IBOutlet weak var mealsStepper: UIStepper!
	@IBOutlet weak var workoutStepper: UIStepper!
	@IBOutlet weak var externalWorkoutStepper: UIStepper!

	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == K.SegueId.moveToSettingsOptions {
			let settingsOptionsVC = segue.destination as! SettingsOptionsTableViewController
			settingsOptionsVC.contentType = optionContentType
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		setupLabels()
		setupStepper()
	}
	
	@IBAction func mealStepperAction(_ sender: UIStepper) {
		mealsPerDayLabel.text = "\(Int(sender.value))"
		UserProfile.defaults.mealsPerDay = Int(sender.value)
		UserProfile.updateServer()
	}
	@IBAction func workoutStepperAction(_ sender: UIStepper) {
		numberOfWorkoutsLabel.text = "\(Int(sender.value))"
		UserProfile.defaults.weaklyWorkouts = Int(sender.value)
		UserProfile.updateServer()
	}
	@IBAction func externalWorkoutAction(_ sender: UIStepper) {
		externalWorkoutLabel.text = "\(Int(sender.value))"
		UserProfile.defaults.externalWorkout = Int(sender.value)
		UserProfile.updateServer()
	}
	
	//MARK: - Table view data source
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		switch indexPath.section {
		case 0:
			personalDetailsTappedAt(indexPath.row)
		case 1:
			nutritionDetailsTappedAt(indexPath.row)
		case 2:
			fitnessLevelDetailsTappedAt(indexPath.row)
		case 3:
			systemTappedAt(indexPath.row)
		default:
			break
		}
	}
}

//MARK: - Functions
extension SettingsViewController {
	
	private func setupLabels() {
		let userData = UserProfile.defaults
		
		if let steps = userData.steps {
		   activityLabel.text = "\(steps) צעדים"
		} else if let kilometers = userData.kilometer {
			activityLabel.text = "\(kilometers) ק״מ"
		} else {
			activityLabel.text = UserProfile.getLifeStyleText()
		}
		
		if let meals = userData.mealsPerDay {
			mealsPerDayLabel.text = "\(meals)"
			mealsStepper.value = Double(meals)
		}
		
		var hungerTitle: String {
			switch userData.mostHungry  {
			case 1:
				return "בוקר"
			case 2:
				return "צהריים"
			case 3:
				return "ערב"
			default:
				return "לא ידוע"
			}
		}
		mostHungryLabel.text = hungerTitle
		var fitnessTitle: String {
			switch userData.fitnessLevel  {
			case 1:
				return "מתחיל"
			case 2:
				return "ביניים"
			case 3:
				return "מתקדם"
			default:
				return "שגיאה"
			}
		}
		fitnessLevelLabel.text = fitnessTitle
	}
	private func setupStepper() {
		let userData = UserProfile.defaults
		mealsStepper.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
		workoutStepper.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
		externalWorkoutStepper.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
		
		switch userData.fitnessLevel {
		case 1:
			workoutStepper.minimumValue = 2
			workoutStepper.maximumValue = 2
		case 2:
			workoutStepper.minimumValue = 2
			workoutStepper.maximumValue = 3
		case 3:
			workoutStepper.minimumValue = 3
			workoutStepper.maximumValue = 4
		default:
			break
		}
		if let workouts = userData.weaklyWorkouts {
			self.workoutStepper.value = Double(workouts)
			self.numberOfWorkoutsLabel.text = "\(workouts)"
		}
		if let workouts = userData.externalWorkout {
			self.externalWorkoutStepper.value = Double(workouts)
			self.externalWorkoutLabel.text = "\(workouts)"
		}
	}
	private func sendSupportEmail() {
		let subject = ""
		let messageBody = "<h1>יש לכתוב כאן את ההודעה</h1>"
		let mailVC = MailComposerViewController(recipients: ["Fitappsupport@gmail.com"], subject: subject, messageBody: messageBody, messageBodyIsHtml: true)
		
		present(mailVC, animated: true)
	}
	
	private func systemTappedAt(_ row: Int) {
		switch row {
		case 0:
			optionContentType = .notifications
			performSegue(withIdentifier: K.SegueId.moveToSettingsOptions, sender: self)
		case 1:
			presentLogoutAlert()
		default:
			break
		}
	}
	private func personalDetailsTappedAt(_ row: Int) {
		let storyboard = UIStoryboard(name: K.StoryboardName.questionnaire, bundle: nil)
		let activityLevelVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.questionnaireForth)
			as! QuestionnaireActivityViewController
		
		activityLevelVC.isFromSettings = true
		navigationController?.pushViewController(activityLevelVC, animated: true)
	}
	private func nutritionDetailsTappedAt(_ row: Int) {
		switch row {
		case 1:
			optionContentType = .mostHungry
			performSegue(withIdentifier: K.SegueId.moveToSettingsOptions, sender: self)
		default:
			break
		}
	}
	private func fitnessLevelDetailsTappedAt(_ row: Int) {
		switch row {
		case 0:
			optionContentType = .fitnessLevel
			performSegue(withIdentifier: K.SegueId.moveToSettingsOptions, sender: self)
		default:
			break
		}
	}
}
