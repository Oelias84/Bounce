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
	
	@IBOutlet weak var commentScrollView: UIScrollView!
	@IBOutlet weak var commentTextView: UITextView!
	@IBOutlet weak var commentImageView: UIImageView!
	@IBOutlet weak var commentImageHeight: NSLayoutConstraint!
	
	weak var delegate: CommentViewDelegate?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		updateCommentImage()
		updateTextView()
	}
}

extension CommentViewController {

	private func updateTextView() {
		var text = ""
		guard let commentText = comment.text else { return }
		
		if commentText.count > 1 {
			for i in 0...commentText.count-1 {
				let commentNumber = "\(i+1). "
				let commentText = commentText[i].replacingOccurrences(of: "\\n", with: "\n")
				text.append(commentNumber + commentText + "\n\n")
			}
		} else {
			text = commentText[0].replacingOccurrences(of: "\\n", with: "\n")
		}
		
		DispatchQueue.main.async {
			self.commentTextView.isHidden = false
			self.commentImageView.isHidden = true
			self.commentTextView.text = text
		}
	}
	private func updateCommentImage() {
		guard let imagePath = comment.image else { return }
		Spinner.shared.show(self.view)
		
		GoogleStorageManager.shared.downloadImageURL(from: .profileImage, path: imagePath) {
			[weak self] result in
			guard let self = self else { return }
			Spinner.shared.stop()
			
			switch result {
			case .success(let imageUrl):
				DispatchQueue.main.async {
					self.commentTextView.isHidden = true
					self.commentImageView.isHidden = false
					
					self.getData(from: imageUrl) {
						[weak self] data, URL, error in
						guard let self = self, let data = data, error == nil else { return }
						DispatchQueue.main.async {
							self.commentImageView.image = UIImage(data: data)!
						}
					}
				}
			case .failure(let error):
				print(error.localizedDescription)
			}
		}
	}
	func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
		URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
	}
}
