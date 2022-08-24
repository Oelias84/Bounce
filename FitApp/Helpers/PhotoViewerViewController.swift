//
//  PhotoViewerViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 13/02/2021.
//

import UIKit
import SDWebImage

class PhotoViewerViewController: UIViewController {

	fileprivate let url: URL?
	fileprivate let image: UIImage?
	
	init(with url: URL? = nil, image: UIImage? = nil) {
		self.url = url
		self.image = image
		super.init(nibName: nil, bundle: nil)
	}
	
	private let imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		title = "תמונה"
		view.backgroundColor = .black
		if let image = image {
			view.addSubview(imageView)
			self.imageView.image = image
		} else {
			view.addSubview(imageView)
			self.imageView.sd_setImage(with: self.url)
		}
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		imageView.frame = view.bounds
	}
}
