//
//  Chat.swift
//  FitApp
//
//  Created by Ofir Elias on 09/02/2021.
//

import Foundation

class Chat {

	var userId: String
	var isAdmin: Bool
	var otherUserPushTokens: [String]?
	var lastSeenMessageDate: Date?
	
	init(userId: String, isAdmin: Bool = false, otherUserPushTokens: [String]? = nil, lastSeenMessageDate: Date? = nil) {
		self.userId = userId
		self.isAdmin = isAdmin
		self.otherUserPushTokens = otherUserPushTokens
		self.lastSeenMessageDate = lastSeenMessageDate
	}
}

struct LatestMessage {
	
	let date: String
	let text: String
	let isRead: Bool
}
