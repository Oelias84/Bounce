//
//  ChatViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 23/01/2022.
//

import Foundation
import MessageKit
import FirebaseAuth

class ChatViewModel {
	
	private var chat: Chat?
	private let messagesManager = MessagesManager.shared
	
	var messages: UiKitObservableObject<[Message]> = UiKitObservableObject([])
		
	required init(chat: Chat?) {
		
		DispatchQueue.global(qos: .userInitiated).async {
			if let chat = chat {
				self.chat = chat
				self.messagesManager.numberOfMessages = 10
				
				self.listenToMessages()
				self.updateLastSeenDate()
			} else {
				if let chat = self.messagesManager.getUserChat() {
					self.chat = chat
					self.listenToMessages()
				} else {
					self.messagesManager.chats.bind() {
						chats in

						if !chats.isEmpty {
							self.chat = self.messagesManager.getUserChat()
							self.listenToMessages()
						}
					}
				}
			}
		}
	}
	
	//getters
	var getChatUserId: String {
		chat?.userId ?? ""
	}
	var getOtherUserToken: String {
		chat?.pushTokens?.first ?? ""
	}
	var getDisplayName: String? {
		chat?.displayName
	}
	var messagesCount: Int {
		messages.value.count
	}
	var getLastMessage: Message? {
		messages.value.last
	}
	func getMessageAt(_ indexPath: IndexPath) -> Message {
        messages.value[indexPath.section]
	}
	
	var getSelfSender: Sender? {
		guard let senderId = Auth.auth().currentUser?.uid,
			  let name = UserProfile.defaults.name else {
				  return nil
			  }
		return Sender(photoURL: "", senderId: senderId, displayName: name)
	}
	
	public func listenToMessages() {
		guard let chat = chat else {
			return
		}
		
		messagesManager.fetchMessagesFor(chat) {
			[weak self] messages in
			guard let self = self, let messages = messages else {
				return
			}
			self.messages.value = messages.sorted()
		}
	}
	public func updateLastSeenDate() {
		guard let chat = chat else { return }
        messagesManager.googleManager.updateLastSeenMessageDate(userID: chat.userId, isAdmin: chat.isAdmin)
	}
	public func getMediaUrlFor(_ urlString: String, completion: @escaping (URL?) -> ()) {
		messagesManager.downloadMediaURL(urlString: urlString, completion: completion)
	}
	public func sendMessage(messageKind: MessageKind, completion: @escaping (Error?) -> ()) {
		guard let chat = chat else { return }
		
		switch messageKind {
		case .text(let string):
            messagesManager.sendTextMessageToChat(userID: chat.userId, isAdmin: chat.isAdmin, userPushToke: chat.pushTokens ?? [], text: string, completion: completion)
		case .photo(_), .video(_):
            messagesManager.sendMediaMessageFor(userID: chat.userId, isAdmin: chat.isAdmin, tokens: chat.pushTokens ?? [], messageKind: messageKind, completion: completion)
		default:
			break
		}
	}
}
