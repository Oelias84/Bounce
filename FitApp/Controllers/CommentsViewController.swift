//
//  CommentsTableViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 08/06/2021.
//

import UIKit

class CommentsViewController: UIViewController {
	
	var viewModel: CommentsViewModel!
	
	@IBOutlet weak var topBarView: BounceNavigationBarView!
	@IBOutlet weak var tableView: UITableView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		registerCells()
		setupTopBarView()
		
		Spinner.shared.show(self.view)
		viewModel = CommentsViewModel()
		viewModel.bindNotificationViewModelToController = { [weak self] in
			guard let self = self else { return }
			self.updateUI()
		}
    }
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		topBarView.setImage()
	}
}

//MAKR: - Delegates
extension CommentsViewController: UITableViewDataSource, UITableViewDelegate {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return viewModel.getSectionCount()
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.getSectionCollapsed(for: section) ? 0 : viewModel.getCommentsCount(for: section)
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.collapsibleCell, for: indexPath) as! CollapsibleTableViewCell
		let text = viewModel.getComment(for: indexPath)

		cell.articleTextLabel.text = text.replacingOccurrences(of: "\\n", with: "\n")
		return cell
	}
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let header = tableView.dequeueReusableHeaderFooterView(withIdentifier:  K.CellId.collapsibleHeader) as! CollapsibleTableViewHeader
		
		header.titleLabel.text = viewModel.getSectionTitle(for: section)
		header.setCollapsed(collapsed: viewModel.getSectionCollapsed(for: section))
		header.section = section
		header.delegate = self
		return header
	}
}
extension CommentsViewController:  CollapsibleTableViewHeaderDelegate {
	
	func toggleSection(header: CollapsibleTableViewHeader, section: Int) {
		let collapsed = !viewModel.getSectionCollapsed(for: section)
		
		switch viewModel.getSectionTitle(for: section) {
		case  "טבלת ג׳אנק פוד":
			if let commentVC = storyboard?.instantiateViewController(identifier: K.ViewControllerId.commentViewController) as? CommentViewController {
				commentVC.comment = viewModel.getCommentForCell(at: section)
				commentVC.photoName = "junk_food_spreadsheet"
				navigationController?.pushViewController(commentVC, animated: true)
			}
		case "טבלת המרות":
			if let commentVC = storyboard?.instantiateViewController(identifier: K.ViewControllerId.commentViewController) as? CommentViewController {
				commentVC.comment = viewModel.getCommentForCell(at: section)
				commentVC.photoName = "conversion_spreadsheet"
				navigationController?.pushViewController(commentVC, animated: true)
			}
		default:
			// Toggle collapse
			viewModel.updateSection(at: section, collapsed: collapsed)
			header.setCollapsed(collapsed: collapsed)
			tableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
		}
	}
}
extension CommentsViewController: BounceNavigationBarDelegate {
	
	func backButtonTapped() {
		navigationController?.popViewController(animated: true)
	}
}

//MAKR: - Functions
extension CommentsViewController {
	

	private func updateUI() {
		Spinner.shared.stop()
		
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}
	}
	private func setupTopBarView() {
		
		topBarView.delegate = self
		topBarView.nameTitle = "ארוחות"
		topBarView.isMotivationHidden = true
		topBarView.isDayWelcomeHidden = true
		topBarView.isDayWelcomeHidden = true
	}
	private func registerCells() {
		
		tableView.register(UINib(nibName: K.NibName.collapsibleTableViewCell, bundle: nil), forCellReuseIdentifier: K.CellId.collapsibleCell)
		tableView.register(UINib(nibName: K.NibName.collapsibleTableViewHeader, bundle: nil), forHeaderFooterViewReuseIdentifier: K.CellId.collapsibleHeader)
		tableView.register(UINib(nibName: K.NibName.collapsibleSpreadsheetTableViewCell, bundle: nil), forCellReuseIdentifier: K.CellId.collapsibleSpreadsheetCell)
	}
}
