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
import JGProgressHUD
import CropViewController
import InputBarAccessoryView

final class ChatViewController: MessagesViewController {
	
	var viewModel: ChatViewModel!
	
	fileprivate let hud = JGProgressHUD()
	fileprivate let isAdmin: Bool = UserProfile.defaults.getIsManager
	fileprivate let refreshControl = UIRefreshControl()
	fileprivate let imagePickerController = UIImagePickerController()
	fileprivate var ifFirstLoad = true

	init(viewModel: ChatViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		bindViewModel()
		setupController()
		setupInputButton()
	}
	@IBAction func closeButtonAction(_ sender: Any) {
		dismiss(animated: true)
	}
}

//MARK: - Delegats
extension ChatViewController: InputBarAccessoryViewDelegate {
    
	func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
		disableInteraction()

		guard !text.replacingOccurrences(of: " ", with: "").isEmpty else {
			self.disableInteraction()
			return
		}
		
		viewModel.sendMessage(messageKind: .text(text)) {
			[weak self] error in
			guard let self = self else { return }
			
			if let error = error {
				self.presentOkAlert(withTitle: "אופס",withMessage: "שליחת הודעה נכשלה")
				print("Error:", error.localizedDescription)
				return
			}
			self.messageInputBar.inputTextView.text = nil
		}
	}
}

//Messages
extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, MessageCellDelegate {
    
    var currentSender: SenderType {
       if let sender = viewModel.getSelfSender {
           return sender
       }
       fatalError("Self Sender in nil, email should cached")
    }
	func isFromCurrentSender(message: MessageType) -> Bool {
		if isAdmin {
			return message.sender.senderId != viewModel.getChatUserId
		}
        return message.sender.senderId == currentSender.senderId
	}
	
	//Collection view dataSource
	func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
		viewModel.messagesCount
	}
	func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
		viewModel.getMessageAt(indexPath)
	}
	func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
		guard let message = message as? Message else {
			return
		}
		switch message.kind {
		case .photo(let media), .video(let media):
			imageView.image = media.placeholderImage
		default:
			break
		}
	}
	func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
		
		//Name Config
		let presentingName: String = {
			if message.sender.senderId != viewModel.getChatUserId {
				return "B"
			} else {
				let senderName = isAdmin ? viewModel.getDisplayName?.splitFullName : UserProfile.defaults.name?.splitFullName
				let presentingInitials = "\(senderName?.0.first ?? " ")\(senderName?.1.first ?? " ")"
				return presentingInitials
			}
		}()

		//Avatar Config
		if isAdmin {
			avatarView.backgroundColor = message.sender.senderId == viewModel.getChatUserId  ? .projectIncomingMessageBubble : .projectOutgoingMessageBubble
		} else {
			avatarView.backgroundColor = message.sender.senderId != currentSender.senderId ? .projectIncomingMessageBubble : .projectOutgoingMessageBubble
		}
		avatarView.placeholderFont = UIFont(name: "Assistant-Regular", size: 12)!
		avatarView.placeholderTextColor = .black
		avatarView.initials = presentingName
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
	func didTapMessage(in cell: MessageCollectionViewCell) {
		guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
		let message = viewModel.getMessageAt(indexPath)
		switch message.kind {
		case .linkPreview(let linkItem):
			UIApplication.shared.open(linkItem.url)
		default:
			break
		}
	}
	func didTapImage(in cell: MessageCollectionViewCell) {
		messagesCollectionView.endEditing(true)
		guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
		let message = viewModel.getMessageAt(indexPath)
		
		switch message.kind {
		case .photo(let media):
			guard let media = media as? Media, let imageUrl = media.mediaURLString else { return }
			presentImageFor(imageUrl)
		case .video(let media):
			guard let media = media as? Media, let videoUrl = media.mediaURLString else { return }
			presentVideoFor(videoUrl)
		default:
			break
		}
	}
}

