//
//  UserDetailsViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 25/05/2022.
//

import Foundation

class UserDetailsViewModel {
	
	let userData: Chat
	let googleManager = GoogleApiManager.shared
	var userDetails : ObservableObject<ServerUserData?> = ObservableObject(nil)
	

	init(userData: Chat) {
		self.userData = userData
		fetchUserDetails()
	}
	
	//Getters
	var getUserChat: Chat {
		return userData
	}
}

extension UserDetailsViewModel {
	
	private func fetchUserDetails() {
		DispatchQueue.global(qos: .userInitiated).async {
			self.googleManager.getUserData(userID: self.getUserChat.userId) {
				[weak self] result in
				guard let self = self else { return }
				
				switch result {
				case .success(let data):
					guard let data = data else { return }
					self.userDetails.value = data
				case .failure(let error):
					print("Error:", error.localizedDescription)
				}
			}
		}
	}
}
