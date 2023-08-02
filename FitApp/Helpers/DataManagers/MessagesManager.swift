//
//  MessagesManager.swift
//  FitApp
//
//  Created by Ofir Elias on 22/09/2021.
//

import UIKit
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
    fileprivate let googleFirestore = GoogleApiManager.shared
    fileprivate let googleStorageManager = GoogleStorageManager.shared
    
    var chats: UiKitObservableObject<[Chat]> = UiKitObservableObject([Chat]())
    
    private let userId = Auth.auth().currentUser?.uid
    private let userEmail = UserProfile.defaults.email
    private let userName = UserProfile.defaults.name
    private let isAdmin = UserProfile.defaults.getIsManager
    
    var numberOfMessages: UInt = 10
    
    private init() {
        guard let userId = self.userId else { return }
        
        if chats.value.isEmpty {
            let queue = OperationQueue()
            
            DispatchQueue.global(qos: .userInitiated).sync {
                queue.addOperation {
                    if self.isAdmin {
                        self.fetchSupportChats()
                    } else {
                        self.fetchUserChat(userId: userId, isAdmin: self.isAdmin)
                    }
                }
                queue.addOperation {
                    // Update tokens
                    self.googleManager.updatePushToken(userId: userId, isAdmin: self.isAdmin)
                }
                queue.waitUntilAllOperationsAreFinished()
            }
        }
    }
}

//MARK: - Functions
extension MessagesManager {
    
    // Getters
    public func getUserChat() -> Chat? {
        guard let chat = chats.value.first else { return nil }
        return chat
    }
    public func getSupportChats() -> [Chat]? {
        guard !chats.value.isEmpty else { return nil }
        return chats.value
    }
    
