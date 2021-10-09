//
//  MessagesManager.swift
//  FitApp
//
//  Created by Ofir Elias on 22/09/2021.
//

import Foundation

enum MessageError: Error {
	
	case messageNotSent
}

class MessagesManager {
	
	static let shared = MessagesManager()
	
	public var userChats: [Chat]?
	private var supportTokens: [String]?
	
	private let userName = UserProfile.defaults.name
	private let userEmail = UserProfile.defaults.email
	
	var bindMessageManager: (() -> ()) = {}
	
	private init() {
		
		let queue = OperationQueue()
		
		queue.addOperation {
			self.generateUserSupportChat() {
				[weak self] chat in
				guard let self = self else { return }
				self.supportTokens = chat?.otherUserTokens
			}
		}
		queue.addOperation {
			self.supportChatExist() {
				[weak self] chat in
				guard let self = self else { return }
				self.userChats = chat
				self.bindMessageManager()
			}
		}
		
		queue.waitUntilAllOperationsAreFinished()
	}
}

//MARK: - Functions
extension MessagesManager {
	
	private func generateSelfSender() -> Sender? {
		guard let email = userEmail, let name = userName else {  return nil }
		return Sender(senderId: email.safeEmail, displayName: name)
	}
	private func generateMessageId(otherUserEmail: String) -> String? {
		guard let currentUserEmail = UserProfile.defaults.email else { return nil }
		let identifier = "\(otherUserEmail)_\(currentUserEmail.safeEmail)_\(Date().fullDateStringForDB)"
		return identifier
	}
	private func generateMessageIdForBroadcast(otherUserEmail: String) -> String? {
		guard let currentUserEmail = UserProfile.defaults.email else { return nil }
		let identifier = "\(currentUserEmail.safeEmail)_\(otherUserEmail)_\(Date().fullDateStringForDB)"
		return identifier
	}
	public func generateUserSupportChat(completion: @escaping (Chat?) -> ()) {
		guard let userSafeEmail = userEmail?.safeEmail else { return }
		let name = "דברי אלינו"
		let latestMessage = LatestMessage (date: Date().dateStringForDB, text: "כיתבי לנו כאן ואנו מבטיחים לחזור אליך בהקדם האפשרי", isRead: false)
		
		GoogleDatabaseManager.shared.getChatUsers {
			result in
			
			switch result {
			case .success(let users):
				for user in users {
					if user.email == "support-mail-com" {
						let tokens = user.tokens
						let otherUserEmail = user.email
						let chatId = "\(userSafeEmail)_\(otherUserEmail)_\(Date().dateStringForDB)"
						completion(Chat(id: chatId, name: name, otherUserEmail: otherUserEmail, otherUserTokens: tokens, latestMessage: latestMessage))
					}
				}
			case .failure(let error):
				print(error.localizedDescription)
				completion(nil)
			}
		}
	}
	
	private func sendNotification(to tokens: [String], name: String, text: String) {
		let notification = PushNotificationSender()
		DispatchQueue.global(qos: .background).async {
			tokens.forEach {
				notification.sendPushNotification(to: $0, title: "הודעה נשלחה מ- \(name)", body: text)
			}
		}
	}
	private func createChat(otherUserEmail: String, otherTokens: [String], name: String, message: Message, notificationSenderName: String? = nil, notificationText: String) {
		DispatchQueue.global(qos: .background).async {
			GoogleDatabaseManager.shared.createNewChat(with: otherUserEmail, otherUserTokens: otherTokens, name: name, firstMessage: message) {
				[weak self] success in
				guard let self = self else { return }
				
				if success {
					self.sendNotification(to: otherTokens, name: notificationSenderName ?? name, text: notificationText)
				} else {
					print("not sent")
					return
				}
			}
		}
	}
	private func sendMessageToChat(chatId: String, otherUserEmail: String, otherTokens: [String], name: String, message: Message, notificationSenderName: String? = nil, notificationText: String) {
		DispatchQueue.global(qos: .background).async {
			GoogleDatabaseManager.shared.sendMessage(to: chatId, otherUserEmail: otherUserEmail, newMessage: message, name: name) {
				[weak self] success in
				guard let self = self else { return }
				
				if success {
					self.sendNotification(to: otherTokens, name: notificationSenderName  ?? name, text: notificationText)
				} else {
					print("not sent")
					return
				}
			}
		}
	}
	
	public func supportChatExist(completion: @escaping ([Chat]?) -> ()) {
		guard let userSafeEmail = userEmail?.safeEmail else { return }
		
		GoogleDatabaseManager.shared.getAllChats(for: userSafeEmail) {
			result in
			
			switch result {
			case .success(let chats):
				guard !chats.isEmpty else {
					completion(nil)
					return
				}
				completion(chats)
			case .failure(let error):
				print(error.localizedDescription)
				completion(nil)
			}
		}
	}
}

extension MessagesManager {
	
	public func postMassageToSupport(existingChatId: String?, otherUserEmail: String? ,messageText: String, chatOtherTokens: [String]?) {
		guard let otherUserEmail = otherUserEmail, let messageId = generateMessageId(otherUserEmail: otherUserEmail), let selfSender = generateSelfSender(), let userName = userName else { return }
		let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(messageText))
		
		if existingChatId == nil {
			guard let otherTokens = supportTokens else { return }
			createChat(otherUserEmail: otherUserEmail, otherTokens: otherTokens, name: userName, message: message, notificationText: messageText)
		} else {
			guard let chatID = existingChatId, let otherTokens = supportTokens else { return }
			sendMessageToChat(chatId: chatID, otherUserEmail: otherUserEmail, otherTokens: otherTokens, name: userName, message: message, notificationText: messageText)
		}
	}
	public func postBroadcast(text: String, chatUsers: [ChatUser]) {
		let usersWithExistingChats: [Chat] = userChats ?? []
		var usersWithoutChats: [ChatUser] = [ChatUser]()
		
		//Filter users without chats
		let existingChatUserNames = usersWithExistingChats.map { $0.otherUserEmail }
		for user in chatUsers {
			if !existingChatUserNames.contains(where: { $0 == user.email }) {
				usersWithoutChats.append(user)
			}
		}
		
		//Create new chats and send messages for users without chats
		for user in usersWithoutChats {
			guard let userToken = user.tokens, let messageId = generateMessageIdForBroadcast(otherUserEmail: user.email), let selfSender = generateSelfSender() else { return }
			let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
			
			createChat(otherUserEmail: user.email, otherTokens: userToken, name: user.name, message: message, notificationSenderName: "Bounce", notificationText: text)
		}
		//Send messages for users with chats
		for userChat in usersWithExistingChats {
			guard let userToken = userChat.otherUserTokens , let messageId = generateMessageIdForBroadcast(otherUserEmail: userChat.otherUserEmail), let selfSender = generateSelfSender() else { return }
			let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
			
			sendMessageToChat(chatId: userChat.id, otherUserEmail: userChat.otherUserEmail, otherTokens: userToken, name: "Bounce", message: message, notificationSenderName: "Bounce", notificationText: text)
		}
	}
}
