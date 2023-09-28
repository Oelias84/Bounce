//
//  UsersListViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 18/05/2022.
//

import UIKit
import Foundation
import FirebaseAuth
import MessageKit

enum UserFilterType {
    
    case allUsers
    case programActive
    case programExpired
    case programExpiredSoon
    case didNotUpdateWorkout
    case searchBy(name: String)
    case notLoggedFor(days: Int? = 3)
}

enum BroadcastType {
    
    case selective
    case allFilterd
}

class UsersListViewModel {
    
    private var currentFilter: UserFilterType = .allUsers
    
    private var originalUsers: [UserViewModel]?
    private var selectedBroadcastUser: [UserViewModel] = []
    
    private let parentVC: UIViewController!
    private let messagesManager = MessagesManager.shared
    private var didFetchIsExpired = false
    
    public var isBroadcastSelection: BroadcastType? {
        didSet {
            if isBroadcastSelection == .selective {
                originalUsers?.forEach { $0.shouldShowBrodcast = true }
            } else {
                originalUsers?.forEach { $0.shouldShowBrodcast = false }
            }
        }
    }
    public var filteredUsers: UiKitObservableObject<[UserViewModel]?> = UiKitObservableObject(nil)

    init(parentVC: UIViewController) {
        self.parentVC = parentVC
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.getChats() {
                self.filterUsers(with: self.currentFilter)
            }
        }
    }
    
    func addOrRemoveSelectedUser(_ userViewModel: UserViewModel) {
        if let containdUserIndex = selectedBroadcastUser.firstIndex(where: { $0.userId == userViewModel.userId }) {
            selectedBroadcastUser.remove(at: containdUserIndex)
        } else {
            selectedBroadcastUser.append(userViewModel)
        }
    }
    func removeAllbroadcastUsers() {
        selectedBroadcastUser.removeAll()
    }
    
    //MARK: - Getters
    var chatsCount: Int? {
        filteredUsers.value?.count
    }
    var showOnlyActive: Bool {
        get {
            let userDefaults = UserDefaults.standard
            var showOnlyActive = true
            
            if let value = userDefaults.value(forKey: "showOnlyActive") as? Bool {
                showOnlyActive = value
                return showOnlyActive
            } else {
                userDefaults.set(true, forKey: "showOnlyActive")
                return showOnlyActive
            }
        }
        set {
            let userDefaults = UserDefaults.standard
            userDefaults.set(newValue, forKey: "showOnlyActive")
        }
    }
    public func userViewModel(row: Int) -> UserViewModel {
        filteredUsers.value![row]
    }
    public func filterUsers(with term: UserFilterType) {
        Spinner.shared.stop()
        guard let users = originalUsers else { return }
        currentFilter = term
        
        let usersViewModels = users.filter {
            //Filter active users if needed
            return showOnlyActive ? !($0.programState == .expire || $0.programState == nil) : true
        }
        
        let results = usersViewModels.filter { user in
            switch term {
            case .didNotUpdateWorkout:
                return true
            case .searchBy(let filteredName):
                let name = user.userName?.lowercased() ?? ""
                return name.contains(filteredName.lowercased())
            case .notLoggedFor(_):
                return user.wasSeenLately == false && user.programState != .expire && user.programState != nil
            case .programActive:
                return user.programState == .active || user.programState == .expireSoon
            case .programExpired:
                return user.programState == .expire || user.programState == nil
            case .programExpiredSoon:
                return user.programState == .expireSoon
            case .allUsers:
                return true
            }
        }
        
        //Get chats for unread messages
        //Sort by the newest message at the top
        let unreadMessagesUsers = results.filter { !$0.didReadLastMessage }.sorted()
        
        //Get chats for read messages
        //Sort by the newest message at the top
        let readMessagesUsers = results.filter { $0.didReadLastMessage }.sorted()
        
        filteredUsers.value = unreadMessagesUsers + readMessagesUsers
    }
    
    //MARK: - Filter menu
    var filterMenu: UIMenu {
        UIMenu(title: "מיין לפי:", image: nil, identifier: nil, options: [], children: filterItems)
    }
    private var filterItems: [UIAction] {
        
        var actions = [
            UIAction(title: "כל היוזרים") { _ in
                self.filterUsers(with: .allUsers)
            },
            UIAction(title: "לא נראו 3 ימים", image:  UIImage(systemName: "person.fill.questionmark")) { _ in
                self.filterOrFetch(filter: .notLoggedFor())
            },
            UIAction(title: "לפני סיום מנוי", image: UIImage(systemName: "clock.badge.exclamationmark")) { _ in
                self.filterOrFetch(filter: .programExpiredSoon)
            }
        ]
        
        if !showOnlyActive {
            actions.append( UIAction(title: "מנויים לא פעילים") { _ in
                self.filterOrFetch(filter: .programExpired)
            })
            actions.append( UIAction(title: "מנויים פעילים") { _ in
                self.filterOrFetch(filter: .programActive)
            })
        }
        return actions
    }
    
    //MARK: - Broadcast message
    public func removeBrodcastSelection() {
        selectedBroadcastUser = []
        originalUsers?.forEach { $0.shouldBroadcast = false }
    }
    public func sendBroadcastMessage(type: MessageKind, completion: @escaping (Error?) -> ()) {
        Spinner.shared.show()
        
        var broadcastUsers: [UserViewModel] {
            switch isBroadcastSelection {
            case .selective:
                return selectedBroadcastUser
            case .allFilterd:
                return filteredUsers.value ?? []
            case nil:
                return []
            }
        }
        print(broadcastUsers.count)
        guard !broadcastUsers.isEmpty else {
            completion(ErrorManager.DatabaseError.dataIsEmpty)
            return
        }
        MessagesManager.shared.postBroadcast(messageKind: type,
                                             for: broadcastUsers,
                                             completion: completion)
    }
    public func getMediaUrlFor(_ urlString: String, completion: @escaping (URL?) -> ()) {
        MessagesManager.shared.downloadMediaURL(urlString: urlString, completion: completion)
    }

    
    //MARK: - Fetch data
    fileprivate func getChats(completion: @escaping ()->()) {
        
        messagesManager.chats.bind() {
            [weak self] chats in
            guard let self = self else { return }
            
            if !chats.isEmpty {
                if var users = self.originalUsers {
                    chats.forEach { chat in
                        //Happens on data base live changes
                        //If user exist in the list will update its latest message and latest seen
                        //Else add the user
                        if let oldChat = users.first(where: { $0.userId == chat.userId }) {
                            oldChat.chat.commentLastSeen = chat.commentLastSeen
                        } else {
                            users.append(UserViewModel(chat))
                        }
                    }
                } else {
                    self.originalUsers = chats.map({UserViewModel($0)})
                }
                completion()
            }
        }
    }
    fileprivate func filterOrFetch(filter: UserFilterType) {
        if self.didFetchIsExpired {
            self.filterUsers(with: filter)
        } else {
            Spinner.shared.show(self.parentVC.view)
            
            DispatchQueue.global(qos: .userInteractive).async {
                self.messagesManager.addIsExpired {
                    self.filterUsers(with: filter)
                    self.didFetchIsExpired = true
                    Spinner.shared.stop()
                }
            }
        }
    }
}
