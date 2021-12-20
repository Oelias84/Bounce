//
//  ArticlesViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 11/01/2021.
//

import UIKit
import BetterSegmentedControl

class ArticlesViewController: UIViewController {
	
	private var filteredArticles: [Article]?
	private var articleViewModel: ArticleViewModel!
	private var articleTopic: String!
	public var openFromChat = false
	
	@IBOutlet weak var topBarView: BounceNavigationBarView!
	@IBOutlet weak var segmentedControl: BetterSegmentedControl!
	
	@IBOutlet weak var tableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupView()
		callToViewModelForUIUpdate()
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if filteredArticles != nil {
			checkTopic()
		}
	}
	@IBAction func segmentedControlAction(_ sender: BetterSegmentedControl) {
		let index = sender.index
		
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
	private func setupView() {
		segmentedControl.backgroundColor = UIColor.projectBackgroundColor
		segmentedControl.borderColorV = .projectGray
		segmentedControl.borderWidthV = 1

		segmentedControl.options = [
				.cornerRadius(20),
				.indicatorViewBorderWidth(1),
				.indicatorViewBackgroundColor(.projectTail),
		]
		
		segmentedControl.segments =  [
			LabelSegment(text: "תזונה", normalFont: UIFont(name: "Assistant-SemiBold", size: 18), normalTextColor: .black, selectedTextColor: .white),
			LabelSegment(text: "אימונים", normalFont: UIFont(name: "Assistant-SemiBold", size: 18), normalTextColor: .black, selectedTextColor: .white),
			LabelSegment(text: "מתכונים", normalFont: UIFont(name: "Assistant-SemiBold", size: 18), normalTextColor: .black, selectedTextColor: .white),
			LabelSegment(text: "אחר", normalFont: UIFont(name: "Assistant-SemiBold", size: 18), normalTextColor: .black, selectedTextColor: .white)
		]
		
		topBarView.nameTitle = "מאמרים"
		topBarView.isMotivationHidden = true
		topBarView.isDayWelcomeHidden = true
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
		segmentedControl.setIndex(index)
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
