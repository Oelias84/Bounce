//
//  FeaturesKeysManager.swift
//  FitApp
//
//  Created by Ofir Elias on 15/11/2023.
//

import Foundation

final class IOSKeysManager {
    
    enum FeaturesKey {
        case neutralMenu
    }
    
    var keys: FeaturesKeyModel?

    static let shared = IOSKeysManager()
    
    private init() {
        fetchFeaturesKeysData { keysData in
            self.keys = keysData
        }
    }
    
    func isFeatureOpen(_ featuresKey: FeaturesKey) -> Bool {
        switch featuresKey {
        case .neutralMenu:
            return keys?.neutralMenu ?? false
        }
    }
    
    private func fetchFeaturesKeysData(completion: @escaping (FeaturesKeyModel)->()) {
        GoogleApiManager.shared.getFeaturesKeys { result in
            switch result {
            case .success(let data):
                completion(data)
            case .failure(let error):
                print("fetchKeysData Error: ", error)
            }
        }
    }
}

struct FeaturesKeyModel: Codable {
    let neutralMenu: Bool
}
struct KeysData: Codable {
    var Keys: FeaturesKeyModel
}
