//
//  GoogleDatabaseManager.swift
//  FitApp
//
//  Created by Ofir Elias on 07/02/2021.
//

import Foundation
import MessageKit
import FirebaseDatabase

enum DatabaseError: Error {
	
	case failedToUpdate
	case failedToFetch
	case failedToDecodeData
	case dataIsEmpty
	case noFetch
	case isPrime
}


final class GoogleDatabaseManager {
	
	static let shared = GoogleDatabaseManager()
	private let database = Database.database().reference()
}

//MARK: - User functionality
extension GoogleDatabaseManager {
	
	public func insertUser(with user: User, completion: @escaping (Bool) -> Void) {
		
		database.child(user.safeEmail).setValue([
			"first_name": user.firsName,
			"last_name": user.lastName
		]) { error, _ in
			
			guard error == nil else {
				print("failed to write to database")
				completion(false)
				return
			}
			
			self.database.child("chat_users").observeSingleEvent(of: .value) { snapshot in
				let newElement = ["name": user.firsName + " " + user.lastName,
								  "email": user.safeEmail,
								  "tokens": [user.deviceToken]] as [String : Any]
				
				if var usersCollection = snapshot.value as? [[String:Any]] {
					usersCollection.append(newElement)
					self.database.child("chat_users").setValue(usersCollection) { error, data in
						guard error == nil else {
							completion(false)
							return
						}
						completion(true)
					}
				} else {
					let newCollection: [[String:Any]] = [newElement]
					self.database.child("chat_users").setValue(newCollection) { error, data in
						guard error == nil else {
							completion(false)
							return
						}
						completion(true)
					}
				}
			}
		}
	}
	public func userExists(with email: String, completion: @escaping ((Bool) -> Void)) {
		
		database.child(email.safeEmail).observeSingleEvent(of: .value) { snapshot in
			guard snapshot.value as? String != nil else {
				completion(false)
				return
			}
			completion(true)
		}
	}
	public func getChatUsers(completion: @escaping (Result<[ChatUser], DatabaseError>) -> Void) {
		database.child("chat_users").observeSingleEvent(of: .value) { snapshot in
			guard snapshot.value != nil else {
				completion(.failure(.failedToFetch))
				return
			}
			
			if let data = snapshot.data {
				do {
					let users = try JSONDecoder().decode([ChatUser].self, from: data)
					if users.isEmpty {
						completion(.failure(.dataIsEmpty))
					} else {
						completion(.success(users))
					}
				} catch {
					completion(.failure(.failedToDecodeData))
					print(error.localizedDescription)
				}
			}
		}
	}
	func add(token: String, for user: User) {
		self.database.child("chat_users").observeSingleEvent(of: .value) { snapshot in
			
			let updateData = ["name": user.firsName + " " + user.lastName,
							  "email": user.safeEmail,
							  "tokens": [user.deviceToken ?? ""] as [String]] as [String : Any]
			
			if var usersCollection = snapshot.value as? [[String : Any]] {
				for i in 0...usersCollection.count-1 {
					let user = usersCollection[i]
					
					if user["email"] as! String == "support-mail-com" {
						if user["tokens"] == nil {
							usersCollection[i] = updateData
							break
						} else {
							var tokenCollection = (usersCollection[i]["tokens"] as! [String])
							tokenCollection.append(token)
							usersCollection[i]["tokens"] = tokenCollection
							break
						}
					} else if user["email"] as! String == updateData["email"] as! String {
						usersCollection[i] = updateData
						break
					} else {
						usersCollection.append(updateData)
					}
				}
				self.database.child("chat_users").setValue(usersCollection) { error, data in
					guard error == nil else {
						print(error!.localizedDescription)
						return
					}
					print("chat user was update")
				}
			}
		}
	}
}

//MARK: - Chat functionality
extension GoogleDatabaseManager {
	
