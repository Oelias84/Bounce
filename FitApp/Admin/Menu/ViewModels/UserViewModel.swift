//
//  UserViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 16/07/2023.
//

import Foundation

class UserViewModel: Comparable {
    
    var chat: Chat
    var shouldBroadcast = false
    var shouldShowBrodcast = false
    
    init(_ chat: Chat) {
        self.chat = chat
    }
    
    var isAdmin: Bool {
        chat.isAdmin
    }
    var userId: String {
        chat.userId
    }
    var userName: String? {
        chat.displayName
    }
    var imagePath: URL? {
        chat.imagePath
    }
    var programExperationDatedisplay: String {
        chat.programExpirationDate?.fullDateFromStringWithDash?.dateStringDisplay ?? ""
    }
    var programState: UserProgramSatet? {
        if let programExperationDate = chat.programExpirationDate,
           let expirationDate = programExperationDate.fullDateFromStringWithDash {
            
            if Date().isLater(than: expirationDate) {
                return .expire
            } else if Date().isLaterThanOrEqual(to: expirationDate.subtract(7.days)) {
                return .expireSoon
            } else {
                return .active
            }
        }
        return nil
    }
    var wasSeenLately: Bool? {
        if let userLastSeen = chat.userLastSeen,
           let userLastSeenDate = userLastSeen.dateFromString {
            return Date().onlyDate.subtract(3.days) <= userLastSeenDate
        }
        return nil
    }
    var didReadLastMessage: Bool {
        guard let lastSeen = chat.lastSeenMessageDate,
              let lastMessage = chat.latestMessage?.sentDate else { return false }
        
        return lastSeen > lastMessage
    }
    var chatViewModel: ChatViewModel {
        ChatViewModel(chat: chat)
    }
    var userDetailsViewModel: UserDetailsViewModel {
        UserDetailsViewModel(userData: chat)
    }
    var latestMessage: Message? {
        get {
            chat.latestMessage
        }
        set {
            chat.latestMessage = newValue
        }
    }
    var lastSeenMessageDate: Date? {
        get {
            chat.lastSeenMessageDate
        }
        set {
            chat.lastSeenMessageDate = newValue
        }
    }
    var pushToken: [String] {
        chat.pushTokens ?? []
    }
    
    var showUnreadComment: Bool {
        guard let currentAdminID = UserProfile.defaults.id else { return false }
        
        // Check if contains comment update
        guard let updateComments = chat.commentLastSeen?.first(where: {$0.state == .update})?.dataList.sorted(), !updateComments.isEmpty else { return false }
        
        // Get the last update
        guard let latestUpdate = updateComments.first else { return false }
        
        // Check if latest comment belongs to current admin
        if latestUpdate.userID != currentAdminID {
        
            // Check if contains comments read
            guard let readComments = chat.commentLastSeen?.first(where: {$0.state == .read})?.dataList.sorted(), !updateComments.isEmpty else { return true }
            
            // Get latest read comment
            guard let currentAdminLatestReadComment = readComments.first(where: {$0.userID == currentAdminID}) else { return true }
            
            // Check the date for latest update is bigger then latest read comment by current admin
            return latestUpdate.dateTime > currentAdminLatestReadComment.dateTime
        } else {
            return false
        }
    }
    
    static func == (lhs: UserViewModel, rhs: UserViewModel) -> Bool {
        false
    }
    static func < (lhs: UserViewModel, rhs: UserViewModel) -> Bool {
        guard let latestMessage = lhs.chat.latestMessage, let latestMessageOther = rhs.chat.latestMessage else { return false }
        return latestMessage.sentDate > latestMessageOther.sentDate
    }
}
