//
//  MessagesViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 05/02/2021.
//

import Foundation

class ChatsViewModel: NSObject {
	
	var chats: [Chat]? {
		didSet {
			self.bindChatsViewModelToController()
		}
	}
	var isNewChat = false
	
	var bindChatsViewModelToController : (() -> ()) = {}

	override init() {
		super.init()
		startListeningForChats()
	}
	
	var getChatsCount: Int? {
		guard chats != nil else {
			return nil
		}
		return self.chats?.count
	}
	func getChatFor(row: Int) -> Chat {
		return self.chats![row]
	}
	public func updateChatState(chat: Chat) {
		GoogleDatabaseManager.shared.updateChat(chat: chat) { result in
			
			switch result {
			case .success(_):
				print("Chat was updated")
			case .failure(_):
				print("Chat isRead did not update")
			}
		}
	}
	
	private func startListeningForChats() {
		guard let email = UserProfile.defaults.email?.safeEmail else { return }
		
		GoogleDatabaseManager.shared.getAllChats(for: email) { [weak self] result in
			guard let self = self else { return }
			
			switch result {
			case .success(let chats):
				guard !chats.isEmpty else {
					return
				}
				self.isNewChat = false
				self.chats = chats
			case .failure(let error):
				if error == ErrorManager.DatabaseError.noFetch {
					self.isNewChat = true
					self.addSupportUser { chat in
						if let chat = chat {
							self.chats = [chat]
						} else {
							self.bindChatsViewModelToController()
						}
					}
				} else {
					self.bindChatsViewModelToController()
				}
			}
		}
	}
	private func addSupportUser(completion: @escaping (Chat?) -> Void) {
		let database = GoogleDatabaseManager.shared
		var chat: Chat?
		
		database.getChatUsers { result in
			switch result {
			case .success(let users):
				
				for user in users {
					if user.email == "support-mail-com" {
						
						let userEmail = UserProfile.defaults.email!.safeEmail
						
						let name = "דברי אלינו"
						let otherUserEmail = user.email
						let tokens = user.tokens
						let chatId = "\(userEmail)_\(otherUserEmail)_\(Date().dateStringForDB)"
						let latestMessage = LatestMessage (date: Date().dateStringForDB,
														   text: "כיתבי לנו כאן ואנו מבטיחים לחזור אליך בהקדם האפשרי",
														   isRead: false)
						
						chat = Chat(id: chatId, name: name, otherUserEmail: otherUserEmail, otherUserTokens: tokens, latestMessage: latestMessage)
						completion(chat)
					}
				}
			case .failure(let error):
				print(error.localizedDescription)
				completion(chat)
			}
		}
	}
}
