//
//  Article.swift
//  FitApp
//
//  Created by iOS Bthere on 11/01/2021.
//

import Foundation

struct Article: Codable {
    
    let title: String
//    let description: String
    let text: String
}

struct ServerArticles: Codable {
    
    let nutrition: [Article]
    let exercise: [Article]
    let recipes: [Article]
    let other: [Article]
}
