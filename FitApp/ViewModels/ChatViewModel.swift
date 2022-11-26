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
	
	var messages: ProjectObservableObject<[Message]?> = ProjectObservableObject(nil)
		
	required init(chat: Chat?) {
		
		if let chat = chat {
			self.chat = chat
			self.listenToMessages()
			self.updateLastSeenDate()
		} else {
			if let chat = self.messagesManager.getUserChat() {
				self.chat = chat
				self.listenToMessages()
			} else {
				messagesManager.bindMessageManager = {
					self.chat = self.messagesManager.getUserChat()
					self.listenToMessages()
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
		messages.value?.count ?? 0
	}
	var getLastMessage: Message? {
		messages.value?.last
	}
	func getMessageAt(_ indexPath: IndexPath) -> Message {
		messages.value![indexPath.section]
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
		messagesManager.googleManager.updateLastSeenMessageDate(chat: chat)
	}
	public func getMediaUrlFor(_ urlString: String, completion: @escaping (URL?) -> ()) {
		messagesManager.downloadMediaURL(urlString: urlString, completion: completion)
	}
	public func sendMessage(messageKind: MessageKind, completion: @escaping (Error?) -> ()) {
		guard let chat = chat else { return }
		
		switch messageKind {
		case .text(let string):
			messagesManager.sendTextMessageToChat(chat: chat, text: string, completion: completion)
		case .photo(_), .video(_):
			messagesManager.sendMediaMessageFor(chat: chat, messageKind: messageKind, completion: completion)
		default:
			break
		}
	}
}
