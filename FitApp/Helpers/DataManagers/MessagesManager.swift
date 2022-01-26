//
//  MessagesManager.swift
//  FitApp
//
//  Created by Ofir Elias on 22/09/2021.
//

import Foundation
import FirebaseAuth
import AVFoundation
import MessageKit

enum MessageError: Error {
	
	case messageNotSent
}

class MessagesManager {
	
	static let shared = MessagesManager()
	
	let googleManager = GoogleDatabaseManager.shared
	let googleStorageManager = GoogleStorageManager.shared
	
	private var chats: [Chat] = [Chat]() {
		didSet {
			self.bindMessageManager()
		}
	}
	
	private let isAdmin = UserProfile.defaults.getIsManager
	private let supportEmail = "support-mail-com"
	private let userId = Auth.auth().currentUser?.uid
	private let userEmail = UserProfile.defaults.email
	private let userName = UserProfile.defaults.name
	
	var bindMessageManager: (() -> ()) = {}
	
	private init() {
		guard let userId = self.userId else { return }
		let queue = OperationQueue()
		
		queue.addOperation {
			// Update tokens
			self.googleManager.updatePushToken(userId: userId, isAdmin: self.isAdmin)
		}
		queue.addOperation {
			if self.isAdmin {
				self.fetchSupportChats()
			} else {
				self.fetchUserChat(userId: userId, isAdmin: self.isAdmin)
			}
		}
		queue.waitUntilAllOperationsAreFinished()
	}
}

//MARK: - Functions
extension MessagesManager {
	
	//Getters
	public func getUserChat() -> Chat? {
		guard let chat = chats.first else { return nil }
		return chat
	}
	public func getSupportChats() -> [Chat]? {
		guard !chats.isEmpty else { return nil }
		return chats
	}
	
	private func sendNotification(to tokens: [String], name: String, text: String) {
		let notification = PushNotificationSender()
		
		DispatchQueue.global(qos: .background).async {
			tokens.forEach {
				notification.sendPushNotification(to: $0, title: "הודעה נשלחה מ- \(name)", body: text)
			}
		}
	}
	public func sendTextMessageToChat(chat: Chat, text: String, completion: @escaping (Error?) -> ()) {
		
		DispatchQueue.global(qos: .background).async {
			GoogleDatabaseManager.shared.sendMessageToChat(chat: chat, content: text, kind: .text(text)) {
				[weak self] result in
				guard let self = self else { return }
				
				switch result {
				case .success(_):
					
					completion(nil)
					guard let userName = self.userName, let otherUserPushTokens = chat.pushTokens else { return }
					self.sendNotification(to: otherUserPushTokens, name: userName, text: text)
				case .failure(let error):
					
					completion(error)
					print("Error:", error.localizedDescription)
				}
			}
		}
	}
	public func sendMediaMessageFor(chat: Chat, messageKind: MessageKind, completion: @escaping (Error?) -> ()) {
		
		switch messageKind {
		case .photo(let media):
			guard let image = media.image,
				  let imageData = image.jpegData(compressionQuality: 0.5),
				  let fileName = self.remoteFileName(chat: chat, suffix: "photo_message.jpeg") else { return }
			
			//Send Photo message
			GoogleStorageManager.shared.uploadImage(from: .messagesImage, data: imageData, fileName: fileName) {
				result in
				
				switch result {
				case .success(let urlString):
					
					guard let url = URL(string: urlString),
						  let placeholder = UIImage(systemName: "plus") else { return }
					let media = Media(url: url, image: nil, placeholderImage: placeholder, size: .zero)
					
					GoogleDatabaseManager.shared.sendMessageToChat(chat: chat, content: "", link: urlString, previewData: nil, kind: .photo(media)) {
						[weak self] result in
						guard let self = self else { return }
						
						switch result {
							
						case .success():
							completion(nil)
							guard let userName = self.userName, let otherUserPushTokens = chat.pushTokens else { return }
							self.sendNotification(to: otherUserPushTokens, name: userName, text: "הודעת תמונה")
							
						case .failure(let error):
							completion(error)
							print("Error:", error.localizedDescription)
						}
					}
				case .failure(let error):
					print("message photo upload error:", error)
				}
			}
		case .video(let media):
			guard let fileUrl = media.url,
				  let fileName = self.remoteFileName(chat: chat, suffix: "video_message.mp4") else { return }
			
			//Send Video message
			googleStorageManager.uploadVideo(fileUrl: fileUrl, fileName: fileName) {
				[weak self] result in
				guard let self = self else { return }
				
				switch result {
				case .success(let urlString):
					
					guard let url = URL(string: urlString),
						  let placeholder = MessagesManager.generateThumbnailFrom(videoURL: url) else { return }
					let media = Media(url: url, image: nil, placeholderImage: placeholder, size: .zero)
					
					GoogleDatabaseManager.shared.sendMessageToChat(chat: chat, content: "", link: urlString, previewData: placeholder.jpegData(compressionQuality: 2), kind: .video(media)) {
						[weak self] result in
						guard let self = self else { return }
						
						switch result {
							
						case .success():
							completion(nil)
							guard let userName = self.userName, let otherUserPushTokens = chat.pushTokens else { return }
							self.sendNotification(to: otherUserPushTokens, name: userName, text: "הודעת וידאו")
							
						case .failure(let error):
							completion(error)
							print("Error:", error.localizedDescription)
						}
					}
				case .failure(let error):
					print("message photo upload error:", error)
				}
			}
		default:
			return
		}
	}
	
