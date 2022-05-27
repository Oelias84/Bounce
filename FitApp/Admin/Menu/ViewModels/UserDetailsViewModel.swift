//
//  UserDetailsViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 25/05/2022.
//

import Foundation

class UserDetailsViewModel {
	
	let userData: Chat
	
	init(userData: Chat) {
		self.userData = userData
		
	}
	
	var getUserChat: Chat {
		return userData
	}
}
