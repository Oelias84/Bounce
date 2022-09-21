//
//  MessagesViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 05/02/2021.
//

import Foundation

class ChatsViewModel {
	
	private var chats: [Chat]?
	private var flitteredChats: [Chat]?
	
	private let imageLoader = ImageLoader()
	private let messagesManager = MessagesManager.shared

	var chatsViewModelBinder: (() -> ()) = {}

	init() {
		messagesManager.bindMessageManager = {
			self.chats = self.messagesManager.getSupportChats()?.sorted()
			self.flitteredChats = self.chats
			self.chatsViewModelBinder()
		}
	}
	
	//Getters
	var getChatsCount: Int? {
		flitteredChats?.count
	}
	func getChatFor(row: Int) -> Chat {
		flitteredChats![row]
	}
	func getChats(completion: @escaping ()->()) {
		if let chats = messagesManager.getSupportChats() {
			self.chats = chats.sorted()
			self.flitteredChats = self.chats
			completion()
		} else {
			messagesManager.fetchSupportChats()
			completion()
		}
	}
	public func filterUsers(with term: String?, completion: ()->()) {
		Spinner.shared.stop()
		guard let term = term else {
			flitteredChats = chats
			return
		}
		
		guard let chats = chats else { return }
		
		let results = chats.filter({
			let name = $0.displayName?.lowercased() ?? ""
			return name.hasPrefix(term.lowercased())
		})
		
		flitteredChats = results
		completion()
	}
}
