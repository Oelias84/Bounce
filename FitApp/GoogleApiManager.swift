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

	func getUserData(userID: String? = nil, completion: @escaping (Result<ServerUserData?, Error>) -> Void) {
		db.collection("users").document(userID ?? Auth.auth().currentUser!.uid).collection("profile-data").document("data").getDocument(source: .default) {
			(data, error) in
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
		}
	}
	func getUserLastSeenData(days: Int, userID: String, completion: @escaping (Result<String?, Error>) -> Void) {
		db.collection("users").document(userID).collection("user-daily-meals").getDocuments(source: .default) {
			(data, error) in
			
            if let error = error {
				print(error)
				completion(.failure(error))
			}
			if let data = data?.documents.last {
                completion(.success(data.documentID))
			} else {
				completion(.success(nil))
			}
		}
	}
	func getUserOrderExpirationData(userID: String, completion: @escaping (Result<String?, Error>) -> Void) {
		db.collection("users").document(userID).collection("profile-data").document("order-data").getDocument(source: .default) {
			(data, error) in
			
            if let error = error {
				print(error)
			}
			if let data = data?.data() {
				guard let transactionDate = data["dateOfTransaction"] as? String,
					  let period = data["period"] as? Int else {
					completion(.failure(ErrorManager.DatabaseError.dataIsEmpty))
					return
				}
                
				if let expirationDate = transactionDate.fullDateFromStringWithDash?.add(period.months) {
                    completion(.success(expirationDate.fullDateStringForDB))
				} else {
					completion(.success(nil))
				}
			} else {
				completion(.success(nil))
			}
		}
	}
		
	//MARK: - Meals
    func getMealFor(userID: String? = nil, _ date: Date, completion: @escaping (Result<DailyMeal?, Error>) -> Void) {
        db.collection("users").document(userID ?? Auth.auth().currentUser!.uid).collection("user-daily-meals").document("\(date.dateStringForDB)")
            .getDocument(source: .default, completion: { (data, error) in
                
                if let error = error {
                    print("getMealFor Error: ", error)
                } else if let data = data {
                    do {
                        var dailyMeal: DailyMeal?
                        dailyMeal = try data.data(as: DailyMeal?.self)
                        completion(.success(dailyMeal))
                    } catch {
                        print("getMealFor Error: ", error)
                        completion(.failure(error))
                    }
                }
            })
    }
	
	//MARK: - Weights
	func getWeights(userUID: String? = nil, completion: @escaping (Result<[Weight]?, Error>) -> Void) {
		do {
			db.collection("users").document(userUID ?? Auth.auth().currentUser!.uid).collection("user-weights").document("weights").getDocument(source: .default, completion: { (data, error) in
				
                if let error = error {
					print(error)
				} else if let data = data {
                    
					do {
                        var weights: [Weight]?
                        let weightData = try data.data(as: Weights?.self)
                        weights = weightData?.weights
                        completion(.success(weights))
                    } catch {
                        print("getWeights Error: ", error)
                        completion(.failure(error))
					}
				}
			})
		}
	}
    
    //MARK: - Program Orders
    func getCurrentOrder(userUID: String? = nil, completion: @escaping (Result<CurentOrderModel, Error>) -> Void) {
        do {
            db.collection("users").document(userUID ?? Auth.auth().currentUser!.uid).collection("profile-data").document("order-data").getDocument(source: .default, completion: { (data, error) in
                
                if let error = error {
                    print(error)
                } else if let data = data {
                    
                    do {
                        let cureentOrder = try data.data(as: CurentOrderModel.self)
                        completion(.success(cureentOrder))
                    } catch {
                        print("getWeights Error: ", error)
                        completion(.failure(error))
                    }
                }
            })
        }
    }
    func getOrder(orderID: String, completion: @escaping (Result<OrderModel, Error>) -> Void) {
        do {
            db.collection("orders-data").document(orderID).getDocument(source: .default, completion: { (data, error) in
                
                if let error = error {
                    print(error)
                } else if let data = data {
                    
                    do {
                        let order = try data.data(as: OrderModel.self)
                        completion(.success(order))
                    } catch {
                        print("getWeights Error: ", error)
                        completion(.failure(error))
                    }
                }
            })
        }
    }

	//MARK: - Comments
	func updateUserAdminComment(userUID: String, comments: UserAdminCommentsData, completion: ((Error?) -> Void)? = nil) {
		do {
			try db.collection("users").document(userUID).collection("user-admin-comments").document("comments").setData(from: comments.self, merge: true, completion: completion)
		} catch {
			print(error)
			completion!(error)
		}
	}
	func getUserAdminComments(userUID: String, completion: @escaping (Result<UserAdminCommentsData?, Error>) -> Void) {
		do {
			db.collection("users").document(userUID).collection("user-admin-comments").document("comments").addSnapshotListener{ documentSnapshot, error in
				guard let data = documentSnapshot else {
					print("Error fetching document: \(error!)")
					completion(.failure(error!))
					return
				}
				
				do {
					let adminUserComment = try data.data(as: UserAdminCommentsData?.self)
					completion(.success(adminUserComment))
				} catch {
					print(error)
					completion(.failure(error))
				}
				print("Current data: \(data)")
			}
		}
	}
    
    //MARK: - ApprovedUsersCheck
    func checkUserApproved(completion: @escaping (Result<Bool, Error>) -> Void) {
        do {
            db.collection("users").document(Auth.auth().currentUser!.uid).collection("profile-data").document("data").getDocument {
                (data, error) in
                
                if let error = error {
                    completion(.failure(error))
                } else if let data = data {
                    do {
                        let decodedData = try data.data(as: PermissionLevel.self)
                        if let permissionLevel = decodedData.permissionLevel, permissionLevel > 0 {
                            UserProfile.defaults.permissionLevel = decodedData.permissionLevel
                            completion(.success(true))
                        } else {
                            completion(.success(false))
                            return
                        }
                    } catch {
                        completion(.failure(ErrorManager.DatabaseError.failedToDecodeData))
                    }
                }
            }
        }
    }
    
    //MARK: - UserData
    func deleteUser(email: String, password: String, completion: @escaping ((Error?) -> Void)) {
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        Auth.auth().currentUser?.reauthenticate(with: credential) {
            data, error in
            
            if error != nil {
                completion(error)
            }
            Auth.auth().currentUser?.delete {
                error in
                
                if error != nil {
                    completion(error)
                }
                completion(nil)
            }
        }
    }
    func updateUserData(userData: ServerUserData) {
        do {
            try db.collection("users").document(Auth.auth().currentUser!.uid).collection("profile-data").document("data").setData(from: userData, merge: true)
        } catch {
            print("updateUserData Error: ", error)
        }
    }
    func addUserOrderData(userOrderData: UserOrderData, completion: ((Error?) -> Void)? = nil) {
        do {
            try db.collection("users").document(Auth.auth().currentUser!.uid).collection("profile-data").document("order-data").setData(from: userOrderData, merge: true, completion: completion)
        } catch {
            print("addUserOrderData Error: ", error)
        }
    }
    func addOrderData(data: OrderData, with orderNumber: String, completion: ((Error?) -> Void)? = nil) {
        do {
            try db.collection("orders-data").document(orderNumber).setData(from: data, completion: completion)
        } catch {
            print("addOrderData Error: ", error)
        }
    }
    func generatOrderId(completion: @escaping (Result<String, Error>) -> Void) {
        
        db.collection("orders-data").getDocuments {
            (data, error) in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let lastId = data.documents.last?.documentID {
                if let orderNumber = lastId.components(separatedBy: "-").last {
                    let newOrderId = Int(orderNumber)! + 1
                    completion(.success("order-\(newOrderId)"))
                } else {
                    completion(.failure(ErrorManager.DatabaseError.failedToDecodeData))
                }
            } else {
                completion(.failure(ErrorManager.DatabaseError.failedToDecodeData))
            }
        }
    }
    func updateAppVersion() {
        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return }
        guard let user = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(user).collection("profile-data").document("data").setData(["currentAppVersion":appVersion], merge: true)
    }
    func getProgramExpirationData(completion: @escaping (Result<String?, Error>) -> Void) {
        guard let user = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(user).collection("profile-data").document("order-data").getDocument(source: .default) {
            (data, error) in
            if let error = error {
                print("getProgramExpirationData Error: ", error)
            }
            
            if let data = data?.data() {
                guard let transactionDate = data["dateOfTransaction"] as? String,
                      let period = data["period"] as? Int else {
                    completion(.failure(ErrorManager.DatabaseError.dataIsEmpty))
                    return
                }
                if let expirationDate = transactionDate.fullDateFromStringWithDash?.add(period.months) {
                    completion(.success(expirationDate.fullDateStringForDB))
                } else {
                    completion(.success(nil))
                }
            } else {
                completion(.success(nil))
            }
        }
    }
    func getUserCaloriesProgressData(userID: String? = nil, completion: @escaping (Result<[CaloriesProgressState]?, Error>) -> Void) {
        db.collection("users").document(userID ?? Auth.auth().currentUser!.uid).collection("user-calories-progress").getDocuments {
            data, error in
            
            var calorieCalculationList = [CaloriesProgressState]()
            
            if let error = error {
                completion(.failure(error))
                return
            } else if let data = data {
                
                for document in data.documents {
                    do {
                        let documentData = try document.data(as: CaloriesProgressState.self)
                        calorieCalculationList.append(documentData)
                    } catch {
                        completion(.failure(error))
                    }
                }
                completion(.success(calorieCalculationList))
            }
        }
    }
    
    //MARK: - Meals
    func createDailyMeal(meals: [Meal], date: Date) {
        guard !meals.isEmpty else { return }
        let currentDate = date.dateStringForDB
        let dailyMeals = DailyMeal(meals: meals)
        
        do {
            try db.collection("users").document(Auth.auth().currentUser!.uid).collection("user-daily-meals").document("\(currentDate)").setData(from: dailyMeals.self)
        } catch {
            print("createDailyMeal Error: ", error)
        }
    }
    func updateMealBy(date: Date, dailyMeal: DailyMeal, completion: @escaping (Error?) -> Void) {
        do {
            try db.collection("users").document(Auth.auth().currentUser!.uid).collection("user-daily-meals").document("\(date.dateStringForDB)").setData(from: dailyMeal.self, completion: completion)
        } catch {
            print("updateMealBy Error: ", error)
        }
    }
    func getAllMeals(completion: @escaping (Result<[DailyMeal]?, Error>) -> Void) {
        db.collection("users").document(Auth.auth().currentUser!.uid).collection("user-daily-meals").getDocuments {
            data, error in
            
            if let error = error {
                print("getAllMeals Error: ", error)
            } else if let data = data {
                do {
                    var dailyMeal: [DailyMeal]? = nil
                    dailyMeal = try data.documents.map { try $0.data(as: DailyMeal.self) }
                    completion(.success(dailyMeal))
                } catch {
                    print("getAllMeals Error: ", error)
                    completion(.failure(error))
                }
            }
        }
    }
    
    //MARK: - Weights
    func updateWeights(weights: [Weight]?, completion: @escaping (Error?) -> ()) {
        guard let weights = weights else { return }
        let weightsModel = Weights(weights: weights)
        
        do {
            try db.collection("users").document(Auth.auth().currentUser!.uid).collection("user-weights").document("weights").setData(from: weightsModel.self, merge: true, completion: completion)
        } catch {
            print("updateWeights Error: ", error)
        }
    }
    func updateWeights(weights: Weights) {
        do {
            try db.collection("users").document(Auth.auth().currentUser!.uid).collection("user-weights").document("weights").setData(from: weights.self)
        } catch {
            print("updateWeights Error: ", error)
        }
    }
    
    //MARK: - User Calories Progress Sate
    func updateCaloriesProgressState(data: CaloriesProgressState) {
        do {
            try db.collection("users").document(Auth.auth().currentUser!.uid).collection("user-calories-progress").document(data.date.dateStringForDB).setData(from: data.self)
        } catch {
            print("updateCaloriesProgressState Error: ", error)
        }
    }
    
    //MARK: - Dishes
    func getDishes(completion: @escaping (Result<[[ServerDish]]?, Error>) -> Void) {
        do {
            db.collection("dishes-data").document("dishes").getDocument { (data, error) in
                if let error = error {
                    print("getDishes Error: ", error)
                } else if let data = data {
                    do {
                        var dishes: [[ServerDish]] = []
                        if let decodedData = try data.data(as: ServerDishes?.self) {
                            dishes = [decodedData.fat, decodedData.carbs, decodedData.protein]
                        }
                        completion(.success(dishes))
                    } catch {
                        print("getDishes Error: ", error)
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
                    print("getArticles Error: ", error)
                } else if let data = data {
                    do {
                        var articles: [[Article]] = []
                        
                        if let decodedData = try data.data(as: ServerArticles?.self) {
                            articles = [decodedData.nutrition, decodedData.exercise, decodedData.recipes, decodedData.other]
                        }
                        completion(.success(articles))
                    } catch {
                        print("getArticles Error: ", error)
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    //MARK: - Motivations
    func getMotivations(completion: @escaping (Result<Motivations?, Error>) -> Void) {
        do {
            guard let userGender = UserProfile.defaults.getGender else { return }
            
            var fileName: String {
                switch userGender {
                case .female:
                    return "sentences"
                case .male:
                    return "man-sentences"
                }
            }
            db.collection("motivation-sentences-data").document(fileName).getDocument { (data, error) in
                if let error = error {
                    print("getMotivations Error: ", error)
                } else if let data = data {
                    do {
                        let decodedData = try data.data(as: Motivations?.self)
                        completion(.success(decodedData))
                    } catch {
                        print("getMotivations Error: ", error)
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    //MARK: - Comments
    func getComments(completion: @escaping (Result<CommentsData?, Error>) -> Void) {
        do {
            db.collection("comment-data").document("newComment").getDocument { (data, error) in
                if let error = error {
                    print(error)
                } else if let data = data {
                    do {
                        let decodedData = try data.data(as: CommentsData?.self)
                        completion(.success(decodedData))
                    } catch {
                        print(error)
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    //MARK: - Preferred Workout
    func removeUserWorkoutData(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        DispatchQueue.global(qos: .userInteractive).async {
            group.enter()
            db.collection("users").document(Auth.auth().currentUser!.uid).collection("user-workout-data").document("preferred-workout").delete() { error in
                group.leave()
            }
            group.enter()
            db.collection("users").document(Auth.auth().currentUser!.uid).collection("user-workout-data").document("workout-state").delete() { error in
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completion()
        }
    }
    
    //MARK: - Workouts
    //Home Workout
    func getWorkouts(forFitnessLevel: Int, completion: @escaping (Result<[Workout], Error>) -> Void) {
        do {
            db.collection("workouts-data").document("workouts").getDocument(source: .default, completion: { (data, error) in
                if let error = error {
                    print(error)
                } else if let data = data {
                    do {
                        var workouts: [Workout] = []
                        if let workoutsData = try data.data(as: Workouts?.self) {
                            
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
                        if let decodedData = try data.data(as: ExerciseData?.self) {
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
    //Gym Workout
    func getGymWorkouts(forFitnessLevel: Int, completion: @escaping (Result<[Workout], Error>) -> Void) {
        do {
            db.collection("workouts-data").document("gym-workouts").getDocument(source: .default, completion: { (data, error) in
                if let error = error {
                    print(error)
                } else if let data = data {
                    do {
                        var workouts: [Workout] = []
                        let workoutsData = try data.data(as: Workouts.self)
                        
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
                        
                    } catch {
                        print(error)
                        completion(.failure(error))
                    }
                }
            })
        }
    }
    func getGymExerciseBy(completion: @escaping (Result<[Exercise], Error>) -> Void) {
        do {
            db.collection("workouts-data").document("gym-exercises").getDocument(source: .default, completion: { (data, error) in
                if let error = error {
                    print(error)
                } else if let data = data {
                    do {
                        let decodedData = try data.data(as: ExerciseData.self)
                        completion(.success(decodedData.exercises))
                        
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
        let group = DispatchGroup()
        
        DispatchQueue.global(qos: .userInteractive).async {
            videoNumber.forEach { video in
                let number = video.split(separator: "/").last
                let pathReference = storage.reference(withPath: "exercise_videos/\(number!).m4v")
                
                
                group.wait()
                group.enter()
                pathReference.downloadURL { url, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    } else {
                        guard let url = url else { return }
                        urls.append(url)
                    }
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                completion(.success(urls))
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

struct DishArray:Codable {
    let protein: [String]
}
