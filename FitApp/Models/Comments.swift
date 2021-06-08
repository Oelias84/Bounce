//
//  Comments.swift
//  FitApp
//
//  Created by Ofir Elias on 14/02/2021.
//

import Foundation

struct Comments: Codable {
	
	let text: [String]
}
#warning("change here as well")
struct newComments: Codable {
	
	let comments: [Comment]
}

struct Comment: Codable {
	
	let title: String
	let text: [String]
	let image: String?
}
