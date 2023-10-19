//
//  ActivityLevelAlertView+ViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 29/05/2023.
//

import SwiftUI

extension ActivityLevelAlertView {
    
    class ViewModel: ObservableObject {
        
        var minSteps: Double = 100
        var maxSteps: Double = 30000
        
        var minKilometers: Double = 0.1
        var maxKilometers: Double = 25.01

        
        enum ViewState {
            case activity
            case lifeStyle
        }
        
        enum ActivityOptions {
            case steps
            case kilometers
        }
        
        enum LifeStyleOptions: String, CaseIterable {
            case sitting = "אורח חיים יושבני"
            case semiActive = "אורח חיים פעיל מתון"
            case active = "אורח חיים פעיל"
            case veryActive = "אורח חיים פעיל מאוד"
        }
        
        private let userData = UserProfile.defaults
        
        @Published var isKilometeresChecked: Bool
        @Published var isStepsChecked: Bool
        
        @Published var kilometersValue: Double = 0 {
            didSet {
                if kilometersValue >= 0.1 {
                    resetSteps()
                    resetLifeStyle()
                    isKilometeresChecked = true
                }
            }
        }
        @Published var stepsValue: Double = 0 {
            didSet {
                if stepsValue >= 100 {
                    resetKilometers()
                    resetLifeStyle()
                    isStepsChecked = true
                }
            }
        }
        
        @Published var unownButtonText: String = "לא ידוע"
        @Published var selectedOption: [Bool] = [false, false, false, false]
        
        @Published var viewType: ViewState = .activity {
            didSet {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                    self.changeUnownButtonText()
                }
            }
        }
        
        init() {
            if let steps = userData.steps {
                stepsValue = Double(steps)
                isStepsChecked = true
                viewType = .activity
            } else {
                isStepsChecked = false
            }
            
            if let kilometers = userData.kilometer {
                kilometersValue = Double(kilometers)
                isKilometeresChecked = true
                viewType = .activity
            } else {
                isKilometeresChecked = false
            }
            if let activityLifeStyle = userData.lifeStyle {
                selectedOption[getLifeIndexSelection(for: activityLifeStyle)] = true
                viewType = .lifeStyle
            }
        }
        
        func confirmeChanges(complition: (Bool, ActivityOptions?)->Void) {
            if let selectionOptionIndex = selectedOption.firstIndex(of: true) {
                UserProfile.defaults.lifeStyle = getLifeStyle(for: selectionOptionIndex)
                UserProfile.defaults.steps = nil
                UserProfile.defaults.kilometer = nil
                complition(true, nil)
            } else {
                if isStepsChecked {
                    if stepsValue < 100 {
                        complition(false, .steps)
                    } else {
                        UserProfile.defaults.steps = Int(stepsValue)
                        UserProfile.defaults.kilometer = nil
                        UserProfile.defaults.lifeStyle = nil
                        complition(true, nil)
                    }
                } else if isKilometeresChecked {
                    if kilometersValue < 0.1 {
                        complition(false, .kilometers)
                    } else {
                        UserProfile.defaults.kilometer = kilometersValue
                        UserProfile.defaults.steps = nil
                        UserProfile.defaults.lifeStyle = nil
                        complition(true, nil)
                    }
                } else {
                    complition(false, nil)
                }
            }
        }
        func toggleBooleanArray(excluding index: Int) {
            //Reset Steps and Kilometers Selection
            resetKilometers()
            resetSteps()
            
            for i in 0..<selectedOption.count {
                if i != index {
                    selectedOption[i] = false
                }
            }
        }
        func toggleActivity(for type: ActivityOptions) {
            //Reset lifeStyle Selection
            resetLifeStyle()
            
            switch type {
            case .steps:
                resetKilometers()
            case .kilometers:
                resetSteps()
            }
        }
        func getOptionTextFor(_ lifeStile: LifeStyleOptions) -> String {
            switch lifeStile {
            case .sitting:
                return StaticStringsManager.shared.getGenderString?[8] ?? ""
            case .semiActive:
                return StaticStringsManager.shared.getGenderString?[9] ?? ""
            case .active:
                return StaticStringsManager.shared.getGenderString?[10] ?? ""
            case .veryActive:
                return StaticStringsManager.shared.getGenderString?[11] ?? ""
            }
        }
        
        private func changeUnownButtonText() {
            switch viewType {
            case .activity:
                unownButtonText = "לא ידוע"
            case .lifeStyle:
                unownButtonText = "חזרה"
            }
        }
        private func resetLifeStyle() {
            for i in 0..<selectedOption.count {
                selectedOption[i] = false
            }
        }
        private func resetKilometers() {
            isKilometeresChecked = false
            kilometersValue = 0
        }
        private func resetSteps() {
            isStepsChecked = false
            stepsValue = 0
        }
        private func getLifeStyle(for lifestyle: Int) -> Double {
            switch lifestyle {
            case 0:
                return 1.2
            case 1:
                return 1.3
            case 2:
                return 1.5
            case 3:
                return 1.6
            default:
                return 0.0
            }
        }
        private func getLifeIndexSelection(for lifestyle: Double) -> Int {
            switch lifestyle {
            case 1.2:
                return 0
            case 1.3:
                return 1
            case 1.5:
                return 2
            case 1.6:
                return 3
            default:
                return 0
            }
        }
    }
}
