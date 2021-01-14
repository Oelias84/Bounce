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
    
    //MARK: - UserData
    func updateUserData(userData: ServerUserData){
        do {
            try db.collection("users").document("\(Auth.auth().currentUser!.uid)").collection("profile-data").document("data").setData(from: userData.self)
        } catch {
            print(error)
        }
    }
    func getUserData(completion: @escaping (Result<ServerUserData?, Error>) -> Void){
        db.collection("users").document("\(Auth.auth().currentUser!.uid)").collection("profile-data").document("data")
            .getDocument(source: .default, completion: { (data, error) in
                if let error = error {
                    print(error)
                } else if let data = data {
                    do {
                        var userData: ServerUserData? = nil
                        userData = try data.data(as: ServerUserData.self)
                        completion(.success(userData))
                    } catch {
                        print(error)
                        completion(.failure(error))
                    }
                }
            })
    }
    
    //MARK: - Meals
    func createDailyMeal(meals: [Meal]) {
        let currentDate = Date().dateStringForDB
        let dailyMeals = DailyMeal(meals: meals)
        do {
            try db.collection("users").document("\(Auth.auth().currentUser!.uid)").collection("user-daily-meals").document("\(currentDate)").setData(from: dailyMeals)
        } catch {
            print(error)
        }
    }
    func updateMealBy(date: Date, dailyMeal: DailyMeal) {
        do {
            try db.collection("users").document("\(Auth.auth().currentUser!.uid)").collection("user-daily-meals").document("\(date.dateStringForDB)").setData(from: dailyMeal)
        } catch {
            print(error)
        }
    }
    func getMealFor( _ date: Date, completion: @escaping (Result<DailyMeal?, Error>) -> Void) {
        db.collection("users").document("\(Auth.auth().currentUser!.uid)").collection("user-daily-meals").document("\(date.dateStringForDB)")
            .getDocument(source: .default, completion: { (data, error) in
                if let error = error {
                    print(error)
                } else if let data = data {
                    do {
                        var dailyMeal: DailyMeal? = nil
                        dailyMeal = try data.data(as: DailyMeal.self)
                        completion(.success(dailyMeal))
                    } catch {
                        print(error)
                        completion(.failure(error))
                    }
                }
            })
    }
    
    //MARK: - Weights
    func updateWeights(weights: Weights) {
        do {
            try db.collection("users").document("\(Auth.auth().currentUser!.uid)").collection("user-weights").document("weights").setData(from: weights.self)
        } catch {
            print(error)
        }
    }
    func getWeights(completion: @escaping (Result<[Weight]?, Error>) -> Void) {
        do {
            db.collection("users").document("\(Auth.auth().currentUser!.uid)").collection("user-weights").document("weights").getDocument(source: .default, completion: { (data, error) in
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
    
    //MARK: - Dishes
    func getDishes(completion: @escaping (Result<[[ServerDish]]?, Error>) -> Void) {
        do {
            db.collection("dishes-data").document("dishes").getDocument { (data, error) in
                if let error = error {
                    print(error)
                } else if let data = data {
                    do {
                        var dishes: [[ServerDish]] = []
                        
                        if let decodedData = try data.data(as: ServerDishes.self) {
                            
                            dishes = [decodedData.fat, decodedData.carbs, decodedData.protein]
                        }
                        completion(.success(dishes))
                    } catch {
                        print(error)
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    //MARK: - Articles
    func getArticles(completion: @escaping (Result<[[Article]]?, Error>) -> Void) {
        do {
            db.collection("articles-data").document("articles").getDocument { (data, error) in
                if let error = error {
                    print(error)
                } else if let data = data {
                    do {
                        var articles: [[Article]] = []
                        
                        if let decodedData = try data.data(as: ServerArticles.self) {
                            
                            articles = [decodedData.nutrition, decodedData.exercise, decodedData.recipes, decodedData.other]
                        }
                        completion(.success(articles))
                    } catch {
                        print(error)
                        completion(.failure(error))
                    }
                }
            }
        }
        
    }
}