    // Post
    public func postBroadcast(messageKind: MessageKind, for users: [UserViewModel], completion: @escaping (Error?) -> ()) {
        
        switch messageKind {
        case .text(let text):
            for user in users {
                DispatchQueue.global(qos: .userInteractive).async {
                    if user.programState == .expire { return }
                    self.sendTextMessageToChat(userID: user.userId, isAdmin: user.isAdmin, userPushToke: user.pushToken, text: text, completion: completion)
                }
            }
        case .photo(_), .video(_):
            for user in users {
                DispatchQueue.global(qos: .userInteractive).async {
                    self.sendMediaMessageFor(userID: user.userId, isAdmin: true, tokens: user.pushToken, messageKind: messageKind, completion: completion)
                }
            }
        default:
            break
        }

    }
    public func sendTextMessageToChat(userID: String, isAdmin: Bool, userPushToke: [String], text: String, completion: @escaping (Error?) -> ()) {
        
        googleManager.sendMessageToChat(userID: userID, isAdmin: isAdmin, content: text, kind: .text(text)) {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                completion(nil)
                guard let userName = self.userName, !userPushToke.isEmpty else { return }
                self.sendNotification(to: userPushToke, name: userName, text: text)
            case .failure(let error):
                
                completion(error)
                print("Error:", error.localizedDescription)
            }
        }
    }
    public func sendMediaMessageFor(userID: String, isAdmin: Bool, tokens: [String]?, messageKind: MessageKind, completion: @escaping (Error?) -> ()) {
        switch messageKind {
        case .photo(let media):
            guard let image = media.image,
                  let imageData = image.jpegData(compressionQuality: 0.2),
                  let fileName = remoteFileName(userId: userID, folderName: "messages_images", suffix: ".jpeg") else { return }
            
            //Send Photo message
            googleStorageManager.uploadImage(data: imageData, fileName: fileName) {
                result in
                
                switch result {
                case .success():
                    
                    guard let placeholder = image.jpegData(compressionQuality: 0.05) else { return }
                    let media = Media(url: nil, image: nil, mediaURLString: fileName, placeholderImage: image, size: .zero)
                    
                    self.googleManager.sendMessageToChat(userID: userID,
                                                         isAdmin: isAdmin,
                                                         content: "",
                                                         link: fileName,
                                                         previewData: placeholder,
                                                         kind: .photo(media)) {
                        [weak self] result in
                        guard let self = self else { return }
                        
                        switch result {
                            
                        case .success():
                            completion(nil)
                            guard let userName = self.userName, let otherUserPushTokens = tokens else { return }
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
            guard let media = media as? Media,
                  let fileUrl = media.url,
                  let fileName = remoteFileName(userId: userID, folderName: "messages_videos", suffix: ".mp4") else { return }
            
            //Send Video message
            googleStorageManager.uploadVideo(fileUrl: fileUrl, fileName: fileName) {
                [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(_):
                    guard let placeholder = MessagesManager.generateThumbnailFrom(videoURL: fileUrl) else { return }
                    let media = Media(url: nil, image: nil, mediaURLString: fileName, placeholderImage: placeholder, size: .zero)
                    
                    self.googleManager.sendMessageToChat(userID: userID,
                                                         isAdmin: isAdmin,
                                                         content: "",
                                                         link: fileName,
                                                         previewData: placeholder.jpegData(compressionQuality: 0.05),
                                                         kind: .video(media)) {
                        [weak self] result in
                        guard let self = self else { return }
                        
                        switch result {
                        case .success():
                            completion(nil)
                            guard let userName = self.userName, let otherUserPushTokens = tokens else { return }
                            self.sendNotification(to: otherUserPushTokens, name: userName, text: "הודעת וידאו")
                        case .failure(let error):
                            completion(error)
                            print("Error:", error.localizedDescription)
                        }
                    }
                case .failure(let error):
                    print("message video upload error:", error)
                }
            }
        default:
            return
        }
        
        func remoteFileName(userId: String, folderName: String, suffix: String) -> String? {
            return "\(userId)/\(folderName)/\(Date().millisecondsSince2020)\(suffix)"
        }
    }
    
    // Fetch Admin functions
    public func fetchSupportChats() {
        guard let userId = self.userId else { return }
        
        googleManager.getAllChats(userId: userId) {
            [weak self] chats in
            guard let self = self, !chats.isEmpty else { return }
            
            let group = DispatchGroup()
            
            for chat in chats {
                if chat.programExpirationDate == nil {
                    
                    group.enter()
                    self.googleFirestore.getUserOrderExpirationData(userID: chat.userId) {
                        result in
                        
                        switch result {
                        case .success(let programExpirationDate):
                            if chat.displayName == "אילנה" {
                                print()
                            }
                            chat.programExpirationDate = programExpirationDate
                        case .failure(let error):
                            print(error)
                        }
                        group.leave()
                    }
                }
                
                if let userLastSeen = chat.userLastSeen {
                    
                    group.enter()
                    self.getUserLastSeen(days: 3, userID: chat.userId) {
                        result in
                        switch result {
                        case .success(let userLastSeen):
                            chat.userLastSeen = userLastSeen
                        case .failure(let error):
                            print(error)
                        }
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                self.chats.value = chats
            }
        }
    }
    public func fetchMessagesFor(_ chat: Chat, completion: @escaping ([Message]?) -> ()) {
        self.googleManager.getAllMessagesForChat(toLast: self.numberOfMessages, chat: chat) {
            result in
            DispatchQueue.main.async {
                switch result {
                case .success(let messages):
                    completion(messages)
                case .failure(let error):
                    completion(nil)
                    print("Error:", error.localizedDescription)
                }
            }
        }
        self.numberOfMessages += self.numberOfMessages
    }
    public func addIsExpired(completion: @escaping ()->()) {
        guard !self.chats.value.isEmpty else {
            completion()
            return
        }
        
        let group = DispatchGroup()
        
        for user in self.chats.value {
            if user.programExpirationDate == nil {
                group.enter()
                self.googleFirestore.getUserOrderExpirationData(userID: user.userId) {
                    result in
                    
                    switch result {
                    case .success(let programExpirationDate):
                        user.programExpirationDate = programExpirationDate
                    case .failure(let error):
                        print(error)
                    }
                    group.leave()
                }
            }
        }
        group.wait()
        DispatchQueue.main.async {
            completion()
        }
    }
    
    // Fetch User functions
    fileprivate func fetchUserChat(userId: String, isAdmin: Bool) {
        //Get Chat If Exist
        googleManager.getChat(userId: userId, isAdmin: isAdmin) {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let chat):
                self.chats.value.append(chat)
                
            case .failure(let error):
                
                switch error {
                case .dataIsEmpty:
                    //If chat dose not exist, create new Chat
                    self.googleManager.createChat(userId: userId, isAdmin: self.isAdmin) {
                        [weak self] result in
                        guard let self = self else { return }
                        
                        switch result {
                        case .success(let chat):
                            self.chats.value.append(chat)
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
    fileprivate func sendNotification(to tokens: [String], name: String, text: String) {
        let notification = PushNotificationSender()
        
        var notificationTitle: String {
            return isAdmin ? "הודעה נשלחה מ BOUNCE" : "הודעה נשלחה מ- \(name)"
        }
        
        DispatchQueue.global(qos: .background).async {
            tokens.forEach {
                notification.sendPushNotification(to: $0, title: notificationTitle, body: text)
            }
        }
    }
    fileprivate func getUserLastSeen(days: Int, userID: String, completion: @escaping (Result<String?, Error>)->()) {
        googleFirestore.getUserLastSeenData(days: days, userID: userID, completion: completion)
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
    public func sendMassageToSupport(messageText: String) {
        guard let chat = chats.value.first else { return }
        
        sendTextMessageToChat(userID: chat.userId,
                              isAdmin: chat.isAdmin,
                              userPushToke: chat.pushTokens ?? [],
                              text: messageText) { error in
            if let error = error {
                print("Error: ", error.localizedDescription)
            }
        }
    }
    public func downloadMediaURL(urlString: String, completion: @escaping (URL?) ->()) {
        
        googleStorageManager.downloadURL(path: urlString) {
            result in
            
            switch result {
            case .success(let url):
                completion(url)
            case .failure(let error):
                completion(nil)
                print("no image exist", error)
            }
        }
    }
}
