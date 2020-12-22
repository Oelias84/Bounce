//
//  WeightProgressViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 22/12/2020.
//

import UIKit

class WeightProgressViewController: UIViewController {

    @IBOutlet weak var periodSegmentedController: UISegmentedControl!
    
    @IBOutlet weak var dateRightButton: UIButton! {
        didSet {
            dateRightButton.setImage(dateRightButton.imageView?.image?.imageFlippedForRightToLeftLayoutDirection(), for: .normal)
        }
    }
    @IBOutlet weak var dateTextLabel: UILabel!
    @IBOutlet weak var dateLeftButton: UIButton!{
        didSet {
            dateLeftButton.setImage(dateLeftButton.imageView?.image?.imageFlippedForRightToLeftLayoutDirection(), for: .normal)
        }
    }
    
    @IBOutlet weak var chartsCollectionView: UICollectionView!
    
    @IBOutlet weak var weightDatesTableView: UITableView!
    
    @IBOutlet weak var weightLostResultTextLabel: UILabel!
    @IBOutlet weak var periodResultTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func addWeightButtonAction(_ sender: Any) {
        
    }
}
