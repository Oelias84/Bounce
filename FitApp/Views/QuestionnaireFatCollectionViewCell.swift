//
//  QuestionnaireFatCollectionViewCell.swift
//  FitApp
//
//  Created by iOS Bthere on 25/11/2020.
//

import UIKit

class QuestionnaireFatCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    
    override func layoutSubviews() {
        superview?.layoutSubviews()
    }
    
}
