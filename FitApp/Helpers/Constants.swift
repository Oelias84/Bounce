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
        static let mealPlan = "MealPlan"
        static let exercises = "Exercises"
        static let weightProgress = "WeightProgress"
        static let home = "Home"
        static let articles = "Articles"
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
        //Articles
        static let articlesViewController = "ArticlesViewController"
        static let articleViewController = "ArticleViewController"
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
        
        static let mealCell = "mealCell"
        static let fanCell = "fanCell"
        static let weightCell = "weightCell"
        static let articleCell = "articleCell"
        static let exerciseCell = "exerciseCell"
    }
	
    struct NibName {
        
        static let dishView = "DishView"
        static let exerciseTableViewCell = "ExerciseTableViewCell"
        static let mealPlanTableViewCell = "MealPlanTableViewCell"
        static let articleTableViewCell = "ArticleTableViewCell"
        static let questionnaireFatCollectionViewCell = "QuestionnaireFatCollectionViewCell"
    }
	
	struct Units {
		
		static let kilometers = "ק״מ"
		static let centimeter = "ס״מ"
		static let steps = "צעדים"
		static let unknown = "לא ידוע"
	}
}
