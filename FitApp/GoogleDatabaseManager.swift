//
//  GoogleDatabaseManager.swift
//  FitApp
//
//  Created by Ofir Elias on 07/02/2021.
//

import UIKit
import Foundation
import MessageKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging

final class GoogleDatabaseManager {
	
	static let shared = GoogleDatabaseManager()
	private let database = Database.database().reference()
	
	func createChat(userId: String, isAdmin: Bool, completion: @escaping (Result<Chat, ErrorManager.DatabaseError>) -> Void) {
		let newChatData = createChatData()
		
		chatRef(userId: userId).setValue(newChatData) {
			error, ref in
			if let error = error {
				print(error.localizedDescription)
				return
			}
			
			let queue = DispatchQueue.global()
			let dispatchGroup = DispatchGroup()
			
			let sender = Sender(photoURL: "", senderId: userId, displayName: UserProfile.defaults.name ?? "")
			let chat = Chat(userId: userId, isAdmin: isAdmin, latestMessage: Message(sender: sender, messageId: Auth.auth().currentUser?.uid ?? "", sentDate: Date(), kind: .text(""), isIncoming: false))
			
			dispatchGroup.enter()
			queue.async(group: dispatchGroup) {
				self.downloadUserChatImagePath(chats: [chat]) {
					dispatchGroup.leave()
				}
			}
			dispatchGroup.enter()
			queue.async(group: dispatchGroup) {
				if isAdmin {
					dispatchGroup.leave()
				} else {
					self.updateOtherUserPushToken(chat: chat) {
						dispatchGroup.leave()
					}
				}
			}
			dispatchGroup.notify(queue: .global()) {
				completion(Result.success(chat))
			}
		}
	}
	func updatePushToken(userId: String, isAdmin: Bool) {
		guard let token = UserProfile.defaults.fcmToken else { return }
		let timestamp = Date().millisecondsSince2020
		if isAdmin {
			database.child("support").child("admin_push_tokens").child(token).setValue(timestamp)
		} else {
			chatRef(userId: userId).child("push_tokens").child(token).setValue(timestamp)
		}
	}
	func updateLastSeenMessageDate(chat: Chat) {
		chatRef(userId: chat.userId).child(chat.isAdmin == true ? "support_last_seen_message_timestamp" : "last_seen_message_timestamp").setValue(Date().millisecondsSince2020)
	}
	
	func sendMessageToChat(chat: Chat, content: String, kind: MessageKind, completion: @escaping (Result<Void, Error>) -> ()) {
		sendMessageToChat(chat: chat, content: content, link: nil, previewData: nil, kind: kind, completion: completion)
	}
	func sendMessageToChat(chat: Chat, content: String, link: String?, previewData: Data?, kind: MessageKind, completion: @escaping(Result<Void, Error>) -> ()) {
		let date = Date().millisecondsSince2020
		let messageId = "\(chat.userId)_\(date)"
		guard let senderId = Auth.auth().currentUser?.uid else {
			completion(.failure(ErrorManager.DatabaseError.noUID))
			return
		}
		
		let newMessagesData = createMessageData(senderId: senderId, kind: kind.rawValue, timestamp: date, content: content, mediaPath: link, mediaPreview: previewData?.base64EncodedString())
		
		chatMessagesRef(userId: chat.userId).child(messageId).setValue(newMessagesData) {
			error, data in
			
			if let error = error {
				completion(.failure(error))
			} else {
				completion(.success(()))
			}
		}
		updateLatestMessage(chat: chat, latestMessageData: newMessagesData)
	}
	
	func getAllChats(userId: String, completion: @escaping ([Chat]) -> Void) {
		chatsRef().observe(.value) {
			snapshot in
			
			let chats = self.parseChatsData(userId: userId, snapshot: snapshot)
			completion(chats)
		}
	}
	func getChat(userId: String, isAdmin: Bool, completion: @escaping (Result<Chat, ErrorManager.DatabaseError>) -> Void) {
		
		chatRef(userId: userId).observeSingleEvent(of: .value) {
			snapshot in
			
			guard let chat = self.parseChatData(userId: userId, isAdmin: isAdmin, snapshot: snapshot) else {
				completion(.failure(.dataIsEmpty))
				return
			}
			let queue = DispatchQueue.global()
			let dispatchGroup = DispatchGroup()
			
			dispatchGroup.enter()
			queue.async(group: dispatchGroup) {
				self.downloadUserChatImagePath(chats: [chat]) {
					dispatchGroup.leave()
				}
			}
			dispatchGroup.enter()
			queue.async(group: dispatchGroup) {
				if isAdmin {
					dispatchGroup.leave()
				} else {
					self.updateOtherUserPushToken(chat: chat) {
						dispatchGroup.leave()
					}
				}
			}
			dispatchGroup.notify(queue: .global()) {
				completion(Result.success(chat))
			}
		}
	}
	func getAllMessagesForChat(chat: Chat, completion: @escaping (Result<[Message], ErrorManager.DatabaseError>) -> Void) {
		chatMessagesRef(userId: chat.userId).observe(.value) {
			snapshot in
			guard let messages = self.parseMessagesData(userId: chat.userId, snapshot: snapshot) else {
				completion(.failure(.noFetch))
				return
			}
			completion(.success(messages))
		}
	}
	
