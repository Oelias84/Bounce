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
	
	lazy var chatViewModelBinder: (() -> ()) = {}
	
	required init(chat: Chat?) {
		
		if let chat = chat {
			self.chat = chat
		} else {
			self.chat = messagesManager.getUserChat()
		}
	}
	
	//getters
	var getDisplayName: String? {
		chat?.displayName
	}
	var messagesCount: Int {
		messages.count
	}
	var getLastMessage: Message? {
		messages.last
	}
	var getAllMassages: [Message] {
		messages
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
	
	public func listenToMessages(completion: @escaping () -> ()) {
		guard let chat = chat else {
			completion()
			return
		}
		
		messagesManager.fetchMessagesFor(chat) {
			[weak self] messages in
			guard let self = self, let messages = messages else { return }
			
			self.messages = messages
			completion()
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
