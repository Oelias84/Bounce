//
//  SettingsOptionsTableViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 28/01/2021.
//

import UIKit

enum SettingsContentType {
	
	case mostHungry
	case fitnessLevel
	case notifications
}

class SettingsOptionsTableViewController: UITableViewController {
	
	var contentType: SettingsContentType!
	private var viewModel: SettingTableViewModel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		viewModel = SettingTableViewModel(contentType: contentType, for: self)
		if contentType == .notifications {
			let notificationNib = UINib(nibName: K.NibName.notificationTableViewCell, bundle: nil)
			tableView.register(notificationNib, forCellReuseIdentifier: K.CellId.notificationCell)
			viewModel.bindNotificationViewModelToController = {
				DispatchQueue.main.async {
					self.tableView.reloadData()
				}
			}
		}
		self.title = viewModel.getVCTitle()
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if contentType == .notifications {
			viewModel.updateNotification()
		}
	}
	
	// MARK: - Table view data source
	override func numberOfSections(in tableView: UITableView) -> Int {
		return viewModel.getNumberOfSections()
	}
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if section == 1 {
			return viewModel.getNumberOfNotificationsRows()
		}
		return viewModel.getNumberOfRows()
	}
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		
		if section == 1 {
			let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
			let label = UILabel()

			label.frame = CGRect(x: 0, y: 0, width: headerView.frame.width-20, height: headerView.frame.height-10)
			label.text = "התראות פעילות:"
			label.font = .systemFont(ofSize: 20, weight: .medium)
			headerView.addSubview(label)
			return headerView
		}
		return nil
	}
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		switch indexPath.section {
		case 1:
			let cellData = viewModel.getNotificationCell(at: indexPath.row)
			let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.notificationCell, for: indexPath) as! NotificationTableViewCell
			cell.separatorInset = UIEdgeInsets(top: 0.0, left: cell.bounds.size.width - 10, bottom: 0.0, right: 0.0)
			cell.accessoryView = viewModel.getNotificationTitleCellAccessoryView(at: indexPath.row)
			cell.notification = cellData
			return cell
		default:
			let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.settingsOptionCell)!
			cell.separatorInset = .zero
			cell.selectionStyle = .none
			cell.textLabel?.text = viewModel.getCellTitle(at: indexPath.row)
			return cell
		}
	}
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		viewModel.didSelect(at: indexPath)
	}
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		
		guard contentType == .notifications && indexPath.section == 1 else { return false }
		return true
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		
		if (editingStyle == .delete) {
			self.tableView.beginUpdates()
			viewModel.removeNotification(at: indexPath)
			self.tableView.deleteRows(at: [indexPath], with: .middle)
			self.tableView.endUpdates()
		}
	}
	override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		
		return section == 1 ? UIView() : nil
	}
}
