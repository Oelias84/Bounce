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
				if error == DatabaseError.noFetch {
					self.isNewChat = true
					self.chats = [self.addSupportUser()]
				} else {
					self.bindChatsViewModelToController()
				}
			}
		}
	}
	private func addSupportUser() -> Chat {
		let name = "דברי אלינו"
		let otherUserEmail = "support-mail-com"
		let userEmail = UserProfile.defaults.email!.safeEmail
		let chatId = "\(userEmail)\(otherUserEmail)\(Date().dateStringForDB)"
		
		let latestMessage = LatestMessage (date: Date().dateStringForDB,
										   text: "כיתבי לנו כאן ואנו מבטיחים לחזור אליך בהקדם האפשרי",
										   isRead: false)

		return Chat(id: chatId, name: name, otherUserEmail: otherUserEmail, latestMessage: latestMessage)
	}
}