	//Create
	private func createChatData() -> [String: Any] {
		let messageData = createMessageData(senderId: "", kind: MessageKind.text("").rawValue, timestamp: 0, content: "", mediaPath: nil, mediaPreview: nil)
		
		return [
			"display_name": "\(UserProfile.defaults.name ?? "")",
			"latest_message": messageData,
			"last_seen_message_timestamp": 0,
			"support_last_seen_message_timestamp": 0
		]
	}
	private func createMessageData(senderId: String, kind: String, timestamp: Int64, content: String, mediaPath: String?, mediaPreview: String?) -> [String:Any] {
		return [
			"type": kind,
			"content": content,
			"timestamp": timestamp,
			"sender_id": senderId,
			"media_path": mediaPath as Any,
			"media_preview": mediaPreview as Any
		]
	}
	
	//Update
	private func updateOtherUserPushToken(chat: Chat, completion: @escaping () ->()) {
		database.child("support").child("admin_push_tokens").observeSingleEvent(of: .value) {
			snapshot in
			
			guard let tokens = snapshot.value as? [String: Int64] else {
				completion()
				print("no Tokens")
				return
			}
			var pushTokens: [String] {
				return tokens.keys.compactMap { $0 }
			}
			chat.pushTokens = pushTokens
			completion()
		}
	}
	private func updateLatestMessage(chat: Chat, latestMessageData: [String: Any]) {
		chatRef(userId: chat.userId).child("latest_message").setValue(latestMessageData)
	}
	
	//Parse
	private func parseChatsData(userId: String, snapshot: DataSnapshot) -> [Chat] {
		var chats: [Chat] = []
		
		snapshot.children.forEach {
			data in
			
			guard let data = data as? DataSnapshot,
				  let chatData = data.value as? [String: Any] else  { return }
			var displayName: String? {
				return chatData["display_name"] as? String
			}
			var latestMessage: Message? {
				let messageSnapshot = data.childSnapshot(forPath: "latest_message")
				return parseLatestMessageData(userId: "", snapshot: messageSnapshot)
			}
			var lastSeenMessageTimestamp: Int64? {
				if let lastSeen = chatData["support_last_seen_message_timestamp"] as? Int64 {
					if lastSeen == 0 {
						return nil
					}
				}
				return chatData["support_last_seen_message_timestamp"] as? Int64
			}
			var pushTokens: [String] {
				let data = chatData["push_tokens"] as? [String: Int64]
				return data?.keys.compactMap { $0 } ?? []
			}
			chats.append(Chat(userId: data.key, isAdmin: true, displayName: displayName, latestMessage: latestMessage, pushTokens: pushTokens, lastSeenMessageDate: lastSeenMessageTimestamp?.dateFromMillisecondsSince2020))
		}
		return chats
	}
	private func parseChatData(userId: String, isAdmin: Bool, snapshot: DataSnapshot) -> Chat? {
		guard let chatData = snapshot.value as? [String: Any] else  { return nil }
		
		var displayName: String? {
			if isAdmin {
				return chatData["display_name"] as? String
			} else {
				return nil
			}
		}
		var lastSeenMessageTimestamp: Int64? {
			
			if isAdmin {
				return chatData["support_last_seen_message_timestamp"] as? Int64
			} else {
				return chatData["last_seen_message_timestamp"] as? Int64
			}
		}
		var pushTokens: [String] {
			let data = chatData["push_tokens"] as? [String: Int64]
			return data?.keys.compactMap { $0 } ?? []
		}

		return Chat(userId: userId, isAdmin: isAdmin, displayName: displayName, pushTokens: pushTokens, lastSeenMessageDate: lastSeenMessageTimestamp?.dateFromMillisecondsSince2020)
	}
	private func parseMessagesData(userId: String, snapshot: DataSnapshot) -> [Message]? {
		guard let value = snapshot.value as? [String: Any] else {
			return nil
		}
		
		let messages: [Message] = value.compactMap { entry in
			
			let messageId = entry.key
			guard let messageData = entry.value as? [String: Any],
				  let content = messageData["content"] as? String,
				  let senderId = messageData["sender_id"] as? String,
				  let timestamp = messageData["timestamp"] as? Int64,
				  let type = messageData["type"] as? String else { return nil }
			
			let mediaPath = messageData["media_path"] as? String
			let date = timestamp.dateFromMillisecondsSince2020
			
			var kind: MessageKind?
			switch type {
				
			case "TEXT":
				kind = .text(content)
			case "PHOTO":
				if let base64BitmapData = messageData["media_preview"] as? String, base64BitmapData != "", let placeHolder: UIImage = convertBase64StringToImage(imageBase64String: base64BitmapData) {
					let media = Media(mediaURLString: mediaPath, placeholderImage: placeHolder, size: CGSize(width: 150, height: 150))
					
					kind = .photo(media)
				} else {
					guard let placeHolder = UIImage(systemName: "plus") else { break }
					let media = Media(mediaURLString: mediaPath, placeholderImage: placeHolder, size: CGSize(width: 150, height: 150))
					
					kind = .photo(media)
				}
			case "VIDEO":
				if let base64BitmapData = messageData["media_preview"] as? String, base64BitmapData != "", let placeHolder: UIImage = convertBase64StringToImage(imageBase64String: base64BitmapData) {
					let media = Media(mediaURLString: mediaPath, placeholderImage: placeHolder, size: CGSize(width: 150, height: 150))
					
					kind = .video(media)
				} else if let defaultPlaceHolderImage = UIImage(systemName: "video.fill")?.imageWithSize(CGSize(width: 150, height: 150)) {
					let media = Media(mediaURLString: mediaPath, placeholderImage: defaultPlaceHolderImage, size: CGSize(width: 150, height: 150))
					
					kind = .video(media)
				}
			default:
				break
			}
			return Message(sender: Sender(photoURL: "", senderId: senderId, displayName: ""), messageId: messageId, sentDate: date, kind: kind ?? .text(""), isIncoming: senderId != userId, content: content)
		}
		return messages
	}
	private func parseLatestMessageData(userId: String, snapshot: DataSnapshot) -> Message? {
		guard let value = snapshot.value as? [String: Any] else {
			return nil
		}
		guard let content = value["content"] as? String,
			  let senderId = value["sender_id"] as? String,
			  let timestamp = value["timestamp"] as? Int64,
			  let type = value["type"] as? String else { return nil }
		
		let date = timestamp.dateFromMillisecondsSince2020
		
		var kind: MessageKind?
		
		switch type {
			
		case "TEXT":
			kind = .text(content)
		case "PHOTO":
			kind = .text("תמונה")
		case "VIDEO":
			kind = .text("וידאו")
		default:
			break
		}
		return Message(sender: Sender(photoURL: "", senderId: senderId, displayName: ""), messageId: "", sentDate: date, kind: kind ?? .text(""), isIncoming: senderId != userId, content: content)
	}
	private func downloadUserChatImagePath(chats: [Chat], completion: @escaping () ->()) {
		
		let queue = DispatchQueue.global()
		let dispatchGroup = DispatchGroup()
		
		queue.async(group: dispatchGroup) {
			chats.forEach {
				chat in
				dispatchGroup.enter()
				let path = "\(chat.userId)/profile_image.jpeg"
				GoogleStorageManager.shared.downloadURL(path: path) {
					result in
					
					switch result {
					case .success(let url):
						chat.imagePath = url
						dispatchGroup.leave()
					case .failure(let error):
						dispatchGroup.leave()
						print("no image exist", error)
					}
				}
			}
		}
		dispatchGroup.notify(queue: .global()) {
			completion()
		}
	}
	
