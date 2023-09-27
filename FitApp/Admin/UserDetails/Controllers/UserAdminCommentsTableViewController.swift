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
            viewModel.adminReadMessage(for: indexPath.row)
			selectedEditCellIndex = indexPath
			presentTextFieldAlert(withTitle: "מה תרצו לכתוב?", withMessage: cellData.text, options: "עדכן", "סגור", alertNumber: 1)
		}
	}
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.getCommentsCount
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.userCommentsCell, for: indexPath) as! UserCommentsTableViewCell
		
        if viewModel.hasComments {
			let cellData = viewModel.getCommentsFor(row: indexPath.row)
			
			cell.nameLabel.isHidden = false
			cell.dateLabel.isHidden = false
            cell.isReadIndicatorView.isHidden = !viewModel.showUnreadComment(for: indexPath.row)
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
			viewModel.removeComment(row: indexPath.row) { error in
				if error != nil {
					self.presentOkAlert(withMessage: "המחיקה נכשלה אנה נסו שנית")
				}
			}
            tableView.endUpdates()
		}
	}
}

	// MARK: - Functions
extension UserAdminCommentsTableViewController {
	
	fileprivate func bindViewModel() {
		Spinner.shared.show()

		viewModel.comments.bind {
			data in
            
            Spinner.shared.stop()
            
			if data != nil {
				DispatchQueue.main.async {
					self.tableView.reloadData()
				}
			}
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
        customAlert.cameraButtonIsHidden = false
        
		if options.count == 3 {
			customAlert.doNotShowText = options.last
		}
        
        customAlert.presentOnTop()
	}
}

	// MARK: - Delegates
extension UserAdminCommentsTableViewController: PopupAlertViewDelegate  {
	
	func okButtonTapped(alertNumber: Int, selectedOption: String?, textFieldValue: String?) {
		guard let commentText = textFieldValue else { return }
		
		switch alertNumber {
		case 1:
			guard let selectedCellRow = selectedEditCellIndex?.row else { return }
            let originalText = viewModel.getCommentsFor(row: selectedCellRow).text
            
            if let text = textFieldValue {
                let trimmedText = text.replacingOccurrences(of: originalText, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                
                if Array(trimmedText).isEmpty {
                    DispatchQueue.main.async {
                        self.presentOkAlert(withMessage: "לא הוזן טקסט")
                    }
                    return
                }
                
                let currentDate = "בתאריך: " + Date().fullDateString
                let author = "עודכן על ידי: " + UserProfile.defaults.name!
                let updateText = (originalText + "\n\n\(author)\n\(currentDate)\n\n" + trimmedText)
                
                viewModel.updateComment(text: updateText, row: selectedCellRow)
            } else {
                DispatchQueue.main.async {
                    self.presentOkAlert(withMessage: "הוספת ההערה נכשלה אנה נסו במועד מאוחר שוב")
                }
            }
		default:
			viewModel.createComment(with: commentText) { error in
				if error != nil {
                    DispatchQueue.main.async {
                        self.presentOkAlert(withMessage: "הוספת ההערה נכשלה אנה נסו במועד מאוחר יותר")
                    }
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
    func cameraButtonTapped(alertNumber: Int) {
        print("Camera")
    }
}