	public func createNewChat(with otherUserEmail: String, otherUserTokens: [String]?, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
		guard let currentEmail = UserProfile.defaults.email , let currentName = UserProfile.defaults.name else {
			completion(false)
			return
		}
		let safeEmail = currentEmail.safeEmail
		let selfToken = UserProfile.defaults.fcmToken
		let ref = database.child(safeEmail)
		
		ref.observeSingleEvent(of: .value) { [weak self] snapshot in
			guard let self = self, var userNode = snapshot.value as? [String : Any] else {
				completion(false)
				return
			}
			
			var message = ""
			
			switch firstMessage.kind {
			case .text(let messageText):
				message = messageText
			default:
				break
			}
			
			let chatId = "chat_\(firstMessage.messageId)"
			let newChat: [String: Any] = [
				"id": chatId,
				"other_user_email": otherUserEmail,
				"other_user_tokens": (otherUserTokens ?? nil) as [String]? as Any,
				"name": name,
				"latest_message": [
					"date": firstMessage.sentDate.fullDateStringForDB,
					"message": message,
					"is_read": false
				]
			]
			
			let recipientNewChat: [String: Any] = [
				"id": chatId,
				"other_user_email": safeEmail,
				"other_user_tokens": (selfToken != nil ? [selfToken!] : nil) as [String]? as Any,
				"name": currentName,
				"latest_message": [
					"date": firstMessage.sentDate.fullDateStringForDB,
					"message": message,
					"is_read": false
				]
			]
			
			self.database.child("\(otherUserEmail)/chats").observeSingleEvent(of: .value) { [weak self] snapshot in
				guard let self = self else { return }
				
				if var chats = snapshot.value as? [[String:Any]] {
					chats.append(recipientNewChat)
					self.database.child("\(otherUserEmail)/chats").setValue(chats)
				} else {
					self.database.child("\(otherUserEmail)/chats").setValue([recipientNewChat])
				}
			}
			
			if var chats = userNode["chats"] as? [[String: Any]] {
				chats.append(newChat)
				userNode["chats"] = chats
				ref.setValue(userNode) { [weak self] error, _ in
					guard let self = self, error == nil else {
						completion(false)
						return
					}
					self.finishCreatingChat(name: name, chatId: chatId, firstMessage: firstMessage, completion: completion)
				}
			} else {
				userNode["chats"] = [
					newChat
				]
				ref.setValue(userNode) { [weak self] error, _ in
					guard let self = self, error == nil else {
						completion(false)
						return
					}
					self.finishCreatingChat(name: name, chatId: chatId, firstMessage: firstMessage, completion: completion)
				}
			}
		}
	}
	public func getAllChats(for email: String, completion: @escaping (Result<[Chat],DatabaseError>) -> Void) {
		
		database.child("\(email)/chats").observe(.value) { snapshot in
			
			guard let value = snapshot.value as? [[String:Any]] else {
				completion(.failure(.noFetch))
				return
			}
			
			let chats: [Chat] = value.compactMap { dictionary in
				
				guard let chatId = dictionary["id"] as? String,
					  let name = dictionary["name"] as? String,
					  let otherUserEmail = dictionary["other_user_email"] as? String,
					  let latestMessages = dictionary["latest_message"] as? [String: Any],
					  let sent = latestMessages["date"] as? String,
					  let message = latestMessages["message"] as? String,
					  let isRead = latestMessages["is_read"] as? Bool else {
					return nil
				}
				let otherUserTokens = dictionary["other_user_tokens"] as? [String]?
				
				let latest = LatestMessage(date: sent, text: message, isRead: isRead)
				return Chat(id: chatId, name: name, otherUserEmail: otherUserEmail, otherUserTokens: otherUserTokens ?? nil, latestMessage: latest)
			}
			completion(.success(chats))
		}
	}
	public func updateChat(chat: Chat, completion: @escaping (Result<Bool,DatabaseError>) -> Void) {
		guard let currentUserSafeEmail = UserProfile.defaults.email?.safeEmail else {
			completion(.failure(.noFetch))
			return
		}
		database.child("\(currentUserSafeEmail)/chats").observeSingleEvent(of:.value) { snapshot in
			var databaseEntryChat = [[String:Any]]()
			
			let updateValue: [String:Any] = [
				"date": chat.latestMessage.date,
				"is_read": true,
				"message": chat.latestMessage.text
			]
			if var currentUserChats = snapshot.value as? [[String:Any]] {
				var targetChat: [String:Any]?
				var position = 0
				
				for chatDictionary in currentUserChats {
					if let currentId = chatDictionary["id"] as? String, currentId == chat.id {
						targetChat = chatDictionary
						break
					}
					position += 1
				}
				
				if var targetChat = targetChat {
					targetChat["latest_message"] = updateValue
					currentUserChats[position] = targetChat
					databaseEntryChat = currentUserChats
					
					self.database.child("\(currentUserSafeEmail)/chats").setValue(databaseEntryChat) { error,_ in
						guard error == nil else {
							completion(.failure(.failedToUpdate))
							return
						}
						completion(.success(true))
					}
				} else {
					completion(.failure(.failedToUpdate))
				}
			}
		}
	}
	public func getAllMessagesForChat(with id: String, completion: @escaping (Result<[Message],DatabaseError>) -> Void) {
		database.child("\(id)/messages").observe(.value) { snapshot in
			guard let value = snapshot.value as? [[String:Any]] else {
				completion(.failure(.noFetch))
				return
			}
			
			let messages: [Message] = value.compactMap { dictionary in
				guard let name = dictionary["name"] as? String,
					  let isRead = dictionary["is_read"] as? Bool,
					  let messageId = dictionary["id"] as? String,
					  let content = dictionary["content"] as? String,
					  let senderEmail = dictionary["sender_email"] as? String,
					  let type = dictionary["type"] as? String,
					  let dateString = dictionary["date"] as? String else {
					return nil
				}
				
				var kind: MessageKind?
				if type == "text" {
					kind = .text(content)
				} else {
					guard let imageUrl = URL(string: content),
						  let placeHolder = UIImage(systemName: "plus") else {
						return nil
					}
					let media = Media(url: imageUrl, image: nil, placeholderImage: placeHolder, size: CGSize(width: 300, height: 300))
					kind = .photo(media)
				}
				
				guard let finalKind = kind else { return nil }
				
				let sender = Sender(senderId: senderEmail, displayName: name)
				return Message(sender: sender, messageId: messageId, sentDate: dateString.fullDateFromStringWithDash!, kind: finalKind)
			}
			completion(.success(messages))
		}
	}
	public func sendMessage(to chatId: String, otherUserEmail: String, newMessage: Message, name: String, completion: @escaping (Bool) -> Void) {
		
		guard let currentUserEmail = UserProfile.defaults.email else {
			completion(false)
			return
		}
		let currentUserSafeEmail = currentUserEmail.safeEmail
		let recipientSafeEmail = otherUserEmail.safeEmail
		
		database.child("\(chatId)/messages").observeSingleEvent(of: .value) {
			[weak self] snapshot in
			guard let self = self else { return }
			
			guard var currentMessages = snapshot.value as? [[String:Any]] else {
				completion(false)
				return
			}
			
			var messageContent = ""
			switch newMessage.kind {
			case .text(let messageText):
				messageContent = messageText
			case .photo(let mediaItem):
				if let mediaItem = mediaItem.url {
					messageContent = mediaItem.absoluteString
				}
			default:
				break
			}
			
			let message: [String:Any] = [
				"id": newMessage.messageId,
				"type": newMessage.kind.rawValue,
				"content": messageContent,
				"date": newMessage.sentDate.fullDateStringForDB,
				"sender_email": currentUserSafeEmail,
				"is_read": false,
				"name": name
			]
			
			currentMessages.append(message)
			
			self.database.child("\(chatId)/messages").setValue(currentMessages) {
				[weak self] error, _ in
				guard let self = self, error == nil else {
					completion(false)
					return
				}
				
				//create func
				
				self.database.child("\(currentUserSafeEmail)/chats").observeSingleEvent(of: .value) { snapshot in
					
					var databaseEntryChat = [[String:Any]]()
					let updateValue: [String:Any] = [
						"date": newMessage.sentDate.fullDateStringForDB,
						"is_read": false,
						"message": messageContent
					]
					
					if var currentUserChats = snapshot.value as? [[String:Any]] {
						var targetChat: [String:Any]?
						var position = 0
						
						for chatDictionary in currentUserChats {
							if let currentId = chatDictionary["id"] as? String, currentId == chatId {
								targetChat = chatDictionary
								break
							}
							position += 1
						}
						if var targetChat = targetChat {
							targetChat["latest_message"] = updateValue
							currentUserChats[position] = targetChat
							databaseEntryChat = currentUserChats
						} else {
							let newChatData: [String:Any] = [
								"id": chatId,
								"other_user_email": recipientSafeEmail,
								"name": name,
								"latest_message": updateValue
							]
							currentUserChats.append(newChatData)
							databaseEntryChat = currentUserChats
						}
					} else {
						let newChatData: [String:Any] = [
							"id": chatId,
							"other_user_email": recipientSafeEmail,
							"name": name,
							"latest_message": updateValue
						]
						databaseEntryChat = [
							newChatData
						]
					}
					
					self.database.child("\(currentUserSafeEmail)/chats").setValue(databaseEntryChat) { error,_ in
						guard error == nil else {
							completion(false)
							return
						}
						
						self.database.child("\(recipientSafeEmail)/chats").observeSingleEvent(of: .value) { snapshot in
							
							var databaseEntryChat = [[String:Any]]()
							let updateValue: [String:Any] = [
								"date": newMessage.sentDate.fullDateStringForDB,
								"is_read": false,
								"message": messageContent
							]
							
							if var currentUserChats = snapshot.value as? [[String:Any]] {
								var targetChat: [String:Any]?
								var position = 0
								
								for chatDictionary in currentUserChats {
									if let currentId = chatDictionary["id"] as? String, currentId == chatId {
										targetChat = chatDictionary
										break
									}
									position += 1
								}
								if var targetChat = targetChat {
									targetChat["latest_message"] = updateValue
									currentUserChats[position] = targetChat
									databaseEntryChat = currentUserChats
								} else {
									let newChatData: [String:Any] = [
										"id": chatId,
										"other_user_email": recipientSafeEmail,
										"name": name,
										"latest_message": updateValue
									]
									currentUserChats.append(newChatData)
									databaseEntryChat = currentUserChats
								}
							} else {
								let newChatData: [String:Any] = [
									"id": chatId,
									"other_user_email": recipientSafeEmail,
									"name": name,
									"latest_message": updateValue
								]
								databaseEntryChat = [
									newChatData
								]
							}
							self.database.child("\(recipientSafeEmail)/chats").setValue(databaseEntryChat) { error,_ in
								guard error == nil else {
									completion(false)
									return
								}
								completion(true)
							}
						}
					}
				}
			}
		}
	}
	
	private func finishCreatingChat(name: String, chatId: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
		var content = ""
		
		switch firstMessage.kind {
		case .text(let messageText):
			content = messageText
		default:
			break
		}
		
		guard let currentEmail = UserProfile.defaults.email else {
			completion(false)
			return
		}
		let safeEmail = currentEmail.safeEmail
		let message: [String:Any] = [
			"id": firstMessage.messageId,
			"type": firstMessage.kind.rawValue,
			"content": content,
			"date": firstMessage.sentDate.fullDateStringForDB,
			"sender_email": safeEmail,
			"is_read": false,
			"name": name
		]
		let value: [String:Any] = [
			"messages": [
				message
			]
		]
		
		database.child("\(chatId)").setValue(value) { error, _ in
			guard error == nil else {
				completion(false)
				return
			}
			completion(true)
		}
	}
}

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
