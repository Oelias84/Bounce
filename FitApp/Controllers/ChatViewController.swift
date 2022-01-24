//
//  ChatViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 05/02/2021.
//

import UIKit
import AVKit
import MessageKit
import SDWebImage
import FirebaseAuth
import AVFoundation
import CropViewController
import InputBarAccessoryView

class ChatViewController: MessagesViewController {
	
	private var viewModel: ChatViewModel!
	
	private let isAdmin: Bool = UserProfile.defaults.getIsManager
	private let imagePickerController = UIImagePickerController()
	
	init(viewModel: ChatViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
		
		self.setupController()
		self.setupInputButton()
	}
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		loadFirstMessages()
	}
}

//MARK: - Delegats
//Text Message
extension ChatViewController: InputBarAccessoryViewDelegate {
	
	func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
		disableInteraction()
		
		guard !text.replacingOccurrences(of: " ", with: "").isEmpty else {
			Spinner.shared.stop()
			return
		}
		
		viewModel.sendMessage(messageKind: .text(text)) {
			[weak self] error in
			guard let self = self else { return }
			
			if let error = error {
				#warning("Handel Error")
				print("Error:", error.localizedDescription)
				return
			}
			self.ableInteraction()
			self.messageInputBar.inputTextView.text = ""
		}
	}
}
//Media Messages
extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, MessageCellDelegate {
	
	func currentSender() -> SenderType {
		if let sender = viewModel.getSelfSender {
			return sender
		}
		fatalError("Self Sender in nil, email should cached")
	}
	
	//Collection view dataSource
	func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
		viewModel.messagesCount
	}
	func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
		viewModel.getMessageAt(indexPath)
	}
	func configureAccessoryView(_ accessoryView: UIView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
		accessoryView.backgroundColor = .red
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
		case .video(let media):
			imageView.image = media.placeholderImage
		default:
			break
		}
	}
	func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
		let name = message.sender.displayName.splitFullName
		
		let presentingInitials = "\(name.0.first ?? "N")\(name.1.first ?? "A")"
		avatarView.initials = presentingInitials
	}
	
	//Custom cell view
	func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
		.black
	}
	func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
		isFromCurrentSender(message: message) ? UIColor.projectOutgoingMessageBubble : UIColor.projectIncomingMessageBubble
	}
	func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
		switch message.kind {
		case .text:
			let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
			return .bubbleTail(corner, .curved)
		default:
			return .bubble
		}
	}
	//Cell delegate
	func didTapImage(in cell: MessageCollectionViewCell) {
		messagesCollectionView.endEditing(true)
		guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
		let message = viewModel.getMessageAt(indexPath)
		
		switch message.kind {
		case .photo(let media):
			guard let imageUrl = media.url else { return }
			presentImageFor(imageUrl)
		case .video(let media):
			guard let videoUrl = media.url else { return }
			presentVideoFor(videoUrl)
		default:
			break
		}
	}
}
extension ChatViewController: CropViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
	
	//Image Picker
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		
		picker.dismiss(animated: true) {
			if let image = info[.originalImage] as? UIImage {
				self.presentCropViewController(image: image, type: .default)
				
			} else if let videoUrl = info[.mediaURL] as? URL  {
				guard let placeholder = MessagesManager.generateThumbnailFrom(videoURL: videoUrl) else { return }
				let media = Media(url: videoUrl, image: nil, placeholderImage: placeholder, size: .zero)
				
				self.disableInteraction()
				self.viewModel.sendMessage(messageKind: .video(media)) {
					[weak self] error in
					guard let self = self else { return }
					
					if let error = error {
#warning("Handel Error")
						print("Error:", error)
						return
					}
					self.ableInteraction()
				}
			}
		}
	}
	//Image Crop
	func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
		
		cropViewController.dismiss(animated: true) {
			let media = Media(url: nil, image: image, placeholderImage: image, size: .zero)
			
			self.disableInteraction()
			self.viewModel.sendMessage(messageKind: .photo(media)) {
				[weak self] error in
				guard let self = self else { return }
				
				if let error = error {
#warning("Handel Error")
					print("Error:", error)
					return
				}
				self.ableInteraction()
			}
		}
	}
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true)
	}
}

//MARK: - Functions
extension ChatViewController {
	
