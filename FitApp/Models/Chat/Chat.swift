//
//  Chat.swift
//  FitApp
//
//  Created by Ofir Elias on 09/02/2021.
//

import Foundation

enum UserProgramSatet {
    
    case active
    case expire
    case expireSoon
}

class Chat: Comparable {
    
    var isAdmin: Bool
    var userId: String
    var imagePath: URL?
    var displayName: String?
    var pushTokens: [String]?
    var latestMessage: Message?
    var lastSeenMessageDate: Date?
    var userLastSeen: String?
    var programExpirationDate: String?
    
    init(userId: String,
         isAdmin: Bool = false,
         displayName: String? = nil,
         otherUserUID: String? = nil,
         latestMessage: Message? = nil,
         pushTokens: [String]? = nil,
         lastSeenMessageDate: Date? = nil,
         userLastSeen: String? = nil,
         programExpirationDate: String? = nil) {
        
        self.userId = userId
        self.isAdmin = isAdmin
        self.pushTokens = pushTokens
        self.displayName = displayName
        self.latestMessage = latestMessage
        self.lastSeenMessageDate = lastSeenMessageDate
        self.userLastSeen = userLastSeen
        self.programExpirationDate = programExpirationDate
    }
    
    
    
    static func == (lhs: Chat, rhs: Chat) -> Bool {
        false
    }
    static func < (lhs: Chat, rhs: Chat) -> Bool {
        guard let latestMessage = lhs.latestMessage,
              let latestMessageOther = rhs.latestMessage else { return false }
        
        return latestMessage.sentDate > latestMessageOther.sentDate
    }
}

struct LatestMessage {
    
    let date: String
    let text: String
    let isRead: Bool
}

