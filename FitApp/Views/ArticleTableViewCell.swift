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
		if article.title.contains("שאלות") {
			titleTextLabel.textColor = #colorLiteral(red: 0, green: 0.4640886188, blue: 1, alpha: 1)
		} else {
			titleTextLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
		}
    }
    private func setupView() {
        
        cellBackgroundView.cellView()
        selectionStyle = .none
    }
}
