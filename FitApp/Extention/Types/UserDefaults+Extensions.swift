//
//  UserDefaults+Extensions.swift
//  FitApp
//
//  Created by iOS Bthere on 14/01/2021.
//

import Foundation

extension UserDefaults {
    
    static func resetDefaults() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }
}
