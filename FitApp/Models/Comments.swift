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
