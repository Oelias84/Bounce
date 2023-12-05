//
//  SettingsViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 15/05/2023.
//

import Foundation
import FirebaseAuth

enum SettingsMenu: String, CaseIterable {
    
    case activity = "פעילות"
    case nutrition = "תזונה"
    case fitness = "כושר"
    case system = "מערכת"
}

class SettingsViewModel {
    
    var inCameraMode: Bool = false
    private var optionContentType: SettingsContentType!
    private let userGender = UserProfile.defaults.getGender
    private var userData = UserProfile.defaults

    private var tableViewData: [SettingsMenu: [SettingsCell]] = [:]
    
    //MARK: - Getters
    var getContentType: SettingsContentType {
        optionContentType
    }
    var getNumberOfSections: Int {
        SettingsMenu.allCases.count
    }
    func getTitleFor(_ section: Int) -> String {
        SettingsMenu.allCases[section].rawValue
    }
    func getNumberOfRows(in section: Int) -> Int {
        let type = SettingsMenu.allCases[section]
        
        return tableViewData[type]?.count ?? 0
    }
    func getCellViewModelFor(_ indexPath: IndexPath) -> SettingsCell {
        let type = SettingsMenu.allCases[indexPath.section]
        
        return tableViewData[type]![indexPath.row]
    }
    
    func setupTableViewData(completion: ()->Void) {
        tableViewData = [
            .activity: [
                SettingsCell(title: "רמת פעילות", secondaryTitle: getActivityTitle)
            ],
            .nutrition: [
                SettingsCell(title: "מספר ארוחות", stepperValue: setupNumberOfMealsStepper.2, stepperMin: setupNumberOfMealsStepper.0, stepperMax: setupNumberOfMealsStepper.1),
                SettingsCell(title: StaticStringsManager.shared.getGenderString?[21] ?? "", secondaryTitle: getMostHungryTitle)
            ],
            .fitness: [
                SettingsCell(title: "רמת קושי", secondaryTitle: getFitnessLevelTitle),
                SettingsCell(title: "מספר אימונים שבועי", stepperValue: setupNumberOfTrainingsStepper.2, stepperMin: setupNumberOfTrainingsStepper.0, stepperMax: setupNumberOfTrainingsStepper.1),
                SettingsCell(title: "מספר אימונים שבועי חיצוני", stepperValue: setupNumberOfExternalTrainingsStepper.2, stepperMin: setupNumberOfExternalTrainingsStepper.0, stepperMax: setupNumberOfExternalTrainingsStepper.1)
            ],
            .system: [
                SettingsCell(title: "התראות", secondaryTitle: ""),
                SettingsCell(title:  StaticStringsManager.shared.getGenderString?[22] ?? "", secondaryTitle: ""),
                SettingsCell(title:  StaticStringsManager.shared.getGenderString?[40] ?? "", secondaryTitle: "")
            ]
        ]
        if IOSKeysManager.shared.isFeatureOpen(.neutralMenu) {
            tableViewData[.nutrition]?.insert(SettingsCell(title: "סוג תפריט", secondaryTitle: getNutritiousTitle), at: 0)
        }
        completion()
    }
    
    //MARK: - Private Funcs
    private var getNutritiousTitle: String {
        if let naturalMenu = userData.naturalMenu {
            return naturalMenu == true ? StaticStringsManager.shared.getGenderString?[46] ?? "" : StaticStringsManager.shared.getGenderString?[48] ?? ""
        } else {
            UserProfile.defaults.naturalMenu = true
            return StaticStringsManager.shared.getGenderString?[46] ?? ""
        }
    }
    private var getActivityTitle: String {
        if let steps = userData.steps {
            return "\(steps) צעדים"
        } else if let kilometers = userData.kilometer {
            return String(format: "%.1f", kilometers) + " ק״מ"
        } else {
            return UserProfile.getLifeStyleText()
        }
    }
    private var getMostHungryTitle: String {
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
        return hungerTitle
    }
    
    private var getFitnessLevelTitle: String {
        
        var fitnessTitle: String {
            switch userData.fitnessLevel  {
            case 1:
                return StaticStringsManager.shared.getGenderString?[14] ?? ""
            case 2:
                return "ביניים"
            case 3:
                return StaticStringsManager.shared.getGenderString?[17] ?? ""
            default:
                return "שגיאה"
            }
        }
        return fitnessTitle
    }
    private var setupNumberOfMealsStepper: (Int, Int, Double) {
        if let meals = userData.mealsPerDay {
            return (3, 5, Double(meals))
        }
        return (0, 0, 0)
    }
    private var setupNumberOfTrainingsStepper: (Int, Int, Double) {
        var min = 0
        var max = 0
        
        switch userData.fitnessLevel {
        case 1:
            min = 2
            max = 2
        case 2:
            min = 2
            max = 3
        case 3:
            min = 3
            max = 4
        default:
            break
        }
        if let workouts = userData.weaklyWorkouts {
            return (min, max, Double(workouts))
        }
        return (min, max, 0)
    }
    private var setupNumberOfExternalTrainingsStepper: (Int, Int, Double) {
        let min = 0
        let max = 3
        
        if let workouts = userData.externalWorkout {
            return (min, max, Double(workouts))
        }
        return (min, max, 0)
    }
}
