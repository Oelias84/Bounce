//
//  ArticleTableViewCell.swift
//  FitApp
//
//  Created by iOS Bthere on 11/01/2021.
//

import UIKit
import Foundation

class ArticleTableViewCell: UITableViewCell {
    
    var article: Article! {
        didSet {
            setupCell()
        }
    }
    
    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var cellBackgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func setupCell() {
        titleTextLabel.text = article.title
    }
    private func setupView() {
        
        cellBackgroundView.cellView()
        selectionStyle = .none
    }
}
