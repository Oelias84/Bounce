//
//  UserDetailsViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 25/05/2022.
//

import Foundation

final class UserDetailsViewModel {
    
    let userData: Chat
    let googleManager = GoogleApiManager.shared
    var group: DispatchGroup?
    
    var userDetails: UiKitObservableObject<ServerUserData?> = UiKitObservableObject(nil)
    var comments: UiKitObservableObject<[UserAdminComment]?> = UiKitObservableObject(nil)
    
    init(userData: Chat) {
        self.userData = userData
        group = DispatchGroup()
        group?.enter()
        
        fetchUserDetails {
            self.group?.leave()
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.group?.wait()
            self.group?.enter()
            
            self.getComments() {
                if let group = self.group {
                    group.leave()
                }
            }
        }
        group?.notify(queue: .global()) {
            self.group = nil
        }
    }
}

//Getters
extension UserDetailsViewModel {
    
    var userName: String? {
        userData.displayName
    }
    var getUserId: String {
        return userData.userId
    }
    var getUserChat: Chat {
        return userData
    }
    var getActivityTitle: (String, String) {
        
        if let steps = userDetails.value?.steps {
            return ("רמת פעילות:", "\(steps) צעדים")
        } else if let kilometers = userDetails.value?.kilometer {
            return ("רמת פעילות:",String(format: "%.1f", kilometers) + " ק״מ")
        } else {
            return ("אורך חיים:",self.setupLifeStyleText)
        }
    }
    var getMostHungryTitle: String {
        
        var hungerTitle: String {
            switch userDetails.value?.mostHungry  {
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
    var getFitnessLevelTitle: String {
        
        var fitnessTitle: String {
            switch userDetails.value?.fitnessLevel  {
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
        return fitnessTitle
    }
}

//Functions
extension UserDetailsViewModel {
    
    private func fetchUserDetails(complition: @escaping ()->()) {
        self.googleManager.getUserData(userID: self.getUserChat.userId) {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                guard let data = data else { return }
                self.userDetails.value = data
            case .failure(let error):
                
                print("Error:", error.localizedDescription)
            }
            complition()
        }
    }
    private func getComments(complition: @escaping ()->()) {
        GoogleApiManager.shared.getUserAdminComments(userUID: self.getUserChat.userId) {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                self.comments.value = data?.comments.sorted()
            case .failure(let error):
                print("Error:", error.localizedDescription)
            }
            complition()
        }
    }
    private var setupLifeStyleText: String {
        
        switch userDetails.value?.lifeStyle {
        case 1.2:
            return "אורח חיים יושבני"
        case 1.3:
            return "אורח חיים פעיל מתון"
        case 1.5:
            return "אורח חיים פעיל"
        case 1.6:
            return "אורח חיים פעיל מאוד"
        default:
            return ""
        }
    }
}
