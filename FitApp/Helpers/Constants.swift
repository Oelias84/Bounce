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
		static let serverKey = "AAAArNkTRhE:APA91bGVqhqX37ZiH-Q_lARYwTRw-Y8Tii46jrLckItPkilLvNsYkHZ_s5Gc5PiLXHdmFiKr7O0EfzAC6JwZMUpNOlxD9hdnZRVHRjAJ0jEC3wjgLZU5eISfzyoradZ3HQ5s7zelluPM"
        
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
        static let workout = "Workout"
        static let weightProgress = "WeightProgress"
        static let home = "Home"
        static let articles = "Articles"
		static let settings = "Settings"
		static let chat = "Chat"
		static let adminMenu = "Admin"
	}
	
	struct ViewControllerId {
        
		//Login Register
		static let startViewController = "StartViewController"
		static let startNavigationViewController = "StartNavigationViewController"
		//Home
        static let homeViewController = "HomeViewController"
		static let registerViewController = "RegisterViewController"
		static let HomeTabBar = "HomeTabBar"
        //Meal
        static let mealViewController = "MealViewController"
		static let commentViewController = "CommentViewController"
		static let commentsTableViewController = "CommentsTableViewController"
		static let dishesListViewController = "DishesTableViewController"
		//Questionnaire
        static let questionnaireNavigation = "QuestionnaireNavigation"
        static let questionnaireWelcome = "QuestionnaireWelcome"
        static let questionnaireSecond = "QuestionnaireSecond"
        static let questionnaireThird = "QuestionnaireThird"
        static let questionnaireForth = "QuestionnaireForth"
		static let questionnaireForthSecondPart = "QuestionnaireForthSecondPart"
        static let questionnaireFifth = "QuestionnaireFifth"
        static let questionnaireSixth = "QuestionnaireSixth"
        static let questionnaireSeventh = "QuestionnaireSeventh"
		static let questionnaireEighth = "QuestionnaireEighth"
		//Workout
        static let workoutTableViewController = "WorkoutTableViewController"
        static let exercisesTableViewController = "ExercisesTableViewController"
        static let exerciseDetailViewController = "ExerciseDetailViewController"
        //Weight
        static let weightViewController = "WeightViewController"
        //Articles
        static let articlesViewController = "ArticlesViewController"
        static let articleViewController = "ArticleViewController"
		//Settings
		static let SettingsViewController = "SettingsViewController"
		//Chat
		static let ChatViewController = "ChatViewController"
		static let ChatsViewController = "ChatsViewController"
		static let NewChatViewController = "NewChatViewController"
		static let ChatContainerViewController = "ChatContainerViewController"
		//Settings
		static let SettingsOptionsTableViewController = "SettingsOptionsTableViewController"
		//Admin
		static let usersListViewController = "UsersListViewController"
		static let userDetailsViewController = "UserDetailsViewController"
	}
	
	struct NavigationId {
		
		static let homeNavigation = "HomeNavigation"
		static let QuestionnaireNavigation = "QuestionnaireNavigation"
	}
    
    struct SegueId {
        
        static let moveToExerciseViewController = "moveToExerciseViewController"
        static let moveToExerciseDetailViewController = "moveToExerciseDetailViewController"
        //Questionnaire Segue
        static let moveToPersonalDetails = "moveToPersonalDetails"
		static let moveToFatGender = "moveToFatGender"
        static let moveToFatPercentage = "moveToFatPercentage"
        static let moveToActivity = "moveToActivity"
		static let moveToSecondActivity = "moveToSecondActivity"
        static let moveToNutrition = "moveToNutrition"
        static let moveToFitnessLevel = "moveToFitnessLevel"
        static let moveToSumup = "moveToSumup"
		//Settings
		static let moveToSettingsOptions = "moveToSettingsOptions"
		//Admin
		static let moveToUserDetails = "moveToUserDetails"
    }
    
    struct CellId {
        
        static let mealCell = "mealCell"
        static let fanCell = "fanCell"
        static let weightCell = "weightCell"
		static let collapsibleCell = "collapsibleCell"
		static let collapsibleSpreadsheetCell = "collapsibleSpreadsheetCell"
		static let collapsibleHeader = "collapsibleTableViewHeader"
		static let commentCell = "commentCell"
        static let exerciseCell = "exerciseCell"
        static let workoutCell = "workoutCell"
		static let settingsOptionCell = "settingsOptionCell"
		static let notificationCell = "notificationCell"
		static let chatCell = "chatCell"
		static let dishesCell = "dishesCell"
		static let addingCell = "addingCell"
		
		static let settingCell = "settingCell"
		
		static let activityCell = "activityCell"
		static let numberOfMealsCell = "numberOfMealsCell"
		static let mostHungryCell = "mostHungryCell"
		static let fitnessLevelCell = "fitnessLevelCell"
		static let numberOfWorkouts = "numberOfWorkouts"
		static let numberOfWorkoutsExternal = "numberOfWorkoutsExternal"
		static let logoutCell = "logoutCell"
		
		//Admin
		static let adminUserMenuCell = "adminUserMenuCell"
		static let userDetailCell = "userDetailTableViewCell"
    }
	
    struct NibName {
		
        //Cells
		static let SettingsTableViewCell = "SettingsTableViewCell"
		
		static let chatTableViewCell = "ChatTableViewCell"
		static let addingTableViewCell = "AddingTableViewCell"
        static let workoutTableViewCell = "WorkoutTableViewCell"
        static let articleTableViewCell = "ArticleTableViewCell"
		
		static let collapsibleTableViewCell = "CollapsibleTableViewCell"
		static let collapsibleSpreadsheetTableViewCell = "CollapsibleSpreadsheetTableViewCell"

		static let commentTableViewCell = "CommentTableViewCell"
		static let exerciseTableViewCell = "ExerciseTableViewCell"
		static let mealPlanTableViewCell = "MealPlanTableViewCell"
		static let notificationTableViewCell = "NotificationTableViewCell"
		static let questionnaireFatCollectionViewCell = "QuestionnaireFatCollectionViewCell"
		static let collapsibleTableViewHeader = "CollapsibleTableViewHeader"

		static let adminUserMenuTableViewCell = "AdminUserMenuTableViewCell"
		static let userDetailTableViewCell = "UserDetailTableViewCell"

		//Views
		static let dishView = "DishView"
		static let chartView = "ChartView"
		static let moveDishView = "MoveDishView"
		static let changeDateView = "ChangeDateView"
		static let tableViewEmptyView = "TableViewEmptyView"
		static let addWeightAlertView = "AddWeightAlertView"
		static let exerciseCategoryView = "ExerciseCategoryView"
		static let addMealAlertView = "AddMealAlertView"
		static let addMealAlertDishView = "AddMealAlertDishView"
		static let bounceNavigationBarView = "BounceNavigationBarView"
		static let popupAlertView = "PopupAlertView"

    }
	
	struct Units {
		
		static let Kilograms = "ק״ג"
		static let kilometers = "ק״מ"
		static let centimeter = "ס״מ"
		static let steps = "צעדים"
		static let unknown = "לא ידוע"
	}
	
	struct Notifications {
		
		static let alertWaterTitle = "קביעת תזכורת שתיה"
		static let alertWeterMessage = "באיזה שעה תרצי לקבוע תזכורת שתיה?"
		static let alertWeightTitle = "קביעת תזכורת שקילה"
		static let alertWeightMessage = "באיזה שעה תרצי לקבוע תזכורת לשקילה?"
	}
}
