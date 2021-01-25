//
//  ArticleViewModel.swift
//  FitApp
//
//  Created by iOS Bthere on 11/01/2021.
//

import Foundation


class ArticleViewModel: NSObject {
    
    var articles: [[Article]]! {
        didSet {
            self.bindArticleViewModelToController()
        }
    }
    var topics = ["תזונה", "אימונים", "מתכונים", "אחר"]
    private var googleService: GoogleApiManager!
    
    var bindArticleViewModelToController : (() -> ()) = {}

    override init() {
        super.init()
        
        googleService = GoogleApiManager()
        fetchArticles()
    }
    
    func fetchArticles() {
        googleService.getArticles { result in
            switch result {
            case .success(let articles):
                if let articles = articles {
                    self.articles = articles
                }
            case .failure(let error):
                print(error)
            }
        }
    }

}
