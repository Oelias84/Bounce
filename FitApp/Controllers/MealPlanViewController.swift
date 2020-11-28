//
//  MealPlanViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 27/11/2020.
//

import UIKit

class MealPlanViewController: UIViewController {
    
    let mealArray: [String] = []
    var selectedCellIndexPath: IndexPath?

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "MealPlanTableViewCell", bundle: nil), forCellReuseIdentifier: "mealCell")
    }

}

extension MealPlanViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mealCell", for: indexPath) as! MealPlanTableViewCell
        cell.indexPath = indexPath
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let normalHeight: CGFloat = 124
        let expendedHeight: CGFloat = 300
        let cellHeight = tableView.cellForRow(at: indexPath)?.bounds.height
        let selectedCellHeight = tableView.cellForRow(at: selectedCellIndexPath ?? indexPath)?.bounds.height
        
        if selectedCellIndexPath == indexPath {
            if selectedCellHeight == normalHeight {
                return expendedHeight
            } else {
                return normalHeight
            }
        } else if cellHeight != expendedHeight{
            return normalHeight
        } else {
            return expendedHeight
        }
    }
}

extension MealPlanViewController: MealPlanTableViewCellDelegate  {
    func detailTapped(cell: IndexPath) {
        selectedCellIndexPath = cell
        tableView.beginUpdates()
        tableView.endUpdates()
        if selectedCellIndexPath != nil {
            // This ensures, that the cell is fully visible once expanded
            tableView.scrollToRow(at: cell, at: .none, animated: true)
        }
    }
}
