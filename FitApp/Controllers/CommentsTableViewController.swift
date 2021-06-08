//
//  CommentsTableViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 08/06/2021.
//

import UIKit

class CommentsTableViewController: UITableViewController {

	var viewModel: CommentsViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		tableView.register(UINib(nibName: K.NibName.commentTableViewCell, bundle: nil), forCellReuseIdentifier: K.CellId.commentCell)
		tableView.allowsSelection = true
		
		Spinner.shared.show(self.view)
		viewModel = CommentsViewModel()
		viewModel.bindNotificationViewModelToController = { [weak self] in
			guard let self = self else { return }
			self.updateUI()
		}
    }

	
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
		1
	}
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.getCommentsCount()
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let data = viewModel.getCommentForCell(at: indexPath.row)
		let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.commentCell, for: indexPath) as! CommentTableViewCell
		
		cell.comment = data
		return cell
    }
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let selectedComment = viewModel.getCommentForCell(at: indexPath.row)
		let commentVC = storyboard?.instantiateViewController(identifier: K.ViewControllerId.commentViewController) as! CommentViewController
		
		commentVC.title = selectedComment.title
		commentVC.comment = selectedComment
		navigationController?.pushViewController(commentVC, animated: true)
	}
}

extension CommentsTableViewController {
	
	private func updateUI() {
		Spinner.shared.stop()
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}
	}
}
