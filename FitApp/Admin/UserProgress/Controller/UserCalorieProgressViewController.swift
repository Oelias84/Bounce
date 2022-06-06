//
//  UserCalorieProgressViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 06/06/2022.
//

import UIKit

class UserCalorieProgressViewController: UIViewController {
	
	var viewModel: UserCalorieProgressViewModel!
	
	@IBOutlet weak var tableView: UITableView!
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == K.SegueId.moveToUserProgressDetails {
			if let userDetailsVC = segue.destination as? UserProgressDetailsViewController {
				
				guard let userProgressData = sender as? CaloriesProgressState else { return }

				userDetailsVC.navigationItem.largeTitleDisplayMode = .always
				userDetailsVC.viewModel = UserProgressDetailsViewModel(userProgressData: userProgressData)
			}
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		setupView()
		setupBinders()
	}
}


//MARK: - Delegates
extension UserCalorieProgressViewController: UITableViewDelegate, UITableViewDataSource  {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		viewModel.getProgressCount
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let progressDate = viewModel.getTitle(at: indexPath.row)
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
		
		cell?.textLabel?.text = progressDate
		return cell ?? UITableViewCell()
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let progressData = viewModel.getProgressData(at: indexPath.row)
		
		performSegue(withIdentifier: K.SegueId.moveToUserProgressDetails, sender: progressData)
	}
}
extension UserCalorieProgressViewController: PopupAlertViewDelegate {
	
	func okButtonTapped(alertNumber: Int, selectedOption: String?, textFieldValue: String?) {
		return
	}
	func cancelButtonTapped(alertNumber: Int) {
		return
	}
	func thirdButtonTapped(alertNumber: Int) {
		return
	}
}

//MARK: - Functions
extension UserCalorieProgressViewController {
	
	fileprivate func setupView() {
		Spinner.shared.show(view)
	}
	fileprivate func setupBinders() {
		viewModel.userProgress.bind {
			userProgress in
			
			if userProgress != nil {
				DispatchQueue.main.async {
					self.tableView.reloadData()
					Spinner.shared.stop()
				}
			}
		}
	}
	fileprivate func presentPopupAlert(withTitle title: String? = nil, withMessage message: String, options: (String)...) {
		let storyboard = UIStoryboard(name: K.NibName.popupAlertView, bundle: nil)
		let customAlert = storyboard.instantiateViewController(identifier: K.NibName.popupAlertView) as! PopupAlertView
		
		customAlert.providesPresentationContextTransitionStyle = true
		customAlert.definesPresentationContext = true
		customAlert.modalPresentationStyle = .overCurrentContext
		customAlert.modalTransitionStyle = .crossDissolve
		
		customAlert.delegate = self
		customAlert.titleText = title
		customAlert.popupType = .normal
		customAlert.messageText = message
		customAlert.cancelButtonIsHidden = true
		
		present(customAlert, animated: true, completion: nil)
	}
}
