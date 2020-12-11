//
//  QuestionnaireFatPresentViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 25/11/2020.
//

import UIKit

class QuestionnaireFatPresentViewController: UIViewController {
    
    private let pickerItems = ["Fat1", "Fat2", "Fat3", "Fat4", "Fat5", "Fat6", "Fat7"]
    private var cellScale: CGFloat = 0.6
    private var selectedPercentage: String?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageNib = UINib(nibName: K.NibName.questionnaireFatCollectionViewCell, bundle: nil)
        collectionView.register(imageNib, forCellWithReuseIdentifier: K.CellId.fanCell)
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        if let fatPercentage = selectedPercentage {
            var fatPrecent: Double = 0.0
            switch fatPercentage {
            case "Fat1":
                fatPrecent = 10.0
            case "Fat2":
                fatPrecent = 20.0
            case "Fat3":
                fatPrecent = 30.0
            case "Fat4":
                fatPrecent = 40.0
            case "Fat5":
                fatPrecent = 50.0
            case "Fat6":
                fatPrecent = 60.0
            case "Fat7":
                fatPrecent = 70.0
            default:
                break
            }
            UserProfile.shared.fatPercentage = fatPrecent
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

