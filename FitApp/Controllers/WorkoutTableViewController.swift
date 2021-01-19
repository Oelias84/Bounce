//
//  WorkoutTableViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 17/01/2021.
//

import UIKit

class WorkoutTableViewController: UITableViewController {
    
    private var workoutViewModel: WorkoutViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
}