	public func  fetchSupportChats() {
		guard let userId = self.userId else { return }
		
		GoogleDatabaseManager.shared.getAllChats(userId: userId) {
			[weak self] chats in
			guard let self = self else { return }
			
			self.chats = chats
		}
	}
	private func fetchUserChat(userId: String, isAdmin: Bool) {
		//Get Chat If Exist
		googleManager.getChat(userId: userId, isAdmin: isAdmin) {
			[weak self] result in
			guard let self = self else { return }
			
			switch result {
			case .success(let chat):
				
				self.chats.append(chat)
			case .failure(let error):
				
				switch error {
				case .dataIsEmpty:
					
					//If chat dose not exist, create new Chat
					GoogleDatabaseManager.shared.createChat(userId: userId, isAdmin: self.isAdmin) {
						[weak self] result in
						guard let self = self else { return }
						
						switch result {
						case .success(let chat):
							self.chats.append(chat)
						case .failure(let error):
							print("Error:", error.localizedDescription)
						}
					}
				default:
					Spinner.shared.stop()
					print("Error:", error.localizedDescription)
				}
			}
		}
	}
	public func  fetchMessagesFor(_ chat: Chat, completion: @escaping ([Message]?) -> ()) {
		
		googleManager.getAllMessagesForChat(chat: chat) {
			result in
			
			switch result {
			case .success(let messages):
				if messages.isEmpty {
					completion([])
					return
				}
				completion(messages)
			case .failure(let error):
				print("Error:", error.localizedDescription)
			}
		}
	}
}

extension MessagesManager {
	
	private func remoteFileName(chat: Chat, suffix: String) -> String? {
		return "\(chat.userId)_\(Date().millisecondsSince2020)_\(suffix)"
	}
	static func generateThumbnailFrom(videoURL: URL) -> UIImage? {
		let asset = AVAsset(url: videoURL)
		let assetImgGenerate = AVAssetImageGenerator(asset: asset)
		let time = CMTimeMakeWithSeconds(Float64(1), preferredTimescale: 100)
		
		assetImgGenerate.appliesPreferredTrackTransform = true

		do {
			let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
			let thumbnail = UIImage(cgImage: img)
			return thumbnail
		} catch {
			return UIImage(named: "plus")
		}
	}
	public func sendMassageToSupport(existingChatId: String?, otherUserEmail: String? ,messageText: String, chatOtherTokens: [String]?) {
		//		guard let otherUserEmail = otherUserEmail, let messageId = generateMessageId(otherUserEmail: otherUserEmail), let selfSender = generateSelfSender(), let userName = userName else { return }
		//		let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(messageText), isIncoming: false)
		//
		//		if existingChatId == nil {
		//			guard let otherTokens = supportTokens else { return }
		//			createChat(otherUserEmail: otherUserEmail, otherTokens: otherTokens, name: userName, message: message, notificationText: messageText)
		//		} else {
		//			guard let chatID = existingChatId, let otherTokens = supportTokens else { return }
		//			sendMessageToChat(chatId: chatID, otherUserEmail: otherUserEmail, otherTokens: otherTokens, name: userName, message: message, notificationText: messageText)
		//		}
	}
	
	public func postBroadcast(text: String) {
		for chat in chats {
			self.sendTextMessageToChat(chat: chat, text: text) {_ in
				
			}
		}
	}
}
