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
	public var openFromChat = false
	
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
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if filteredArticles != nil {
			checkTopic()
		}
	}
	
	@IBAction func articlesSegmentedControlAction(_ sender: UISegmentedControl) {
		let index = sender.selectedSegmentIndex
		moveTo(index)
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
	
	private func updateDataSource() {
		Spinner.shared.stop()
		checkTopic()
	}
	private func callToViewModelForUIUpdate() {
		tableView.register(UINib(nibName: K.NibName.articleTableViewCell, bundle: nil), forCellReuseIdentifier: K.CellId.articleCell)
		if let navView = navigationController?.view {
			Spinner.shared.show(navView)
		}
		articleViewModel = ArticleViewModel()
		articleViewModel.bindArticleViewModelToController = {
			self.updateDataSource()
		}
	}
	private func moveToArticleView(for article: Article) {
		let storyboard = UIStoryboard(name: K.StoryboardName.articles, bundle: nil)
		let articleVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.articleViewController) as ArticleViewController
		
		articleVC.title = articleTopic
		articleVC.article = article
		navigationController?.pushViewController(articleVC, animated: true)
	}
	private func moveTo(_ index: Int) {
		filteredArticles = index == 3 ? articleViewModel.articles[index].reversed() : articleViewModel.articles[index]
		articleTopic = articleViewModel.topics[index]
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}
		articlesSegmentedControl.selectedSegmentIndex = index
	}
	private func checkTopic() {
		if openFromChat {
			moveTo(3)
			openFromChat = false
		} else {
			moveTo(0)
		}
	}
}
