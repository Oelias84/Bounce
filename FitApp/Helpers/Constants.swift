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
        
        struct UserBasicDetails {
			
            static let birthDate = "birthDate"
            static let weight = "weight"
            static let height = "height"
        }
        struct UserFatPercentage {
			
            static let fatPercentage = "fatPercentage"
        }
        
        struct UserActivity {
			
            static let kilometers = "kilometers"
            static let steps = "steps"
        }
        
        struct UserNutrition {
			
            static let mealsPerDay = "mealsPerDay"
            static let mostHungry = "mostHungry"
            static let leastHungry = "leastHungry"
        }
        
        struct UserFitnessLevel {
			
            static let fitnessLevel = "fitnessLevel"
            static let weaklyWorkouts = "weaklyWorkouts"
        }
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
		static let HomeTabBar = "HomeTabBar"
        //Meal
        static let mealViewController = "MealViewController"
		//Questionnaire
        static let questionnaireNavigation = "QuestionnaireNavigation"
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
        
        //Questionnaire Segue
        static let moveToPersonalDetails = "moveToPersonalDetails"
        static let moveToFatPercentage = "moveToFatPercentage"
        static let moveToActivity = "moveToActivity"
        static let moveToNutrition = "moveToNutrition"
        static let moveToFitnessLevel = "moveToFitnessLevel"
        static let moveToSumup = "moveToSumup"
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
	
	struct Units {
		
		static let kilometers = "ק״מ"
		static let centimeter = "ס״מ"
		static let steps = "צעדים"
		static let unknown = "לא ידוע"
	}
}
