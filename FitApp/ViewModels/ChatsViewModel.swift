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
	
	private func startListeningForChats() {
		guard let email = UserProfile.defaults.email?.safeEmail else { return }
		
		GoogleDatabaseManager.shared.getAllChats(for: email) { [weak self] result in
			guard let self = self else { return }
			
			switch result {
			case .success(let chats):
				guard !chats.isEmpty else { return }
				self.chats = chats
			case .failure(let error):
				self.bindChatsViewModelToController()
				print(error)
			}
		}
	}
}
