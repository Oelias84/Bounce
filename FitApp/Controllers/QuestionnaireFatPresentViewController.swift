//
//  QuestionnaireFatPresentViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 25/11/2020.
//

import UIKit

class QuestionnaireFatPresentViewController: UIViewController {
	
	private let pickerItems = ["18", "20", "25", "30", "40", "45"]
	private var cellScale: CGFloat = 0.6
	private var selectedPercentage: String?
	private var isFirstLoad = true
	private var index: Int?
	
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var pageControl: UIPageControl!
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupSelectedImage()
		setUpCollectionView()
	}
	
	@IBAction func nextButtonAction(_ sender: Any) {
		
			
			if let fatPercentage = selectedPercentage {
				var fatPrecent: Double = 0.0
				
				switch fatPercentage {
				case "18":
					fatPrecent = 18.0
				case "20":
					fatPrecent = 20.0
				case "25":
					fatPrecent = 25.0
				case "30":
					fatPrecent = 30.0
				case "40":
					fatPrecent = 40.0
				case "45":
					fatPrecent = 45.0
				default:
					break
				}
				UserProfile.defaults.fatPercentage = fatPrecent
				performSegue(withIdentifier: K.SegueId.moveToActivity, sender: self)
				
			} else {
				presentOkAlert(withTitle: "אופס",withMessage: "נראה כי לא נעשתה בחירה, יש לבחור בתמונה שהכי משקפת אתת הנראות שלך", buttonText: "הבנתי") {
					return
				}
			}
	}
}

extension QuestionnaireFatPresentViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		1
	}
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		pickerItems.count
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.CellId.fanCell, for: indexPath) as! QuestionnaireFatCollectionViewCell
		
//		cell.fatImageString = pickerItems[indexPath.row]
		cell.setFatPresentLabel(for: indexPath.row)
		return cell
	}
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		selectedPercentage = pickerItems[indexPath.row]
	}
}

extension QuestionnaireFatPresentViewController {
	
	func setupSelectedImage() {
		let userData = UserProfile.defaults
		
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
		if let _ = userData.fatPercentage {
			selectedPercentage = pickerItems[index!]
		}
		DispatchQueue.main.async {
			[unowned self] in
			self.collectionView.scrollToItem(at: IndexPath(item: index ?? 0, section: 0), at: .centeredHorizontally, animated: true)
		}
	}
	private func setUpCollectionView() {
		collectionView.isUserInteractionEnabled = true
		layout(collectionView){
			[weak self] row in
			guard let self = self else { return }
			self.pageControl.currentPage = row
		}
	}

	//MARK: - CollectionView CompositionalLayout
	func layout(_ collectionView: UICollectionView, callBack: @escaping (Int)->()) {
		
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
					callBack(currentPage)
					rowToCompare = currentPage
				}
			}
			return section
		}
		collectionView.collectionViewLayout = layout
	}
}
