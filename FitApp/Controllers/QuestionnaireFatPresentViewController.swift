//
//  QuestionnaireFatPresentViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 25/11/2020.
//

import UIKit

class QuestionnaireFatPresentViewController: UIViewController {
    
    private let pickerItems = ["fat", "fat", "fat","fat","fat","fat","fat"]
    private var cellScale : CGFloat = 0.6
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageNib = UINib(nibName: "QuestionnaireFatCollectionViewCell", bundle: nil)
        collectionView.register(imageNib, forCellWithReuseIdentifier: "fanCell")
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        
    }
}

extension QuestionnaireFatPresentViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pickerItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "fanCell", for: indexPath) as! QuestionnaireFatCollectionViewCell
        cell.layer.cornerRadius = 10
        cell.image.image = UIImage(named: pickerItems[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}


