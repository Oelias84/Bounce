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
				return $0.isLastMessageReadFor == true && $0.programState != .expire
			case .didNotUpdateWorkout:
				return true
			case .searchBy(let filteredName):
				let name = $0.displayName?.lowercased() ?? ""
				return name.contains(filteredName.lowercased())
			case .notLoggedFor(_):
				return $0.wasSeenLately == false && $0.programState != .expire && $0.programState != nil
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
		let sortedUsers = results.sorted()
		filteredUsers.value = sortedUsers.sorted(by: {
			guard let latestMessage = $0.latestMessage, let latestMessageOther = $1.latestMessage else { return false }
			return latestMessage.sentDate > latestMessageOther.sentDate
		})
	}
	
	// Filter menu
	var filterMenu: UIMenu {
		UIMenu(title: "מיין לפי:", image: nil, identifier: nil, options: [], children: filterItems)
	}
	private var filterItems: [UIAction] {

		return [
			UIAction(title: "כל היוזרים") { _ in
				self.filterUsers(with: .allUsers)
			},
			UIAction(title: "הודעות שנקראו") { _ in
				self.filterUsers(with: .readMassages)
			},
			UIAction(title: "לא נראו 3 ימים", image:  UIImage(systemName: "person.fill.questionmark")) { _ in
				self.filterOrFetch(filter: .notLoggedFor())
			},
			UIAction(title: "מנויים פעילים") { _ in
				self.filterOrFetch(filter: .programActive)
			},
			UIAction(title: "לפני סיום מנוי", image: UIImage(systemName: "clock.badge.exclamationmark")) { _ in
				self.filterOrFetch(filter: .programExpiredSoon)
			},
			UIAction(title: "מנויים לא פעילים") { _ in
				self.filterOrFetch(filter: .programExpired)
			}
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
	fileprivate func filterOrFetch(filter: UserFilterType) {
		if self.didFetchIsExpired {
			self.filterUsers(with: filter)
		} else {
			Spinner.shared.show(self.parentVC.view)
			
			DispatchQueue.global(qos: .userInteractive).async {
				self.messagesManager.addIsExpired {
					self.filterUsers(with: filter)
					self.didFetchIsExpired = true
					Spinner.shared.stop()
				}
			}
		}
	}
}
