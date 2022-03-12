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
	private var messages = [Message]()
	private let messagesManager = MessagesManager.shared
	
	var chatViewModelBinder: (() -> ()) = {}
	
	required init(chat: Chat?) {
		
		if let chat = chat {
			self.chat = chat
			self.listenToMessages()
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
	var getOtherUserToken: String {
		chat?.pushTokens?.first ?? ""
	}
	var getDisplayName: String? {
		chat?.displayName
	}
	var messagesCount: Int {
		messages.count
	}
	var getLastMessage: Message? {
		messages.last
	}
	func getMessageAt(_ indexPath: IndexPath) -> Message {
		messages[indexPath.section]
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
			print("chat not fetched")
			return
		}
		
		messagesManager.fetchMessagesFor(chat) {
			[weak self] messages in
			guard let self = self, let messages = messages else {
				self?.chatViewModelBinder()
				return
			}
			
			self.messages = messages.sorted()
			self.chatViewModelBinder()
		}
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
