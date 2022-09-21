//
//  UsersListViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 18/05/2022.
//

import UIKit
import Foundation
import FirebaseAuth

enum UserFilterType {
	
	case allUsers
	case readMassages
	case programActive
	case programExpired
	case programExpiredSoon
	case didNotUpdateWorkout
	case searchBy(name: String)
	case notLoggedFor(days: Int? = 3)
}


class UsersListViewModel {
	
	fileprivate let parentVC: UIViewController!
	fileprivate let adminId = Auth.auth().currentUser!.uid
	fileprivate let googleDatabase =  GoogleDatabaseManager.shared
	fileprivate let googleFirestore = GoogleApiManager.shared
	fileprivate var currentFilter: UserFilterType = .allUsers
	
	fileprivate var didFetchIsExpired = false
	fileprivate var didFetchWasSeenLately = false

	fileprivate var users: [Chat]?
	var filteredUsers: ObservableObject<[Chat]?> = ObservableObject(nil)
	
	init(parentVC: UIViewController) {
		self.parentVC = parentVC
		
		let group = DispatchGroup()
		self.fetchChats() {
			if let users = self.users {
				DispatchQueue.global().async(group: group) {

				for user in users {
					group.enter()
						self.getUserLastSeen(days: 3, userID: user.userId) {
							result in
							switch result {
							case .success(let wasSeenLately):
								if let wasSeenLately {
									user.wasSeenLately = wasSeenLately
								}
							case .failure(let error):
								print(error)
							}
							group.leave()
						}
					}
				}
			}
			group.notify(queue: .main) {
				self.filterUsers(with: self.currentFilter)
			}
		}
	}
	
	//Getters
	var getChatsCount: Int? {
		filteredUsers.value?.count
	}
	public func getChatFor(row: Int) -> Chat {
		filteredUsers.value![row]
	}
	public func filterUsers(with term: UserFilterType) {
		Spinner.shared.stop()
		guard let users = users else { return }
		self.currentFilter = term
		
		let results = users.filter {
			switch term {
			case .readMassages:
				return $0.isLastMessageReadFor == true
			case .didNotUpdateWorkout:
				return true
			case .searchBy(let filteredName):
				let name = $0.displayName?.lowercased() ?? ""
				return name.contains(filteredName.lowercased())
			case .notLoggedFor(_):
				return $0.wasSeenLately == false
			case .programActive:
				return $0.programState == .active || $0.programState == .expireSoon
			case .programExpired:
				return $0.programState == .expire || $0.programState == nil
			case .programExpiredSoon:
				return $0.programState == .expireSoon
			case .allUsers:
				return true
			}
		}
		filteredUsers.value = results.sorted()
	}
	
	var filterItems: [UIAction] {
		[
			UIAction(title: "כל היוזרים", image: nil, handler: { (_) in
				self.filterUsers(with: .allUsers)
			}),
			UIAction(title: "הודעות שנקראו", image: nil, handler: { (_) in
				self.filterUsers(with: .readMassages)
			}),
			UIAction(title: "לא נראו 3 ימים", image: nil, handler: { (_) in
				self.filterUsers(with: .notLoggedFor())
			}),
			UIAction(title: "מנויים פעילים", image: nil, handler: { (_) in
				if self.didFetchIsExpired {
					self.filterUsers(with: .programActive)
				} else {
					Spinner.shared.show(self.parentVC.view)
					
					self.addIsExpired {
						self.filterUsers(with: .programActive)
						self.didFetchIsExpired = true
						Spinner.shared.stop()
					}
				}
			}),
			UIAction(title: "לפני סיום מנוי", image: nil, handler: { (_) in
				if self.didFetchIsExpired {
					self.filterUsers(with: .programExpiredSoon)
				} else {
					Spinner.shared.show(self.parentVC.view)
					
					self.addIsExpired {
						self.filterUsers(with: .programExpiredSoon)
						self.didFetchIsExpired = true
						Spinner.shared.stop()
					}
				}
			}),
			UIAction(title: "מנויים לא פעילים", image: nil, handler: { (_) in
				if self.didFetchIsExpired {
					self.filterUsers(with: .programExpired)
				} else {
					Spinner.shared.show(self.parentVC.view)
					
					self.addIsExpired {
						self.filterUsers(with: .programExpired)
						self.didFetchIsExpired = true
						Spinner.shared.stop()
					}
				}
			})
		]
	}
	var filterMenu: UIMenu {
		UIMenu(title: "מיין לפי:", image: nil, identifier: nil, options: [], children: filterItems)
	}
	
	//Broadcast message
	public func sendBroadcastMessage(text: String) {
		guard let usersChats = filteredUsers.value else { return }
		
		MessagesManager.shared.postBroadcast(text: text, for: usersChats)
	}
	
	fileprivate func fetchChats(completion: @escaping ()->()) {
		googleDatabase.getAllChats(userId: self.adminId) {
			[weak self] chats in
			guard let self = self else { return }
			self.users = chats
			completion()
		}
	}
	
	fileprivate func getUserLastSeen(days: Int, userID: String, completion: @escaping (Result<Bool?, Error>)->()) {
		googleFirestore.getUserLastSeenData(days: days, userID: userID, completion: completion)
	}
	fileprivate func getUserOrderExpirationData(userID: String, completion: @escaping (Result<UserProgramSatet?, Error>)->()) {
		googleFirestore.getUserOrderExpirationData(userID: userID, completion: completion)
	}
	fileprivate func addIsExpired(completion: @escaping ()->()) {
		let group = DispatchGroup()
		
		DispatchQueue.global(qos: .userInteractive).async {
			if let users = self.users {
				for user in users {
					group.enter()
					self.getUserOrderExpirationData(userID: user.userId) {
						result in
						
						switch result {
						case .success(let programState):
							user.programState = programState
						case .failure(let error):
							print(error)
						}
						group.leave()
					}
				}
				group.wait()
				DispatchQueue.main.async {
					completion()
				}
			}
		}
	}
}
