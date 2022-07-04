//
//  UserCommentsTableViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 03/07/2022.
//

import UIKit
import SpreadsheetView

class UserAdminCommentsTableViewController: UITableViewController {

	var viewModel: UserAdminCommentsViewModel!
	private var selectedEditCellIndex: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
		
		bindViewModel()
    }

	@IBAction func addCommentButtonAction(_ sender: Any) {
		presentTextFieldAlert(withTitle: "הזינו כאן את ההערה:", withMessage: "", options: "שלח", "ביטול", alertNumber: 0)
	}
}

	// MARK: - Table view data source
extension UserAdminCommentsTableViewController {
    
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if viewModel.hasComments {
			let cellData = viewModel.getCommentsFor(row: indexPath.row)
			selectedEditCellIndex = indexPath
			presentTextFieldAlert(withTitle: "מה תרצו לכתוב?", withMessage: cellData.text, options: "עדכן", "סגור", alertNumber: 1)
		}
	}
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.getCommentsCount ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.userCommentsCell, for: indexPath) as! UserCommentsTableViewCell
		
		if viewModel.hasComments {
			let cellData = viewModel.getCommentsFor(row: indexPath.row)
			
			cell.nameLabel.isHidden = false
			cell.dateLabel.isHidden = false
			cell.nameLabel.text = cellData.sender
			cell.commentTextLabel.text = cellData.text
			cell.dateLabel.text = cellData.commentDate
		} else {
			cell.commentTextLabel.text = "אין הערות"
			cell.nameLabel.isHidden = true
			cell.dateLabel.isHidden = true
			cell.accessoryType = .none
		}
        return cell
    }
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		viewModel.hasComments
	}
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			tableView.beginUpdates()
			self.viewModel.removeComment(row: indexPath.row) { error in
				if error != nil {
					self.presentOkAlert(withMessage: "המחיקה נכשלה אנה נסו שנית")
				}
				tableView.deleteRows(at: [indexPath], with: .fade)
				tableView.endUpdates()
			}
		}
	}
}

	// MARK: - Functions
extension UserAdminCommentsTableViewController {
	
	fileprivate func bindViewModel() {
		Spinner.shared.show(self.view)
		
		viewModel.comments.bind {
			data in
			
			if data != nil {
				DispatchQueue.main.async {
					self.tableView.reloadData()
					Spinner.shared.stop()
				}
			}
			Spinner.shared.stop()
		}
	}
	private func presentTextFieldAlert(withTitle title: String? = nil, withMessage message: String, options: (String)..., alertNumber: Int) {
		let storyboard = UIStoryboard(name: K.NibName.popupAlertView, bundle: nil)
		let customAlert = storyboard.instantiateViewController(identifier: K.NibName.popupAlertView) as! PopupAlertView
		
		customAlert.providesPresentationContextTransitionStyle = true
		customAlert.definesPresentationContext = true
		customAlert.modalPresentationStyle = .overCurrentContext
		customAlert.modalTransitionStyle = .crossDissolve
		
		customAlert.delegate = self
		customAlert.titleText = title
		customAlert.popupType = .textBox
		customAlert.alertNumber = alertNumber
		
		switch alertNumber {
		case 1:
			customAlert.textBoxText = message
		default:
			customAlert.messageText = message
		}
		
		customAlert.okButtonText = options[0]
		customAlert.cancelButtonText = options[1]
		
		if options.count == 3 {
			customAlert.doNotShowText = options.last
		}
		present(customAlert, animated: true, completion: nil)
	}
}

	// MARK: - Delegates
extension UserAdminCommentsTableViewController: PopupAlertViewDelegate  {
	
	func okButtonTapped(alertNumber: Int, selectedOption: String?, textFieldValue: String?) {
		guard let commentText = textFieldValue else { return }
		
		switch alertNumber {
		case 1:
			guard let selectedCellRow = selectedEditCellIndex?.row else { return }
			let cellData = viewModel.getCommentsFor(row: selectedCellRow)
			viewModel.updateComment(text: commentText, row: selectedCellRow)
		default:
			viewModel.addNewComment(with: commentText) { error in
				if error != nil {
					self.presentOkAlert(withMessage: "הוספת ההערה נכשלה אנה נסו במועד מאוחר יותר")
				}
			}
		}

	}
	func cancelButtonTapped(alertNumber: Int) {
		return
	}
	func thirdButtonTapped(alertNumber: Int) {
		return
	}
}
