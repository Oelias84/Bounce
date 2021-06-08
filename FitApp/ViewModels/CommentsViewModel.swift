//
//  CommentsViewModel.swift
//  FitApp
//
//  Created by Ofir Elias on 04/06/2021.
//

import Foundation
import SDWebImage

class CommentsViewModel {
	
	
	var comments: newComments? {
		didSet {
			bindNotificationViewModelToController()
		}
	}
	
	var bindNotificationViewModelToController: (() -> ()) = {}
	
	init() {
		fetchComments()
	}
	
	func getComments() -> [Comment] {
		return comments!.comments
	}
	func getCommentsCount() -> Int {
		return comments?.comments.count ?? 0
	}
	func getCommentForCell(at index: Int) -> Comment {
		return comments!.comments[index]
	}
	func getCommentsText(at index: Int) -> [String] {
		return comments!.comments[index].text
	}
//	func getCommentImage(for index: Int, completion: (UIImageView?) -> ()) {
//		var imageView: UIImageView?
//		
//		if let urlString = comments.comments[index].image, let url = URL(string: urlString) {
//			imageView = UIImageView()
//			imageView!.sd_setImage(with: url)
//			completion(imageView)
//		}
//		completion(imageView)
//	}
	
	private func fetchComments() {
		
		GoogleApiManager.shared.getComments {
			[weak self]
			result in
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
