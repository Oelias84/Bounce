//
//  CommentVIew.swift
//  FitApp
//
//  Created by Ofir Elias on 14/02/2021.
//

import UIKit

protocol CommentViewDelegate {
	
	func dismissTapped()
}

class CommentViewController: UIViewController {
	
	@IBOutlet weak var textLabel: UILabel!
	
	var delegate: CommentViewDelegate?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		commonInit()
		addScreenTappGesture()
	}
	
	@IBAction func dismissButtonAction(_ sender: Any) {
		self.dismiss(animated: true)
	}
	
	private func commonInit() {
		GoogleApiManager.shared.getComments {
			[weak self]
			result in
			guard let self = self else { return }
			
			switch result {
			case .success(let comments):
				var text = ""
				if let comments = comments {
					for i in 0...comments.text.count-1 {
						let commentNumber = "\(i+1). "
						let commentText = comments.text[i].replacingOccurrences(of: "\\n", with: "\n")
						text.append(commentNumber + commentText + "\n\n")
					}
				}
				self.textLabel.text = text
			case .failure(let error):
				print(error)
			}
		}
	}
}
