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
	
	@IBOutlet weak var collectionView: UICollectionView!

	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let imageNib = UINib(nibName: K.NibName.questionnaireFatCollectionViewCell, bundle: nil)
		collectionView.register(imageNib, forCellWithReuseIdentifier: K.CellId.fanCell)
		setupSelectedImage()
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
				//show alert
				return
			}
		
	}
}

extension QuestionnaireFatPresentViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		pickerItems.count
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.CellId.fanCell, for: indexPath) as! QuestionnaireFatCollectionViewCell
		cell.fatImageString = pickerItems[indexPath.row]
		return cell
	}
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		selectedPercentage = pickerItems[indexPath.row]
	}
}

extension QuestionnaireFatPresentViewController {
	
	func setupSelectedImage() {
		let userData = UserProfile.defaults
		var index = 0
		
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
			selectedPercentage = pickerItems[index]
		}
		DispatchQueue.main.async {
			self.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
		}
	}
}
