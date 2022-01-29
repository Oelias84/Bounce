//
//  CommentVIew.swift
//  FitApp
//
//  Created by Ofir Elias on 14/02/2021.
//

import UIKit
import SDWebImage

protocol CommentViewDelegate: AnyObject {
	
	func dismissTapped()
}

class CommentViewController: UIViewController {
	
	var comment: Comment!
	
	@IBOutlet weak var topBarView: BounceNavigationBarView!
	
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
	@IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
	@IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
	@IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!

	var photoName: String?

	weak var delegate: CommentViewDelegate?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupView()
		setupTopBarView()
		
		if let photoName = photoName {
			self.imageView.image = UIImage(named: photoName)
		}
	}
	
	override func viewWillLayoutSubviews() {
	  super.viewWillLayoutSubviews()
		updateMinZoomScaleForSize(view.bounds.size)
	}
}

//MARK: - Delegate
extension CommentViewController: BounceNavigationBarDelegate {
	
	func backButtonTapped() {
		navigationController?.popViewController(animated: true)
	}
}
//MARK: - Functions
extension CommentViewController {

	private func setupView() {
		scrollView.delegate = self
		scrollView.showsHorizontalScrollIndicator = false
		scrollView.showsVerticalScrollIndicator = false
	}
	private func setupTopBarView() {
		
		topBarView.delegate = self
		topBarView.nameTitle = comment.title
		topBarView.isMotivationHidden = true
		topBarView.isDayWelcomeHidden = true
		topBarView.isDayWelcomeHidden = true
		topBarView.isMessageButtonHidden = true
	}
}

//MARK:- Sizing
extension CommentViewController {
	
  func updateMinZoomScaleForSize(_ size: CGSize) {
	let widthScale = size.width / imageView.bounds.width
	let heightScale = size.height / imageView.bounds.height
	let minScale = min(widthScale, heightScale)
	  
	scrollView.minimumZoomScale = minScale
	scrollView.zoomScale = minScale
  }
  
  func updateConstraintsForSize(_ size: CGSize) {
	let yOffset = max(0, (size.height - imageView.frame.height) / 2)
	imageViewTopConstraint.constant = yOffset
	imageViewBottomConstraint.constant = yOffset
	
	let xOffset = max(0, (size.width - imageView.frame.width) / 2)
	imageViewLeadingConstraint.constant = xOffset
	imageViewTrailingConstraint.constant = xOffset
	  
	view.layoutIfNeeded()
  }
}
extension CommentViewController: UIScrollViewDelegate {

	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return imageView
	}
	func scrollViewDidZoom(_ scrollView: UIScrollView) {
	  updateConstraintsForSize(view.bounds.size)
	}
}
