//
//  ChatViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 05/02/2021.
//

import UIKit
import MessageKit
import SDWebImage
import CropViewController
import InputBarAccessoryView

class ChatViewController: MessagesViewController {
	
	var isNewChat = false
	var chatId: String!
	var otherUserEmail: String!
	var otherTokens: [String]!
	
	private let imagePickerController = UIImagePickerController()
	private var messages = [Message]()
	
	private var selfSender: Sender? = {
		guard let email = UserProfile.defaults.email,
			  let name = UserProfile.defaults.name else {
			return nil
		}
		return Sender(senderId: email.safeEmail, displayName: name)
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupController()
		setupInputButton()
	}
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		messageInputBar.inputTextView.becomeFirstResponder()
		if let chatId = chatId {
			self.listenToMessages(id: chatId, shouldScrollToBottom: true)
		}
	}
}

//MARK: - Delegats
extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, MessageCellDelegate {
	
	func currentSender() -> SenderType {
		if let sender = selfSender {
			return sender
		}
		fatalError("Self Sender in nil, email should cached")
	}
	func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
		messages.count
	}
	func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
		messages[indexPath.section]
	}
	func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
		guard let message = message as? Message else {
			return
		}
		switch message.kind {
		case .photo(let media):
			guard let imageUrl = media.url else {
				return
			}
			imageView.sd_setImage(with: imageUrl)
		default:
			break
		}
	}
	
	func didTapImage(in cell: MessageCollectionViewCell) {
		messagesCollectionView.endEditing(true)
		guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
		let message = messages[indexPath.section]
		switch message.kind {
		case .photo(let media):
			guard let imageUrl = media.url else {
				return
			}
			let photoViewr = PhotoViewerViewController(with: imageUrl)
			navigationController?.pushViewController(photoViewr, animated: true)
		default:
			break
		}
	}
	func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
		return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
	}
}

extension ChatViewController: InputBarAccessoryViewDelegate {
	
	func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
		Spinner.shared.show(view)
		inputBar.sendButton.isEnabled = false

		
		guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
			  let messageId = createMessageId(), let selfSender = selfSender else { return }
		let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
		
		if isNewChat {
			GoogleDatabaseManager.shared.createNewChat(with: otherUserEmail, otherUserTokens: otherTokens, name: title ?? "User", firstMessage: message) {
				[weak self] success in
				guard let self = self else { return }
				
				if success {
					print("sent")
					self.isNewChat = false
					self.messageInputBar.inputTextView.text = ""
					self.messagesCollectionView.scrollToLastItem()
					self.sendNotification(with: text)
					self.navigationController?.popViewController(animated: true)
				} else {
					print("not sent")
				}
				inputBar.sendButton.isEnabled = true
			}
		} else {
			guard let chatId = chatId, let name = (UserProfile.defaults.isManager ?? false) ? "דברי אלינו" : UserProfile.defaults.name  else { return }
			GoogleDatabaseManager.shared.sendMessage(to: chatId, otherUserEmail: otherUserEmail, newMessage: message, name: name) {
				[weak self] success in
				guard let self = self else { return }
				
				if success {
					print("sent")
					self.messageInputBar.inputTextView.text = ""
					self.messagesCollectionView.scrollToLastItem()
					self.sendNotification(with: text)
				} else {
					print("not sent")
				}
				inputBar.sendButton.isEnabled = true
			}
		}
	}
}

extension ChatViewController: CropViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
	
	//Image Picker
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		let tempoImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
		
		picker.dismiss(animated: true)
		presentCropViewController(image: tempoImage, type: .default)
	}
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true)
	}
	
	//Image Crop
	func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) { 
		cropViewController.dismiss(animated: true) {
			
			guard let messageId = self.createMessageId(),
				  let chatId = self.chatId,
				  let name = self.title else { return }
			
			let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".jpeg"
			
			GoogleStorageManager.shared.uploadImage(from: .messagesImage, data: image.jpegData(compressionQuality: 8)!, fileName: fileName) {
				[weak self] result in
				guard let self = self else { return }
				
				
				switch result {
				case .success(let urlString):
					guard let url = URL(string: urlString),
						  let placeholder = UIImage(systemName: "plus"),
						  let selfSender = self.selfSender else {
						return
					}
					
					let media = Media(url: url, image: nil, placeholderImage: placeholder, size: .zero)
					let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .photo(media))
					
					GoogleDatabaseManager.shared.sendMessage(to: chatId, otherUserEmail: self.otherUserEmail, newMessage: message, name: name) { success in
						
						if success {
							
						} else {
							
						}
					}
				case .failure(let error):
					print("message photo upload error:", error)
				}
			}
		}
	}
}

//MARK: - Functions
extension ChatViewController {
	
	private func setupController() {
		navigationItem.largeTitleDisplayMode = .never
		showMessageTimestampOnSwipeLeft = true
		messagesCollectionView.messagesDataSource = self
		messagesCollectionView.messagesLayoutDelegate = self
		messagesCollectionView.messagesDisplayDelegate = self
		messagesCollectionView.messageCellDelegate = self
		messageInputBar.delegate = self
		imagePickerController.delegate = self
	}
	private func setupInputButton() {
		let button = InputBarButtonItem()
		
		button.setSize(CGSize(width: 35, height: 35), animated: false)
		button.setImage(UIImage(systemName: "camera"), for: .normal)
		button.onTouchUpInside { [weak self] _ in
			guard let self = self else { return }
			self.presentImagePickerActionSheet(imagePicker: self.imagePickerController) {_ in}
		}
		messageInputBar.sendButton.title = "שלח"
		messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
		messageInputBar.setStackViewItems([button], forStack: .left, animated: true)
	}
	private func createMessageId() -> String? {
		guard let currentUserEmail = UserProfile.defaults.email else { return nil }
		let identifier = "\(otherUserEmail)_\(currentUserEmail.safeEmail)_\(Date().fullDateStringForDB)"
		return identifier
	}
	private func sendNotification(with text: String) {
		let notification = PushNotificationSender()
		let userName = UserProfile.defaults.name!
		
		if let tokens = self.otherTokens {
			tokens.forEach {
				notification.sendPushNotification(to: $0, title: "הודעה נשלחה מ-" + (userName), body: text)
			}
		}
	}
	private func listenToMessages(id: String, shouldScrollToBottom: Bool) {
		GoogleDatabaseManager.shared.getAllMessagesForChat(with: id) { [weak self] result in
			guard let self = self else { return }
			
			switch result {
			case .success(let messages):
				if messages.isEmpty {
					return
				}
				self.messages = messages
				DispatchQueue.main.async { [weak self] in
					guard let self = self else { return }
					if shouldScrollToBottom {
						self.messagesCollectionView.reloadData()
						self.messagesCollectionView.scrollToLastItem()
					} else {
						self.messagesCollectionView.reloadDataAndKeepOffset()
					}
				}
			case .failure(let error):
				print("faild to fetch messages:", error)
			}
		}
	}
}
