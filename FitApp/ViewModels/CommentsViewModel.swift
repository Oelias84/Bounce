//
//  CommentsViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 04/06/2021.
//

import Foundation
import SDWebImage

class CommentsViewModel {
	
	
	private var comments: CommentsData? {
		didSet {
			self.sections = comments?.comments.map { return ExpandableSectionData(name: $0.title, text: $0.text ?? []) }
		}
	}
	var sections: [ExpandableSectionData]! {
		didSet {
			bindNotificationViewModelToController()
		}
	}
	var bindNotificationViewModelToController: (() -> ()) = {}
	
	init() {
		fetchComments()
	}
	func getSectionCollapsed(for section: Int) -> Bool {
		sections[section].collapsed
	}
	func getCommentsCount(for section: Int) -> Int {
		sections[section].text.count
	}
	func getComment(for indexPath: IndexPath) -> String {
		sections?[indexPath.section].text[indexPath.row] ?? ""
	}
	func getSectionTitle(for section: Int) -> String  {
		sections?[section].name ?? ""
	}
	func getSectionCount() -> Int {
		return sections?.count ?? 0
	}
	func updateSection(at: Int, collapsed: Bool) {
		sections?[at].collapsed = collapsed
	}
	func setCollapsed(_ isCollapsed: Bool, for section: Int) {
		sections?[section].collapsed = isCollapsed
	}
	
	
	func getCommentForCell(at index: Int) -> Comment {
		return comments!.comments[index]
	}
	func getCommentsText(at index: Int) -> [String] {
		return comments!.comments[index].text ?? []
	}
	func getCommentImage(for index: Int, completion: (UIImageView?) -> ()) {
		var imageView: UIImageView?

		if let urlString = comments?.comments[index].image, let url = URL(string: urlString) {
			imageView = UIImageView()
			imageView!.sd_setImage(with: url)
			completion(imageView)
		}
		completion(imageView)
	}
	
	private func fetchComments() {
		
		GoogleApiManager.shared.getComments {
			[weak self] result in
			guard let self = self else { return }
			Spinner.shared.stop()
			switch result {
			case .success(let receivedComments):
				if let comments = receivedComments {
					self.comments = comments
				}
			case .failure(let error):
				print(error)
			}
		}
	}
}
