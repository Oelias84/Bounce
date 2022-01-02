//
//  QuestionnaireFatPresentViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 25/11/2020.
//

import UIKit

class QuestionnaireFatPresentViewController: UIViewController {
	
	private var selectedPercentage: String?
	private var isFirstLoad = true
	private var index: Int?
	
	var currentIndex: IndexPath {
		let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
		let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
		return collectionView.indexPathForItem(at: visiblePoint) ?? IndexPath()
	}
	var gender: Int {
		return UserProfile.defaults.userGander ?? 1
	}
	
	@IBOutlet weak var collectionView: UICollectionView!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.setHidesBackButton(true, animated: false)

		setupSelectedImage()
		setUpCollectionView()
	}
	
	@IBAction func scrollForewordButtonAction(_ sender: Any) {
		collectionView.scrollToItem(at: IndexPath(item: currentIndex.row + 1, section: 0), at: .centeredHorizontally, animated: true)

	}
	@IBAction func scrollBackButtonAction(_ sender: Any) {
		collectionView.scrollToItem(at: IndexPath(item: currentIndex.row - 1, section: 0), at: .centeredHorizontally, animated: true)
	}

	@IBAction func backButtonAction(_ sender: Any) {
		navigationController?.popViewController(animated: true)
	}
	@IBAction func nextButtonAction(_ sender: Any) {
		var fatPrecent: Double = 0.0
		
		switch currentIndex.row {
		case 0:
			fatPrecent = gender == 1 ? 18.0 : 8.0
		case 1:
			fatPrecent = gender == 1 ? 20.0 : 12.0
		case 2:
			fatPrecent = gender == 1 ? 25.0 : 15.0
		case 3:
			fatPrecent = gender == 1 ? 30.0 : 20.0
		case 4:
			fatPrecent = gender == 1 ? 40.0 : 25.0
		case 5:
			fatPrecent = gender == 1 ? 45.0 : 30.0
		default:
			break
		}
		UserProfile.defaults.fatPercentage = fatPrecent
		performSegue(withIdentifier: K.SegueId.moveToActivity, sender: self)
	}
}

extension QuestionnaireFatPresentViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		1
	}
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		6
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.CellId.fanCell, for: indexPath) as! QuestionnaireFatCollectionViewCell
		
		cell.setFatPresentLabel(for: indexPath.row)
		return cell
	}
}

extension QuestionnaireFatPresentViewController {
	
	private func setupSelectedImage() {
		let userData = UserProfile.defaults
		if gender == 1 {
			switch userData.fatPercentage {
			case 18.0:
				index = 0
			case 20.0:
				index = 1
			case 25.0:
				index = 2
			case 30.0:
				index = 3
			case 40.0:
				index = 4
			case 45.0:
				index = 5
			default:
				break
			}
		} else {
			switch userData.fatPercentage {
			case 8.0:
				index = 0
			case 12.0:
				index = 1
			case 15.0:
				index = 2
			case 20.0:
				index = 3
			case 25.0:
				index = 4
			case 30.0:
				index = 5
			default:
				break
			}
		}
		DispatchQueue.main.async {
			self.collectionView.scrollToItem(at: IndexPath(item: self.index ?? 0, section: 0), at: .centeredHorizontally, animated: true)
		}
	}
	private func setUpCollectionView() {
		collectionView.isUserInteractionEnabled = true
		layout(collectionView)
	}
	
	//MARK: - CollectionView CompositionalLayout
	private func layout(_ collectionView: UICollectionView) {
		
		let layout = UICollectionViewCompositionalLayout { sectionIndex, environment -> NSCollectionLayoutSection? in
			
			let itemSize = NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1.0),
				heightDimension: .fractionalHeight(1.0))
			
			let item = NSCollectionLayoutItem(layoutSize: itemSize)
			
			let groupSize = NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1.0),
				heightDimension: .fractionalHeight(1.0))
			let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
			
			let section = NSCollectionLayoutSection(group: group)
			section.orthogonalScrollingBehavior = .paging
			
			var rowToCompare = 0
			section.visibleItemsInvalidationHandler = { items, contentOffset, environment in
				let currentPage = Int(max(0, round(contentOffset.x / environment.container.contentSize.width)))
				if rowToCompare != currentPage {
					rowToCompare = currentPage
				}
			}
			return section
		}
		collectionView.collectionViewLayout = layout
	}
}
