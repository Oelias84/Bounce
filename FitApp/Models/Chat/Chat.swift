//
//  Chat.swift
//  FitApp
//
//  Created by Ofir Elias on 09/02/2021.
//

import Foundation

struct Chat {
	
	let id: String
	let name: String
	let otherUserEmail: String
	let otherUserTokens: [String]?
	let latestMessage: LatestMessage
}

struct LatestMessage {
	
	let date: String
	let text: String
	let isRead: Bool
}
