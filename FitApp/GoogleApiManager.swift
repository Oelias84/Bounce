//
//  GoogleApiManager.swift
//  FitApp
//
//  Created by iOS Bthere on 06/01/2021.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift

struct GoogleApiManager {
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
	static let shared = GoogleApiManager()
	
	static func safeEmail(emailAddress: String) -> String {
		var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
		safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
		return safeEmail
	}
	
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
	func createDailyMeal(meals: [Meal], date: Date) {
		guard !meals.isEmpty else { return }
        let currentDate = date.dateStringForDB
		let dailyMeals = DailyMeal(meals: meals)
		
        do {
			try db.collection("users").document("\(Auth.auth().currentUser!.uid)").collection("user-daily-meals").document("\(currentDate)").setData(from: dailyMeals.self)
        } catch {
            print(error)
        }
    }
    func updateMealBy(date: Date, dailyMeal: DailyMeal) {
        do {
			try db.collection("users").document("\(Auth.auth().currentUser!.uid)").collection("user-daily-meals").document("\(date.dateStringForDB)").setData(from: dailyMeal.self)
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
	
	//MARK: - Motivations
	func getMotivations(completion: @escaping (Result<Motivations?, Error>) -> Void) {
		do {
			db.collection("motivation-sentences-data").document("sentences").getDocument { (data, error) in
				if let error = error {
					print(error)
				} else if let data = data {
					do {
						if let decodedData = try data.data(as: Motivations.self) {
							completion(.success(decodedData))
						}
					} catch {
						print(error)
						completion(.failure(error))
					}
				}
			}
		}
	}
	#warning("Change here and in data base")
	//MARK: - Comments
	func getComments(completion: @escaping (Result<newComments?, Error>) -> Void) {
		do {
			db.collection("comment-data").document("newComment").getDocument { (data, error) in
				if let error = error {
					print(error)
				} else if let data = data {
					do {
						if let decodedData = try data.data(as: newComments.self) {
							completion(.success(decodedData))
						}
					} catch {
						print(error)
						completion(.failure(error))
					}
				}
			}
		}
	}
	
    //MARK: - Workouts
    func getWorkouts( forFitnessLevel: Int, completion: @escaping (Result<[Workout], Error>) -> Void) {
        do {
            db.collection("workouts-data").document("workouts").getDocument(source: .default, completion: { (data, error) in
                if let error = error {
                    print(error)
                } else if let data = data {
                    do {
                        var workouts: [Workout] = []
                        if let workoutsData = try data.data(as: Workouts.self) {
                            
                            switch forFitnessLevel {
                            case 1:
                                workouts = workoutsData.beginner
								completion(.success(workouts))
                            case 2:
                                workouts = workoutsData.intermediate
								completion(.success(workouts))
                            case 3:
                                workouts = workoutsData.advance
								completion(.success(workouts))
                            default:
                                break
                            }
                        }
                    } catch {
                        print(error)
                        completion(.failure(error))
                    }
                }
            })
        }
    }
    func getExerciseBy(completion: @escaping (Result<[Exercise], Error>) -> Void) {
        do {
            db.collection("workouts-data").document("exercises").getDocument(source: .default, completion: { (data, error) in
                if let error = error {
                    print(error)
                } else if let data = data {
                    do {
                        if let decodedData = try data.data(as: ExerciseData.self) {
                            completion(.success(decodedData.exercises))
                        }
                    } catch {
                        print(error)
                        completion(.failure(error))
                    }
                }
            })
        }
    }
    func getExerciseVideo(videoNumber: [String], completion: @escaping (Result<[URL], Error>) -> Void) {
		var urls = [URL]()
		videoNumber.forEach { video in
			let number = video.split(separator: "/").last
			let httpsReference = storage.reference(forURL: "https://firebasestorage.googleapis.com/b/gs://my-fit-app-a8595.appspot.com//o/\(number!).m4v")
        
        	httpsReference.downloadURL { url, error in
        	    if let error = error {
        	        print(error)
					completion(.failure(error))
        	    } else {
					guard let url = url else { return }
					urls.append(url)
					if urls.count == videoNumber.count {
						completion(.success(urls))
					}
        	    }
        	}
		}

    }

    func updateDishes() {
        let carb = [
            ServerDish(name: "אורז לבן 75 גרם"),
            ServerDish(name: "אורז בסמטי 70 גרם"),
            ServerDish(name: "בורגול 125 גרם"),
            ServerDish(name: "פסטה 60 גרם"),
            ServerDish(name: "בטטה 130 גרם"),
            ServerDish(name: "כוסמת 110 גרם"),
            ServerDish(name: "קינואה 85 גרם"),
            ServerDish(name: "קוסקוס 90 גרם"),
            ServerDish(name: "פתיתים 60 גרם"),
            ServerDish(name: "לחם לבן\\מלא 1 יחידות"),
            ServerDish(name: "לחם קל 2 יחידות"),
            ServerDish(name: "פיתה רגילה 0.5 יחידות"),
            ServerDish(name: "פיתה קלה 1 יחידות"),
            ServerDish(name: "פריכיות עד 100 קל"),
            ServerDish(name: "עדשים 85 גרם"),
            ServerDish(name: "אפונה 120 גרם"),
            ServerDish(name: "תירס קל שימורים 200 גרם"),
            ServerDish(name: "תירס מתוק שימורים 100 גרם"),
            ServerDish(name: "שעועית לבנה\\אדומה\\שחורה 85 גרם"),
            ServerDish(name: "גרגירי חומוס שימורים 85 גרם"),
            ServerDish(name: "קוואקר 30 גרם"),
            ServerDish(name: "פייבר וואן 45 גרם"),
            ServerDish(name: "קורנפלקס אלופים"),
            ServerDish(name: "ברנפלקס 40 גרם"),
            ServerDish(name: "חלב סויה לייט מ\"ל"),
            ServerDish(name: "חלב 3% 60 מיליטר"),
            ServerDish(name: "פרי בגודל אגרוף 1 יחידות"),
            ServerDish(name: "פירות יער 15 יחידות"),
			  ServerDish(name: "מנגו 15 יחידות"),
			  ServerDish(name: "אננס 15 יחידות"),
			  ServerDish(name: "תותים 15 יחידות"),
            ServerDish(name: "ענבים 10 יחידות"),
            ServerDish(name: "אורז לבן 75 גרם"),
            ServerDish(name: "אורז בסמטי 70 גרם"),
            ServerDish(name: "בורגול 125 גרם"),
            ServerDish(name: "פסטה 60 גרם"),
            ServerDish(name: "תפוח אדמה 140 גרם"),
            ServerDish(name: "בטטה 130 גרם"),
            ServerDish(name: "כוסמת 110 גרם"),
            ServerDish(name: "קינואה 85 גרם"),
			  ServerDish(name: "דגני פיטנס שקדים\\דבש 30 גרם")

        ]
        let protein = [
            ServerDish(name: "גבינה לבנה 5% 3/4 גביע"),
            ServerDish(name: "גבינה לבנה 3% 3/4 גביע"),
            ServerDish(name: "גבינת קוטג 5% 3/4 גביע"),
            ServerDish(name: "גבינת קוטג 3% 3/4 גביע"),
            ServerDish(name: "גבינת קוטג 1% גביע"),
            ServerDish(name: "בולגרית 5% 150 גרם"),
            ServerDish(name: "צפתית 5% 125 גרם"),
            ServerDish(name: "לאבנה 5% 150 גרם"),
            ServerDish(name: "לאבנה עזים 5% 150 גרם"),
            ServerDish(name: "גבינת חמד לייט 5% 100 גרם"),
            ServerDish(name: "גבינה צהובה 9-15% 3 יחידות"),
            ServerDish(name: "משקה יוטבתה פרו דאבל זירו 250 מ\"ל"),
            ServerDish(name: "משקה יופלה גו לייט 250 מ\"ל"),
            ServerDish(name: "מעדן חלבון גביע"),
            ServerDish(name: "מעדן חלבון לייט גביע"),
            ServerDish(name: "טונה בשמן קופסה"),
            ServerDish(name: "טונה במים קופסה"),
            ServerDish(name: "פסטרמה 3% 6 יחידות"),
            ServerDish(name: "פסטרמה 1% 7 יחידות"),
            ServerDish(name: "חזה עוף 100 גרם"),
            ServerDish(name: "בשר בקר סינטה 100 גרם"),
            ServerDish(name: "בשר בקר כתף 100 גרם"),
            ServerDish(name: "בשר בקר שייטל 100 גרם"),
            ServerDish(name: "לברק 100 גרם"),
            ServerDish(name: "דג בורי 100 גרם"),
            ServerDish(name: "גד סול 100 גרם"),
            ServerDish(name: "דג בקלה 100 גרם"),
            ServerDish(name: "דג נילוס 100 גרם"),
            ServerDish(name: "דג אמנון 100 גרם"),
            ServerDish(name: "דג סלמון 100 גרם"),
            ServerDish(name: "סלמון מעושן 100 גרם"),
            ServerDish(name: "ביצים M 2 יחידות"),
            ServerDish(name: "טופו 150 גרם"),
            ServerDish(name: "טופו חומוס 200 גרם"),
            ServerDish(name: "אבקת חלבון סקופ"),
            ServerDish(name: "חטיף חלבון יחידה")
        ]
        let fat = [
            ServerDish(name: "שמן זית\\קוקוס\\רגיל כף"),
            ServerDish(name: "טחינה גולמית כף"),
            ServerDish(name: "טחינה מוכנה 2 כפות"),
            ServerDish(name: "חמאת בוטנים כף שטוחה"),
            ServerDish(name: "1/3 אבוקדו"),
            ServerDish(name: "שוקולד מרירי 70% 5 קוביות"),
            ServerDish(name: "שוקולד מריר 70% 2 קוביות דגולות"),
            ServerDish(name: "שקדים 15 יחידות"),
            ServerDish(name: "אגוזי מלך 6 חצאים"),
            ServerDish(name: "חמאה כף"),
            ServerDish(name: "מיונז כף שטוחה"),
            ServerDish(name: "מיונז לייט 2 כפות"),
            ServerDish(name: "זיתים 15 זיתים קטנים"),
            ServerDish(name: "חומוס מקופסה 2 כפות"),
            ServerDish(name: "במבה 25 גרם שקית")

        ]

        do {
            try db.collection("dishes-data").document("dishes").setData(from: ServerDishes(carbs: carb, fat: fat, protein: protein))
        } catch {
            print(error)
        }
    }
}


struct Workouts: Codable {
     
    let advance: [Workout]
    let beginner: [Workout]
    let intermediate: [Workout]
}

struct ExerciseData: Codable {
    
    let exercises: [Exercise]
    
    enum CodingKeys: String, CodingKey {
        
        case exercises = "exercise-data"
    }
}

struct DishArray:Codable {
    let protein: [String]
}
