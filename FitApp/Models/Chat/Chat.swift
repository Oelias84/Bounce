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
	var imagePath: URL?
	var displayName: String?
	var pushTokens: [String]?
	var latestMessage: Message?
	var lastSeenMessageDate: Date?
	var isLastMessageReadFor: Bool {
		guard let lastSeen = self.lastSeenMessageDate, let lastMessage = self.latestMessage?.sentDate else { return false }
		return lastSeen > lastMessage
	}
	var wasSeenLately: Bool = false
	var programState: UserProgramSatet?
	
	init(userId: String, isAdmin: Bool = false, displayName: String? = nil, otherUserUID: String? = nil, latestMessage: Message? = nil, pushTokens: [String]? = nil, lastSeenMessageDate: Date? = nil) {
		
		self.userId = userId
		self.isAdmin = isAdmin
		self.pushTokens = pushTokens
		self.displayName = displayName
		self.latestMessage = latestMessage
		self.lastSeenMessageDate = lastSeenMessageDate
	}
	
	static func == (lhs: Chat, rhs: Chat) -> Bool {
		false
	}
	static func < (lhs: Chat, rhs: Chat) -> Bool {
		
		if let lastSeen = lhs.lastSeenMessageDate, let lastMessage = lhs.latestMessage?.sentDate {
			if lastSeen < lastMessage {
				return true
			} else {
				if let lhsDate = lhs.latestMessage?.sentDate, let rhsDate = rhs.latestMessage?.sentDate {
					return lhsDate > rhsDate
				} else {
					return false
				}
			}
		} else {
			return false
		}
	}
}

struct LatestMessage {
	
	let date: String
	let text: String
	let isRead: Bool
}
