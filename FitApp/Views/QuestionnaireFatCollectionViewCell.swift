//
//  QuestionnaireFatCollectionViewCell.swift
//  FitApp
//
//  Created by iOS Bthere on 25/11/2020.
//

import UIKit

class QuestionnaireFatCollectionViewCell: UICollectionViewCell {
    
    var fatImageString: String! {
        didSet {
            cellImage.image = UIImage(named: fatImageString)
        }
    }
    var selectedFat: Bool?
    
    @IBOutlet weak var cellImage: UIImageView!
    
    override func layoutSubviews() {
        superview?.layoutSubviews()
        layer.cornerRadius = 10
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.image = nil
    }
    override var isSelected: Bool {
        didSet {
            if isSelected {
                layer.borderColor = UIColor.blue.cgColor
                layer.borderWidth = 5
            } else {
                layer.borderColor = nil
                layer.borderWidth = 0
            }
        }
    }
}
