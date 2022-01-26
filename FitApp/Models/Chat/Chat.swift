//
//  Chat.swift
//  FitApp
//
//  Created by Ofir Elias on 09/02/2021.
//

import Foundation

class Chat: Comparable {
	
	
	var isAdmin: Bool
	var userId: String
	var imagePath: String
	var displayName: String?
	var pushTokens: [String]?

	var latestMessage: Message?
	var lastSeenMessageDate: Date?
	
	init(userId: String, isAdmin: Bool = false, imagePath: String = "", displayName: String? = nil, otherUserUID: String? = nil, latestMessage: Message? = nil, pushTokens: [String]? = nil, lastSeenMessageDate: Date? = nil) {
		
		self.userId = userId
		self.isAdmin = isAdmin
		self.imagePath = imagePath
		self.pushTokens = pushTokens
		self.displayName = displayName
		self.latestMessage = latestMessage
		self.lastSeenMessageDate = lastSeenMessageDate
	}
	
	static func == (lhs: Chat, rhs: Chat) -> Bool {
		false
	}
	static func < (lhs: Chat, rhs: Chat) -> Bool {
		lhs.latestMessage!.sentDate > rhs.latestMessage!.sentDate
	}
}

struct LatestMessage {
	
	let date: String
	let text: String
	let isRead: Bool
}
