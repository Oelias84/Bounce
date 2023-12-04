//
//  SettingsOptionsTableViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 28/01/2021.
//

import UIKit

enum SettingsContentType {
    
    case nutritios
    case mostHungry
    case fitnessLevel
    case notifications
}

class SettingsOptionsTableViewController: UIViewController {
    
    var contentType: SettingsContentType!
    private var viewModel: SettingsOptionsViewModel!
    
    @IBOutlet weak var topBarView: BounceNavigationBarView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTopBar()
        registerCells()
        viewModel = SettingsOptionsViewModel(contentType: contentType, for: self)
        
        if contentType == .notifications {
            viewModel.bindNotificationViewModelToController = {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if contentType == .notifications {
            viewModel.updateNotification()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if contentType == .fitnessLevel {
            WorkoutManager.shared.removePreferredWorkoutData {
                // Reloading manager data
                WorkoutManager.shared.loadData()
                // Update server
                UserProfile.updateServer()
                // Remove Spinner
                Spinner.shared.stop()
            }
        }
    }
}

//MARK: - Delegate
extension SettingsOptionsTableViewController: NotificationSwitchTableViewCellDelegate {
    
    func notificationSwitchAction(_ sender: UISwitch) {
        if UserProfile.defaults.showWeightAlertNotification != nil {
            UserProfile.defaults.showWeightAlertNotification?.toggle()
        } else {
            UserProfile.defaults.showWeightAlertNotification = false
        }
    }
}
extension SettingsOptionsTableViewController: BounceNavigationBarDelegate {
    
    func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
extension SettingsOptionsTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.getNumberOfSections()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch contentType {
        case .notifications:
            if section == 0 {
                return viewModel.getNumberOfRows()
            } else {
                return viewModel.getNumberOfNotificationsRows()
            }
        default:
            return viewModel.getNumberOfRows()
        }
        
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch contentType {
        case .notifications:
            if indexPath.section == 0 {
                if indexPath.row == 2 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.notificationSwitchCell, for: indexPath) as! NotificationSwitchTableViewCell
                    cell.notificationTextLabel.text = viewModel.getCellTitle(at: indexPath.row)
                    cell.delegate = self
                    cell.notificationSwitch.isOn = UserProfile.defaults.showWeightAlertNotification ?? true
                    return cell
                } else {
                    return getSettingOptionCell(for: indexPath)
                }
            } else {
                return getSettingOptionCell(for: indexPath)
            }
        default:
            switch indexPath.section {
            case 1:
                let cellData = viewModel.getNotificationCell(at: indexPath.row)
                let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.notificationCell, for: indexPath) as! NotificationTableViewCell
                cell.separatorInset = UIEdgeInsets(top: 0.0, left: cell.bounds.size.width - 10, bottom: 0.0, right: 0.0)
                cell.accessoryView = viewModel.getNotificationCellAccessoryView(at: indexPath)
                cell.notification = cellData
                return cell
            default:
                return getSettingOptionCell(for: indexPath)
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelect(at: indexPath)
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard contentType == .notifications && indexPath.section == 1 else { return false }
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            self.tableView.beginUpdates()
            viewModel.removeNotification(at: indexPath)
            self.tableView.deleteRows(at: [indexPath], with: .middle)
            self.tableView.endUpdates()
        }
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return section == 1 ? UIView() : nil
    }
}

//MARK: - Functions
extension SettingsOptionsTableViewController {
    
    private func registerCells() {
        tableView.register(UINib(nibName: K.NibName.notificationTableViewCell, bundle: nil), forCellReuseIdentifier: K.CellId.notificationCell)
        tableView.register(UINib(nibName: K.NibName.notificationSwitchTableViewCell, bundle: nil), forCellReuseIdentifier: K.CellId.notificationSwitchCell)
    }
    private func setupTopBar() {
        topBarView.delegate = self
        switch contentType {
        case .fitnessLevel:
            topBarView.nameTitle = "רמת פעילות"
        case .mostHungry:
            topBarView.nameTitle = StaticStringsManager.shared.getGenderString?[21] ?? ""
        default:
            topBarView.nameTitle = "רמת קושי"
        }
        topBarView.isCameraButton = true
        topBarView.isBackButtonHidden = false
        topBarView.isMotivationHidden = true
        topBarView.isDayWelcomeHidden = true
        topBarView.isProfileButtonHidden = true
        topBarView.isDayWelcomeHidden = true
        topBarView.isMessageButtonHidden = true
    }
    private func getSettingOptionCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.CellId.settingsOptionCell)!
        cell.separatorInset = .zero
        cell.selectionStyle = .none
        cell.accessoryView = viewModel.getNotificationCellAccessoryView(at: indexPath)
        
        if contentType == .notifications, indexPath.section == 1 {
            cell.textLabel?.text = viewModel.getNotificationCellTitle(at: indexPath.row)
        } else {
            cell.textLabel?.text = viewModel.getCellTitle(at: indexPath.row)
        }
        return cell
    }
}

