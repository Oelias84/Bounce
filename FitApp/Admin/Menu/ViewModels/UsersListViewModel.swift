//
//  UsersListViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 18/05/2022.
//

import Foundation
import FirebaseAuth


class UsersListViewModel {
	
	private let userId = Auth.auth().currentUser!.uid
	private let googleDatabase =  GoogleDatabaseManager.shared
	
	private var users: [Chat]? {
		didSet {
			self.filteredUsers.value = users
		}
	}
	var filteredUsers : ObservableObject<[Chat]?> = ObservableObject(nil)
	
	init() {
		fetchChats()
	}
	
	
	//Getters
	var getChatsCount: Int? {
		filteredUsers.value?.count
	}
	public func getChatFor(row: Int) -> Chat {
		filteredUsers.value![row]
	}
	public func filterUsers(with term: String?, completion: ()->()) {
		Spinner.shared.stop()
		
		guard let term = term else {
			filteredUsers.value = users
			return
		}
		
		guard let users = users else { return }
		
		let results = users.filter {
			let name = $0.displayName?.lowercased() ?? ""
			return name.hasPrefix(term.lowercased())
		}
		
		filteredUsers.value = results
		completion()
	}
	
	private func fetchChats() {
		
		self.googleDatabase.getAllChats(userId: userId) {
			[weak self] chats in
			guard let self = self else { return }
			
			self.users = chats
		}
	}
}
