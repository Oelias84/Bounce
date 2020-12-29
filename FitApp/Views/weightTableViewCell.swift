    //
    //  weightTableViewCell.swift
    //  FitApp
    //
    //  Created by iOS Bthere on 23/12/2020.
    //
    
    import UIKit
    
    class weightTableViewCell: UITableViewCell {
        
        var weight: Weight! {
            didSet {
                setupTextFields()
            }
        }
        var timePeriod: TimePeriod! {
            didSet{
                switch timePeriod {
                case .week:
                    dateTextLabel.text = weight.printWeightDay
                case .month:
                    dateTextLabel.text = "\(weight.date.startOfWeek!.displayDayInMonth)-\(weight.date.endOfWeek!.displayDayInMonth)"
                case .year:
                    dateTextLabel.text = "\(weight.date.displayMonth)"
                default:
                    break
                }
            }
        }
        
        @IBOutlet weak var dateTextLabel: UILabel!
        @IBOutlet weak var differenceTextLabel: UILabel!
        @IBOutlet weak var changeTextLabel: UILabel!
        @IBOutlet weak var weightTextLabel: UILabel!
        
        override func awakeFromNib() {
            super.awakeFromNib()
        }
        
        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
        }
        
        private func setupTextFields(){
            weightTextLabel.text = weight.printWeight
        }
    }