extension ChatViewController: CropViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		
		picker.dismiss(animated: true) {
			
			//Image Picker
			if let image = info[.originalImage] as? UIImage {
				self.presentCropViewController(image: image, type: .default)
				
				//Video Picker
			} else if let videoUrl = info[.mediaURL] as? URL  {
				guard let placeholder = MessagesManager.generateThumbnailFrom(videoURL: videoUrl) else { return }
				let media = Media(url: videoUrl, image: nil, placeholderImage: placeholder, size: .zero)
				
				self.disableInteraction()
				self.viewModel.sendMessage(messageKind: .video(media)) {
					[weak self] error in
					guard let self = self else { return }
					
					if let error = error {
						self.presentOkAlert(withTitle: "אופס",withMessage: "שליחת תמונה נכשלה")
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
					self.presentOkAlert(withTitle: "אופס",withMessage: "שליחת וידאו נכשלה")
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
	
	fileprivate func bindViewModel() {
		messageInputBar.alpha = 0
		messagesCollectionView.alpha = 0
		disableInteraction()

		viewModel.messages.bind {
			messages in

			if messages == nil {
				self.ableInteraction()
			} else {
				DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
					self.ableInteraction()
					self.messagesCollectionView.reloadDataAndKeepOffset()
					
					if self.ifFirstLoad {
						UIView.animate(withDuration: 0.5) {
							self.messageInputBar.alpha = 1
							self.messagesCollectionView.alpha = 1
						}
						self.messagesCollectionView.scrollToLastItem(animated: false)
					} else {
						self.refreshControl.endRefreshing()
					}
				}
			}
		}
	}
	fileprivate func setupController() {
        maintainPositionOnInputBarHeightChanged = true
		showMessageTimestampOnSwipeLeft = true
		title = self.viewModel.getDisplayName
		navigationItem.largeTitleDisplayMode = .never
		
		messageInputBar.delegate = self
		messageInputBar.inputTextView.font = UIFont(name: "Assistant-Regular", size: 18)!
		messageInputBar.maxTextViewHeight = 96
		messageInputBar.shouldAutoUpdateMaxTextViewHeight = false
		
		imagePickerController.delegate = self
		messagesCollectionView.scrollsToTop = false
		messagesCollectionView.messagesDataSource = self
		messagesCollectionView.messageCellDelegate = self
		messagesCollectionView.messagesLayoutDelegate = self
		messagesCollectionView.messagesDisplayDelegate = self
		
		messagesCollectionView.addSubview(refreshControl)
		refreshControl.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
	}
	fileprivate func setupInputButton() {
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
	
	fileprivate func presentInputActionSheet() {
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
	fileprivate func presentVideoInputActionSheet() {
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
		actionSheet.addAction(UIAlertAction(title: "גלריה", style: .default, handler: { [weak self] _ in
			
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
	
	fileprivate func presentImageFor(_ urlString: String) {
		DispatchQueue.global(qos: .userInteractive).async {
			self.viewModel.getMediaUrlFor(urlString) {
				[weak self] url in
				guard let self = self else {
					self?.disableInteraction()
					return
				}
				self.ableInteraction()
				
				DispatchQueue.main.async {
					if let url = url {
						let photoViewer = PhotoViewerViewController(with: url)
						self.parent?.present(photoViewer, animated: true)
					} else {
						self.presentOkAlert(withTitle: "אופס!", withMessage: "נראה שאין אפשרות להציג תמונה זאת", buttonText: "סגירה")
					}
				}
			}
		}
	}
	fileprivate func presentVideoFor(_ urlString: String) {
		DispatchQueue.global(qos: .userInteractive).async {
			self.viewModel.getMediaUrlFor(urlString) {
				[weak self] url in
				guard let self = self else {
					self?.disableInteraction()
					return
				}
				
				self.ableInteraction()
				DispatchQueue.main.async {
					if let url = url {
						let videoVC = AVPlayerViewController()
						
						videoVC.player = AVPlayer(url: url)
						self.parent?.present(videoVC, animated: true)
						videoVC.player?.play()
					} else {
						self.presentOkAlert(withTitle: "אופס!", withMessage: "נראה שהסירטון אינו זמין לצפייה", buttonText: "סגירה")
					}
				}
			}
		}
	}
	fileprivate func disableInteraction() {
		if let view = navigationController?.view {
			Spinner.shared.show(view)
		}
	}
	fileprivate func ableInteraction() {
		DispatchQueue.main.async {
			UIView.animate(withDuration: 0.5) {
				Spinner.shared.stop()
				self.messageInputBar.alpha = 1
				self.messagesCollectionView.alpha = 1
			}
		}
	}
	
	@objc fileprivate func loadMoreMessages() {
		DispatchQueue.global(qos: .userInteractive).async {
			self.viewModel.listenToMessages()
		}
		ifFirstLoad = false
	}
}
