//
//  ChatsViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 05/02/2021.
//

import UIKit

class ChatsViewController: UITableViewController {
	
	private var chatsViewModel: ChatsViewModel!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.register(UINib(nibName: K.NibName.chatTableViewCell, bundle: nil), forCellReuseIdentifier: K.CellId.chatCell)
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(addChatDidTapped))
		navigationController?.navigationBar.prefersLargeTitles = true

		if let navView = navigationController?.view {
			Spinner.shared.show(navView)
		}
		
		chatsViewModel = ChatsViewModel()
		chatsViewModel.bindChatsViewModelToController = {
			Spinner.shared.stop()
			self.updateUI()
		}
		alertForDirectingToQA()
    }
		
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return chatsViewModel.getChatsCount ?? 0
	}
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.chatCell) as! ChatTableViewCell
		let cellData = chatsViewModel.getChatFor(row: indexPath.row)
		
		cell.chat = cellData
		return cell
	}
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let chatData = chatsViewModel.getChatFor(row:indexPath.row)
		
		let chatCV = ChatViewController(with: chatData.otherUserEmail, id: chatData.id)
		chatCV.title = chatData.name
		navigationController?.pushViewController(chatCV, animated: true)
	}
}
 
extension ChatsViewController {
	
	private func updateUI() {
		DispatchQueue.main.async {
			Spinner.shared.stop()
			self.tableView.reloadData()
		}
	}
	private func createNewChat(result: [String:String]) {
		guard let name = result["name"], let email = result["email"] else {
			return
		}
		let chatVC = ChatViewController(with: email, id: nil)
		
		chatVC.isNewChat = true
		chatVC.title = name
		navigationController?.pushViewController(chatVC, animated: true)
	}
	private func alertForDirectingToQA() {
		if UserProfile.defaults.showQaAlert == nil {
			presentAlert(withTitle: "רק רצינו לספר לך", withMessage: "הכנו מאמר שאלות תשובות נפוצות וכדאי לך לעבור עליו, אם את לא מוצאת תשובה, אנחנו פה לעזור לך :)", options: "אישור", "ביטול", "אל תציג שוב") { selection in
				switch selection {
				case 0:
					if let navC = self.tabBarController?.viewControllers?[4] as? UINavigationController {
						let tableC = navC.viewControllers.last as! ArticlesViewController
						
						tableC.openFromChat = true
						self.tabBarController?.selectedIndex = 4
						self.navigationController?.popToRootViewController(animated: false)
					}
				case 2:
					UserProfile.defaults.showQaAlert = false
				default:
					break
				}
			}
		}
	}
	
	@objc private func addChatDidTapped() {
		let chatVC = storyboard?.instantiateViewController(identifier: K.ViewControllerId.NewChatViewController) as! NewChatViewController
		let nav = UINavigationController(rootViewController: chatVC)
		
		chatVC.completion = { [weak self]
			result in
			guard let self = self else { return }
			self.createNewChat(result: result)
		}
		
		nav.modalTransitionStyle = .coverVertical
		nav.modalPresentationStyle = .fullScreen
		present(nav, animated: true)
	}
	
//	func createOfUser() {
//		let user = User(firsName: "תמיכה", lastName: "", email: "support@mail.com")
//
//		GoogleDatabaseManager.shared.insertUser(with: user) {
//			[weak self] success in
//			guard let self = self else { return }
//
//			switch success {
//			case true:
//				print("yes")
//
//			case false:
//				print("No")
//			}
//		}
//	}
}
