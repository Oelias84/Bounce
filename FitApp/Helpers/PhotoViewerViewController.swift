//
//  PhotoViewerViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 13/02/2021.
//

import UIKit
import SDWebImage

class PhotoViewerViewController: UIViewController {

	private let url: URL
	
	init(with url: URL) {
		self.url = url
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
		navigationItem.largeTitleDisplayMode = .never
		view.addSubview(imageView)
		self.imageView.sd_setImage(with: self.url)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		imageView.frame = view.bounds
	}
}
