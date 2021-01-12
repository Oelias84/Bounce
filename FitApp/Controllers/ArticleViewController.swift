//
//  ArticleViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 12/01/2021.
//

import UIKit

class ArticleViewController: UIViewController {
    
    var article: Article!
    
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var articleTextView: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        articleTitleLabel.text = article.title
        articleTextView.text = article.text
    }
}
