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
		comments.value?.count != 0 && comments.value?.count != nil
	}
	var getCommentsCount: Int? {
		comments.value?.count
	}
	public func getCommentsFor(row: Int) -> UserAdminComment {
		comments.value![row]
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
	func addNewComment(with text: String, date: String? = nil, completion: ((Error?) -> Void)? = nil) {
		let currentDate = Date().fullDateStringForDB
		let comment = UserAdminComment(text: text, sender: UserProfile.defaults.name ?? "אין שם", commentDate: date ?? currentDate)
		
		if comments.value == nil {
			comments.value = [comment]
		} else {
			comments.value?.append(comment)
		}
		
		guard let comments = comments.value else { return }
		GoogleApiManager.shared.updateUserAdminComment(userUID: userUID, comments: UserAdminCommentsData(comments: comments), completion: completion)
	}
	func removeComment(row: Int, completion: ((Error?) -> Void)? = nil) {
		guard let comments = comments.value else { return }
		self.comments.value?.remove(at: row)
		GoogleApiManager.shared.updateUserAdminComment(userUID: userUID, comments: UserAdminCommentsData(comments: comments), completion: completion)
	}
	func updateComment(text: String, row: Int, completion: ((Error?) -> Void)? = nil) {
		guard let comments = comments.value else { return }
		comments[row].text = text
		GoogleApiManager.shared.updateUserAdminComment(userUID: userUID, comments: UserAdminCommentsData(comments: comments), completion: completion)
	}
}
