//
//  UsersListViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 18/05/2022.
//

import UIKit
import Foundation
import FirebaseAuth

enum UserFilterType {
    
    case allUsers
    case programActive
    case programExpired
    case programExpiredSoon
    case didNotUpdateWorkout
    case searchBy(name: String)
    case notLoggedFor(days: Int? = 3)
}

class UsersListViewModel {
    
    private var currentFilter: UserFilterType = .allUsers
    
    private var originalUsers: [UserViewModel]?
    private var selectedUsers: [UserViewModel] = []
    public var filteredUsers: ObservableObject<[UserViewModel]?> = ObservableObject(nil)
    
    private let parentVC: UIViewController!
    private let messagesManager = MessagesManager.shared
    private var didFetchIsExpired = false
    
    
    init(parentVC: UIViewController) {
        self.parentVC = parentVC
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.getChats() {
                self.filterUsers(with: self.currentFilter)
            }
        }
    }
    
    func addSelectedUser(user: UserViewModel) {
        selectedUsers.append(user)
    }
    func removeSelectedUser(user: UserViewModel) {
        selectedUsers.removeAll(where: { $0.userId == user.userId })
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
            //			UIAction(title: "הודעות שנקראו") { _ in
            //				self.filterUsers(with: .readMassages)
            //			},
            UIAction(title: "לא נראו 3 ימים", image:  UIImage(systemName: "person.fill.questionmark")) { _ in
                self.filterOrFetch(filter: .notLoggedFor())
            },
            UIAction(title: "מנויים פעילים") { _ in
                self.filterOrFetch(filter: .programActive)
            },
            UIAction(title: "לפני סיום מנוי", image: UIImage(systemName: "clock.badge.exclamationmark")) { _ in
                self.filterOrFetch(filter: .programExpiredSoon)
            }
        ]
        
        if !showOnlyActive {
            actions.append( UIAction(title: "מנויים לא פעילים") { _ in
                self.filterOrFetch(filter: .programExpired)
            })
        }
        return actions
    }
    
    //MARK: - Broadcast message
    public func sendBroadcastMessage(text: String) {
        guard let usersChats = filteredUsers.value else { return }
        MessagesManager.shared.postBroadcast(text: text, for: usersChats)
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
                        if var oldChat = users.first(where: { $0.userId == chat.userId }) {
                            oldChat.latestMessage = chat.latestMessage
                            oldChat.lastSeenMessageDate = chat.lastSeenMessageDate
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
