//
//  ArticlesViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 11/01/2021.
//

import UIKit
import Foundation
import BetterSegmentedControl

class ArticlesViewController: UIViewController {
	private var filteredArticles: [Article]? {
		didSet {
			self.sections = filteredArticles?.map { return ExpandableSectionData(name: $0.title, text: [$0.text]) }
		}
	}
	private var sections: [ExpandableSectionData]? {
		didSet {
			tableView.reloadData()
		}
	}
	
	private var articleViewModel: ArticleViewModel!
	private var articleTopic: String!
	public var openFromChat = false
	
	@IBOutlet weak var topBarView: BounceNavigationBarView!
	@IBOutlet weak var segmentedControl: BetterSegmentedControl!
	
	@IBOutlet weak var tableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.estimatedRowHeight = 44.0
		tableView.rowHeight = UITableView.automaticDimension
		
		setupView()
		callToViewModelForUIUpdate()
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		topBarView.setImage()
		if filteredArticles != nil {
			checkTopic()
		}
	}
	@IBAction func segmentedControlAction(_ sender: BetterSegmentedControl) {
		let index = sender.index
		
		moveTo(index)
	}
}

//MARK: - Delegate
extension ArticlesViewController: UITableViewDelegate, UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return sections?.count ?? 0
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let sections = sections {
			return sections[section].collapsed ? 0 : sections[section].text.count
		}
		return 0
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.collapsibleCell, for: indexPath) as! CollapsibleTableViewCell
		let text = sections?[indexPath.section].text[indexPath.row] ?? ""
		
		cell.articleTextLabel.text = text.replacingOccurrences(of: "\\n", with: "\n")
		return cell
	}
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let header = tableView.dequeueReusableHeaderFooterView(withIdentifier:  K.CellId.collapsibleHeader) as! CollapsibleTableViewHeader
		
		header.titleLabel.text = sections?[section].name
		header.setCollapsed(collapsed: sections?[section].collapsed ?? false)
		header.section = section
		header.delegate = self
		return header
	}
}
extension ArticlesViewController:  CollapsibleTableViewHeaderDelegate {
	
	func toggleSection(header: CollapsibleTableViewHeader, section: Int) {
		guard let sections = sections else { return }
		let collapsed = !sections[section].collapsed
		
		// Toggle collapse
		self.sections?[section].collapsed = collapsed
		header.setCollapsed(collapsed: collapsed)
		tableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
	}
}
extension ArticlesViewController: BounceNavigationBarDelegate {
	
	func backButtonTapped() {}
}

//MARK: - Functions
extension ArticlesViewController {
	
	private func setupView() {
		segmentedControl.backgroundColor = .projectBackgroundColor
		segmentedControl.borderColorV = .projectGray.withAlphaComponent(0.2)
		segmentedControl.borderWidthV = 1
		
		segmentedControl.options = [
			.cornerRadius(20),
			.indicatorViewBackgroundColor(.projectTail)
		]
		
		segmentedControl.segments =  [
			LabelSegment(text: "תזונה", normalFont: UIFont(name: "Assistant-SemiBold", size: 18), normalTextColor: .black, selectedTextColor: .white),
			LabelSegment(text: "אימונים", normalFont: UIFont(name: "Assistant-SemiBold", size: 18), normalTextColor: .black, selectedTextColor: .white),
			LabelSegment(text: "מתכונים", normalFont: UIFont(name: "Assistant-SemiBold", size: 18), normalTextColor: .black, selectedTextColor: .white),
			LabelSegment(text: "אחר", normalFont: UIFont(name: "Assistant-SemiBold", size: 18), normalTextColor: .black, selectedTextColor: .white)
		]
		
		topBarView.delegate = self
		topBarView.nameTitle = "מאמרים"
		topBarView.isMotivationHidden = true
		topBarView.isDayWelcomeHidden = true
		topBarView.isBackButtonHidden = true
		topBarView.isProfileButtonHidden = false
		registerCells()
	}
	private func checkTopic() {
		if openFromChat {
			moveTo(3)
			openFromChat = false
		} else {
			moveTo(0)
		}
	}
	private func registerCells() {
		tableView.register(UINib(nibName: K.NibName.collapsibleTableViewCell, bundle: nil), forCellReuseIdentifier: K.CellId.collapsibleCell)
		tableView.register(UINib(nibName: K.NibName.collapsibleTableViewHeader, bundle: nil), forHeaderFooterViewReuseIdentifier: K.CellId.collapsibleHeader)
	}
	private func updateDataSource() {
		Spinner.shared.stop()
		checkTopic()
	}
	private func moveTo(_ index: Int) {
		filteredArticles = index == 3 ? articleViewModel.articles[index].reversed() : articleViewModel.articles[index]
		articleTopic = articleViewModel.topics[index]
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}
		segmentedControl.setIndex(index)
	}
	private func callToViewModelForUIUpdate() {
		
		if let navView = navigationController?.view {
			Spinner.shared.show(navView)
		}
		articleViewModel = ArticleViewModel()
		articleViewModel.bindArticleViewModelToController = {
			self.updateDataSource()
		}
	}
}
