//
//  GoogleApiManager.swift
//  FitApp
//
//  Created by iOS Bthere on 06/01/2021.
//

import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

struct GoogleApiManager {
    
    let db = Firestore.firestore()
    
    func createDailyMeal(meals: [Meal]) {
        let currentDate = Date().dateStringForDB
        let dailyMeals = DailyMeal(meals: meals)
        do {
            try db.collection("users").document("\(Auth.auth().currentUser!.uid)").collection("daily-meals").document("\(currentDate)").setData(from: dailyMeals)
        } catch {
            print(error)
        }
    }
    func updateMealBy(date: Date, dailyMeal: DailyMeal) {
        do {
            try db.collection("users").document("\(Auth.auth().currentUser!.uid)").collection("daily-meals").document("\(date.dateStringForDB)").setData(from: dailyMeal)
        } catch {
            print(error)
        }
    }
    func getMealFor( _ date: Date, completion: @escaping (Result<[Meal]?, Error>) -> Void) {
        db.collection("users").document("\(Auth.auth().currentUser!.uid)").collection("daily-meals").document("\(date.dateStringForDB)")
            .getDocument(source: .default, completion: { (data, error) in
                if let error = error {
                    print(error)
                } else if let data = data {
                    do {
                        var meals: [Meal]? = nil
                        let m = try data.data(as: DailyMeal.self)
                        meals = m?.meals
                        completion(.success(meals))
                    } catch {
                        print(error)
                        completion(.failure(error))
                    }
                }
            })
    }
    
    
    func getWeights(completion: @escaping (Result<[Weight]?, Error>) -> Void){
        do {
            db.collection("users").document("\(Auth.auth().currentUser!.uid)").getDocument(source: .default, completion: { (data, error) in
                if let error = error {
                    print(error)
                } else if let data = data {
                    do {
                        var weights: [Weight]? = nil
                        let weightData = try data.data(as: Weights.self)
                        weights = weightData?.weights
                        completion(.success(weights))
                    } catch {
                        print(error)
                        completion(.failure(error))
                    }
                }
            })
        }
    }
    func updateWeights(weights: Weights){
        do {
            try db.collection("users").document("\(Auth.auth().currentUser!.uid)").setData(from: weights.self)
        } catch {
            print(error)
        }
    }
}