	//Reference
	private func chatsRef() -> DatabaseReference {
		return database.child("support").child("chats")
	}
	private func chatRef(userId: String) -> DatabaseReference {
		return database.child("support").child("chats").child(userId)
	}
	private func chatMessagesRef(userId: String) -> DatabaseReference {
		return database.child("support").child("messages").child(userId)
	}
	
	func convertBase64StringToImage (imageBase64String: String) -> UIImage? {
		if let imageData = Data(base64Encoded: imageBase64String, options: .init(rawValue: 0)) {
			let image = UIImage(data: imageData)
			return image
		}
		return nil
	}
}

//MARK: - Related Type Extensions
extension DataSnapshot {
	
	var data: Data? {
		guard let value = value, !(value is NSNull) else { return nil }
		return try? JSONSerialization.data(withJSONObject: value)
	}
	var json: String? { data?.string }
}

extension Data {
	
	var string: String? { String(data: self, encoding: .utf8) }
}

extension Date {
	
	private var timestampSince2020: Int64 { 1577833200000 }
	
	var millisecondsSince2020: Int64 {
		return Int64(timeIntervalSince1970 * 1000) - timestampSince2020
	}
}

extension Int64 {
	
	private var timestampSince2020: Int64 { 1577833200000 }
	
	var dateFromMillisecondsSince2020: Date {
		return Date(timeIntervalSince1970: Double(self + timestampSince2020) / 1000.0)
	}
}
extension MessageKind {
	
	var rawValue: String {
		switch self {
		case .text(_):
			return "TEXT"
		case .attributedText(_):
			return "ATTRIBUTED_TEXT"
		case .photo(_):
			return "PHOTO"
		case .video(_):
			return "VIDEO"
		case .location(_):
			return "LOCATION"
		case .emoji(_):
			return "EMOJI"
		case .audio(_):
			return "AUDIO"
		case .contact(_):
			return "CONTACT"
		case .linkPreview(_):
			return "LINK_PREVIEW"
		case .custom(_):
			return "CUSTOM"
		}
	}
}
