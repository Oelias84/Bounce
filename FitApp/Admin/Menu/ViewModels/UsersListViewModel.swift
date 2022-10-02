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
	fileprivate let messagesManager = MessagesManager.shared

	fileprivate var currentFilter: UserFilterType = .allUsers
	
	fileprivate var didFetchIsExpired = false
	fileprivate var didFetchWasSeenLately = false
	
	fileprivate var users: [Chat]?
	var filteredUsers: ObservableObject<[Chat]?> = ObservableObject(nil)
	
	init(parentVC: UIViewController) {
		self.parentVC = parentVC
		
		DispatchQueue.global(qos: .userInitiated).async {
			self.getChats() {
				self.filterUsers(with: self.currentFilter)
			}
		}
	}
	
	// Getters
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
	
	// Filter menu
	var filterMenu: UIMenu {
		UIMenu(title: "מיין לפי:", image: nil, identifier: nil, options: [], children: filterItems)
	}
	private var filterItems: [UIAction] {
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
					
					DispatchQueue.global(qos: .userInteractive).async {
						self.messagesManager.addIsExpired {
							self.filterUsers(with: .programActive)
							self.didFetchIsExpired = true
							Spinner.shared.stop()
						}
					}
				}
			}),
			UIAction(title: "לפני סיום מנוי", image: nil, handler: { (_) in
				if self.didFetchIsExpired {
					self.filterUsers(with: .programExpiredSoon)
				} else {
					Spinner.shared.show(self.parentVC.view)
					
					DispatchQueue.global(qos: .userInteractive).async {
						self.messagesManager.addIsExpired {
							self.filterUsers(with: .programExpiredSoon)
							self.didFetchIsExpired = true
							Spinner.shared.stop()
						}
					}
				}
			}),
			UIAction(title: "מנויים לא פעילים", image: nil, handler: { (_) in
				if self.didFetchIsExpired {
					self.filterUsers(with: .programExpired)
				} else {
					Spinner.shared.show(self.parentVC.view)
					
					DispatchQueue.global(qos: .userInteractive).async {
						self.messagesManager.addIsExpired {
							self.filterUsers(with: .programExpired)
							self.didFetchIsExpired = true
							Spinner.shared.stop()
						}
					}
				}
			})
		]
	}

	// Broadcast message
	public func sendBroadcastMessage(text: String) {
		guard let usersChats = filteredUsers.value else { return }
		
		MessagesManager.shared.postBroadcast(text: text, for: usersChats)
	}
	
	// Fetch data
	fileprivate func getChats(completion: @escaping ()->()) {
		
		messagesManager.chats.bind() {
			[weak self] chats in
			guard let self = self else { return }
			
			if !chats.isEmpty {
				if var users = self.users {
					chats.forEach { chat in
						if let oldChat = users.first(where: { $0.userId == chat.userId }) {
							oldChat.latestMessage = chat.latestMessage
							oldChat.lastSeenMessageDate = chat.lastSeenMessageDate
							
						} else {
							users.append(chat)
						}
					}
				} else {
					self.users = chats
				}
				completion()
			}
		}
	}
}
