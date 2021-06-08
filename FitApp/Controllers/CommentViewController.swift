//
//  CommentVIew.swift
//  FitApp
//
//  Created by Ofir Elias on 14/02/2021.
//

import UIKit

protocol CommentViewDelegate: AnyObject {
	
	func dismissTapped()
}

class CommentViewController: UIViewController {
	
	var comment: Comment!
	
	@IBOutlet weak var commentTextView: UITextView!
	@IBOutlet weak var commentImageView: UIImageView!
	
	weak var delegate: CommentViewDelegate?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		addScreenTappGesture()
		updateTextView()
	}
	
	private func updateTextView() {
		var text = ""
		let commentText = comment.text
		
		if comment.text.count > 1 {
			for i in 0...commentText.count-1 {
				let commentNumber = "\(i+1). "
				let commentText = commentText[i].replacingOccurrences(of: "\\n", with: "\n")
				text.append(commentNumber + commentText + "\n\n")
			}
		} else {
			text = comment.text[0].replacingOccurrences(of: "\\n", with: "\n")
		}
		
		DispatchQueue.main.async {
			self.commentTextView.text = text
		}
	}
	private func updateCommentImage(for index: Int) {
		
		if let imageUrl = comment.image {
			
			commentImageView.sd_setImage(with: URL(string: imageUrl))
		}
	}
}
