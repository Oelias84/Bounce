//
//  Constants.swift
//  FitApp
//
//  Created by Ofir Elias on 24/11/2020.
//

import Foundation

struct K {
	
	struct User {
		
		static let name = "userName"
		static let id = "userId"
	}
	
	struct StoryboardName {
		
		static let questionnaire = "Questionnaire"
		static let launchScreen = "LaunchScreen"
		static let loginRegister = "LoginRegister"
        static let MealPlan = "MealPlan"
        static let Exercises = "Exercises"
        static let Home = "Home"
	}
	
	struct StoryboardNameId {
        
        //Home
        static let homeViewController = "HomeViewController"
        //Meal
        static let mealViewController = "MeallViewController"
		//Questionnaire
        static let questionnaireWelcome = "QuestionnaireWelcome"
        static let questionnaireSecond = "QuestionnaireSecond"
        static let questionnaireThird = "QuestionnaireThird"
        static let questionnaireForth = "QuestionnaireForth"
        static let questionnaireFifth = "QuestionnaireFifth"
        static let questionnaireSixth = "QuestionnaireSixth"
        static let questionnaireSeventh = "QuestionnaireSeventh"
        //Exercise
        static let exercisesTableViewController = "ExercisesTableViewController"
        static let exerciseViewController = "ExerciseViewController"
	}
    
    struct SegueId {
        
        static let moveToExerciseViewController = "moveToExerciseViewController"
        static let moveToExerciseDetailViewController = "moveToExerciseDetailViewController"
    }
    
    struct CellId {
        
        static let exerciseCell = "exerciseCell"
        static let mealCell = "mealCell"
        static let fanCell = "fanCell"
    }
	
    struct NibName {
        
        static let exerciseTableViewCell = "ExerciseTableViewCell"
        static let mealPlanTableViewCell = "MealPlanTableViewCell"
        static let questionnaireFatCollectionViewCell = "QuestionnaireFatCollectionViewCell"
    }
}