	private func setupController() {
		
		showMessageTimestampOnSwipeLeft = true
		
		messageInputBar.delegate = self
		imagePickerController.delegate = self
		messagesCollectionView.messagesDataSource = self
		messagesCollectionView.messageCellDelegate = self
		messagesCollectionView.messagesLayoutDelegate = self
		messagesCollectionView.messagesDisplayDelegate = self
	}
	private func setupInputButton() {
		let button = InputBarButtonItem()
		
		button.setSize(CGSize(width: 35, height: 35), animated: false)
		button.setImage(UIImage(systemName: "camera"), for: .normal)
		button.onTouchUpInside {
			[weak self] _ in
			guard let self = self else { return }
			self.presentInputActionSheet()
		}
		messageInputBar.sendButton.title = StaticStringsManager.shared.getGenderString?[26]
		messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
		messageInputBar.setStackViewItems([button], forStack: .left, animated: true)
	}
	
	private func presentInputActionSheet() {
		let actionSheet = UIAlertController(title: "ייבוא מדיה",
											message: "בחר סוג מדיה",
											preferredStyle: .actionSheet)
		actionSheet.addAction(UIAlertAction(title: "תמונה", style: .default, handler: { [weak self] _ in
			self?.presentImagePickerActionSheet(imagePicker: self!.imagePickerController) {_ in}
		}))
		actionSheet.addAction(UIAlertAction(title: "וידאו", style: .default, handler: { [weak self]  _ in
			self?.presentVideoInputActionSheet()
		}))
		actionSheet.addAction(UIAlertAction(title: "ביטול", style: .cancel, handler: nil))
		
		present(actionSheet, animated: true)
	}
	private func presentVideoInputActionSheet() {
		let actionSheet = UIAlertController(title: "יבוא וידאו",
											message: "מהיכן תרצה לייבא?",
											preferredStyle: .actionSheet)
		actionSheet.addAction(UIAlertAction(title: "מצלמה", style: .default, handler: { [weak self] _ in
			
			let picker = UIImagePickerController()
			picker.sourceType = .camera
			picker.delegate = self
			picker.mediaTypes = ["public.movie"]
			picker.videoQuality = .typeMedium
			picker.allowsEditing = true
			self?.present(picker, animated: true)
			
		}))
		actionSheet.addAction(UIAlertAction(title: "ספרייה", style: .default, handler: { [weak self] _ in
			
			let picker = UIImagePickerController()
			picker.sourceType = .photoLibrary
			picker.delegate = self
			picker.allowsEditing = true
			picker.mediaTypes = ["public.movie"]
			picker.videoQuality = .typeMedium
			self?.present(picker, animated: true)
			
		}))
		actionSheet.addAction(UIAlertAction(title: "ביטול", style: .cancel, handler: nil))
		
		present(actionSheet, animated: true)
	}
	
	private func presentImageFor(_ url: URL) {
		let photoViewer = PhotoViewerViewController(with: url)
		
		self.parent?.present(photoViewer, animated: true)
	}
	private func presentVideoFor(_ url: URL) {
		let videoVC = AVPlayerViewController()
		
		videoVC.player = AVPlayer(url: url)
		self.parent?.present(videoVC, animated: true)
		videoVC.player?.play()
	}
	
	private func disableInteraction() {
		Spinner.shared.show(view)
		messageInputBar.isUserInteractionEnabled = false
	}
	private func ableInteraction() {
		Spinner.shared.stop()
		messageInputBar.isUserInteractionEnabled = true
	}
	
	private func loadFirstMessages() {
		var firstLoad = true
		viewModel.listenToMessages {
			DispatchQueue.global(qos: .userInitiated).async {
				DispatchQueue.main.async {
					if firstLoad {
						firstLoad = false
						Spinner.shared.stop()
						self.messagesCollectionView.reloadData()
						self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: false)
					} else {
						self.insertMessage()
					}
				}
			}
		}
	}
	private func insertMessage() {
		DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1) {
			DispatchQueue.main.async {
				self.messagesCollectionView.reloadDataAndKeepOffset()
			}
		}
	}
	private func isLastSectionVisible() -> Bool {
		guard viewModel.getAllMassages.isEmpty else { return false }
		
		let count = self.viewModel.messagesCount
		let lastIndexPath = IndexPath(item: 0, section: count - 1)
		return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
	}
}

