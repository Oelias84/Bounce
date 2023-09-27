//
//  UserCommentsViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 03/07/2022.
//

import Foundation

class UserAdminCommentsViewModel {
	
	var comments: UiKitObservableObject<[UserAdminComment]?> = UiKitObservableObject(nil)
	private let userUID: String!
	
 	init(userUID: String) {
		self.userUID = userUID
		getComments(userUID: userUID)
	}
	
	var hasComments: Bool {
		comments.value?.count != 0 || comments.value?.count != nil
	}
	var getCommentsCount: Int {
		comments.value?.count ?? 0
	}
	func getCommentsFor(row: Int) -> UserAdminComment {
		comments.value![row]
	}
    func showUnreadComment(for index: Int) -> Bool {
        guard let currentAdminID = UserProfile.defaults.id else { return false }
        guard let currentAdminCommentLastRead = comments.value?[index].commentLastRead.dataList.first(where: {$0.userID == currentAdminID}) else { return true }
        guard let commentDate = comments.value?[index].commentDate.fullDateFromStringWithDash else { return false }
        
        return commentDate > currentAdminCommentLastRead.dateTime
    }
}

//MARK: - Functions
extension UserAdminCommentsViewModel {
	
	private func getComments(userUID: String) {
		GoogleApiManager.shared.getUserAdminComments(userUID: userUID) {
			[weak self] result in
			guard let self = self else { return }
			
			switch result {
			case .success(let data):
				self.comments.value = data?.comments.sorted()
			case .failure(let error):
				print("Error:", error.localizedDescription)
			}
		}
	}
    
	func createComment(with text: String, date: String? = nil, completion: ((Error?) -> Void)? = nil) {
		let currentDate = Date().fullDateStringForDB
		let comment = UserAdminComment(text: text, sender: UserProfile.defaults.name ?? "אין שם", commentDate: date ?? currentDate)
		
		if comments.value == nil {
			comments.value = [comment]
		} else {
			comments.value?.append(comment)
		}
		
		guard let comments = comments.value else { return }
		GoogleApiManager.shared.updateUserAdminComment(userUID: userUID, comments: UserAdminCommentsData(comments: comments), completion: completion)
        GoogleDatabaseManager.shared.updateUserCommentLastSeen(state: .update, for: self.userUID)
	}
	func removeComment(row: Int, completion: ((Error?) -> Void)? = nil) {
		guard let comments = comments.value else { return }
        
        GoogleApiManager.shared.removeUserAdminComment(userUID: userUID, comment: comments[row]) { error in
            if let error {
                completion?(error)
            }
        }
	}
	func updateComment(text: String, row: Int, completion: ((Error?) -> Void)? = nil) {
		guard let comments = comments.value else { return }
        let currentDate = Date().fullDateStringForDB

		comments[row].text = text
        comments[row].commentDate = currentDate
        GoogleApiManager.shared.updateUserAdminComment(userUID: userUID, comments: UserAdminCommentsData(comments: comments)) { error in
            if let error {
                completion?(error)
            }
            GoogleDatabaseManager.shared.updateUserCommentLastSeen(state: .update, for: self.userUID)
        }
	}
    func adminReadMessage(for index: Int) {
        guard let comments = comments.value else { return }
        let selectedComment = comments[index]
        
        guard let currentAdminID = UserProfile.defaults.id else { return }
        
        let readDate = Date().millisecondsSince2020
        let readData = CommentLastSeen(userID: currentAdminID, date: readDate)
        selectedComment.commentLastRead.dataList.append(readData)
        
        GoogleApiManager.shared.updateUserAdminComment(userUID: userUID, comments: UserAdminCommentsData(comments: comments))
        GoogleDatabaseManager.shared.updateUserCommentLastSeen(state: .read, for: self.userUID)
    }
}
