//
//  Comments.swift
//  FitApp
//
//  Created by Ofir Elias on 14/02/2021.
//

import Foundation

struct CommentsData: Codable {
	
	let comments: [Comment]
}

struct Comment: Codable {
	
	let title: String
	let text: [String]?
	let image: String?
}

class UserAdminComment: Codable, Comparable {
	
	var text: String
	var sender: String
	var commentDate: String
	
	init(text: String, sender: String, commentDate: String) {
		self.text = text
		self.sender = sender
		self.commentDate = commentDate
	}
	
	static func < (lhs: UserAdminComment, rhs: UserAdminComment) -> Bool {
		
		return lhs.commentDate.fullDateFromString! > rhs.commentDate.fullDateFromString!
	}
	static func == (lhs: UserAdminComment, rhs: UserAdminComment) -> Bool {
		true
	}
}
struct UserAdminCommentsData: Codable {
	
	let comments: [UserAdminComment]
}
