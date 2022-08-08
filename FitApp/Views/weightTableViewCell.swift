//
//  weightTableViewCell.swift
//  FitApp
//
//  Created by iOS Bthere on 23/12/2020.
//

import UIKit
import Combine
import FirebaseAuth

protocol weightTableViewCellDelegate {
	
	func presentImage(image: UIImage)
}

class weightTableViewCell: UITableViewCell {
	
	private var cancellable: AnyCancellable?
	private var animator: UIViewPropertyAnimator?
	
	private var weight: Weight!
	private var timePeriod: TimePeriod! {
		didSet{
			switch timePeriod {
			case .week:
				changeTextLabel.isHidden = true
				weightImageView.isHidden = false
				disclosureIndicatorImage.isHidden = true
				dateTextLabel.text = weight.printWeightDay
				dateImageStackView.isUserInteractionEnabled = true
				dateImageStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageTapped)))
			case .month:
				weightImageView.isHidden = true
				changeTextLabel.isHidden = false
				disclosureIndicatorImage.isHidden = false
				dateImageStackView.isUserInteractionEnabled = false
				dateTextLabel.text = "\(weight.date.displayDayInMonth)-\(weight.date.add(6.days).displayDayInMonth)"
			case .year:
				weightImageView.isHidden = true
				changeTextLabel.isHidden = false
				disclosureIndicatorImage.isHidden = true
				dateImageStackView.isUserInteractionEnabled = false
				dateTextLabel.text = "\(weight.date.displayMonthAndYear)"
			default:
				break
			}
		}
	}
	
	@IBOutlet weak var dateImageStackView: UIStackView!
	@IBOutlet weak var dateTextLabel: UILabel!
	@IBOutlet weak var differenceTextLabel: UILabel!
	@IBOutlet weak var changeTextLabel: UILabel!
	@IBOutlet weak var weightTextLabel: UILabel!
	@IBOutlet weak var disclosureIndicatorImage: UIImageView!
	@IBOutlet weak var weightImageView: UIImageView!
	
	var delegate: weightTableViewCellDelegate?

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	override public func prepareForReuse() {
		super.prepareForReuse()
		
		dateImageStackView.spacing = 0
		weightImageView.image = nil
		weightImageView.alpha = 0
		animator?.stopAnimation(true)
		cancellable?.cancel()
	}
}

extension weightTableViewCell {
	
	func setupCell(weight: Weight, timePeriod: TimePeriod) {
		self.weight = weight
		self.timePeriod = timePeriod
		
		weightTextLabel.text = weight.weight.isNaN ? String(format: "%.1f", 0) + " ק״ג" : weight.printWeight
		
		cancellable = self.loadImage(url: URL(string: weight.imagePath ?? "")).sink {
			[unowned self] image in
			self.showImage(image: image)
		}
	}
	fileprivate func loadImage(url: URL?) -> AnyPublisher<UIImage?, Never> {
		return Just(url)
		.flatMap({ poster -> AnyPublisher<UIImage?, Never> in
			guard let url = url else { return Just( UIImage().imageWith(name: "N A")!).eraseToAnyPublisher() }
			return ImageLoader.shared.loadImage(from: url)
		})
		.eraseToAnyPublisher()
	}
	fileprivate func showImage(image: UIImage?) {
		dateImageStackView.spacing = 6
		animator?.stopAnimation(false)
		weightImageView.alpha = 0.0
		weightImageView.image = image
		weightImageView.contentMode = .scaleToFill
		animator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
			self.weightImageView.alpha = 1.0
		})
	}
	@objc fileprivate func imageTapped() {
		if let image = weightImageView.image {
			self.delegate?.presentImage(image: image)
		}
	}
}
