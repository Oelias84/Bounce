//
//  ArticlesViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 11/01/2021.
//

import UIKit

class ArticlesViewController: UIViewController {
    
    private var filteredArticles: [Article]?
    private var articleViewModel: ArticleViewModel!
    private var articleTopic: String!

    @IBOutlet weak var articlesSegmentedControl: UISegmentedControl! {
        didSet {
            articlesSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)], for: .normal)
        }
    }
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        callToViewModelForUIUpdate()
    }
    
    @IBAction func articlesSegmentedControlAction(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        filteredArticles = articleViewModel.articles[index]
        articleTopic = articleViewModel.topics[index]
        tableView.reloadData()
    }
}

extension ArticlesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (filteredArticles?.count ?? 0)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = filteredArticles?[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.articleCell, for: indexPath) as! ArticleTableViewCell

        cell.article = data
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let article = filteredArticles?[indexPath.row] else { return }
        
        moveToArticleView(for: article)
    }
}

extension ArticlesViewController {
    
    func updateDataSource() {
        stopSpinner()
        filteredArticles = articleViewModel.articles[0]
        articleTopic = articleViewModel.topics[0]
        self.tableView.reloadData()
    }
    func callToViewModelForUIUpdate() {
        tableView.register(UINib(nibName: K.NibName.articleTableViewCell, bundle: nil), forCellReuseIdentifier: K.CellId.articleCell)
        showSpinner()
        articleViewModel = ArticleViewModel()
        articleViewModel.bindArticleViewModelToController = {
            self.updateDataSource()
        }
    }
    func moveToArticleView(for article: Article) {
        let storyboard = UIStoryboard(name: K.StoryboardName.articles, bundle: nil)
        let articleVC = storyboard.instantiateViewController(identifier: K.StoryboardNameId.articleViewController) as ArticleViewController
        
        articleVC.title = articleTopic
        articleVC.article = article
        navigationController?.pushViewController(articleVC, animated: true)
    }
}
