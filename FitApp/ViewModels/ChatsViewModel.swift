//
//  MessagesViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 05/02/2021.
//

import Foundation

class ChatsViewModel {
	
	private var chats: [Chat]?
	public var flitteredChats: ObservableObject<[Chat]?> = ObservableObject(nil)
	
	private let imageLoader = ImageLoader()
	private let messagesManager = MessagesManager.shared

	init() {
		messagesManager.chats.bind() {
			chats in
			
			if !chats.isEmpty {
				self.chats = chats.sorted()
				self.flitteredChats.value = self.chats
			}
		}
	}
	
	//Getters
	var getChatsCount: Int? {
		flitteredChats.value?.count
	}
	func getChatFor(row: Int) -> Chat {
		flitteredChats.value![row]
	}
	func getChats(completion: @escaping ()->()) {
		if let chats = messagesManager.getSupportChats() {
			self.chats = chats.sorted()
			self.flitteredChats.value = self.chats
			completion()
		} else {
			messagesManager.fetchSupportChats()
			completion()
		}
	}
	public func filterUsers(with term: String?, completion: ()->()) {
		Spinner.shared.stop()
		guard let term = term else {
			flitteredChats.value = chats
			return
		}
		
		guard let chats = chats else { return }
		
		let results = chats.filter({
			let name = $0.displayName?.lowercased() ?? ""
			return name.hasPrefix(term.lowercased())
		})
		
		flitteredChats.value = results
		completion()
	}
}
