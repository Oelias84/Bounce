//
//  Article.swift
//  FitApp
//
//  Created by iOS Bthere on 11/01/2021.
//

import Foundation
import PDFKit

struct Article: Codable {
    
    let title: String
    let text: String
	let maleText: String?

	var getArticleText: String {
		let userGender = UserProfile.defaults.getGender
		switch userGender {
		case .male:
			return maleText ?? text
		default:
			return text
		}
	}
}

struct ServerArticles: Codable {
    
    let nutrition: [Article]
    let exercise: [Article]
    let recipes: [Article]
    let other: [Article]
}
