//
//  HomeViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 28/11/2020.
//

import UIKit
import BLTNBoard
import FirebaseAuth
import JGProgressHUD
import MKRingProgressView

class HomeViewController: UIViewController {
	
	private var viewModel = HomeViewModel()
	private var weightAlertsManager: WeightAlertsManager!
	
	private var carbsRingLayer: RingProgressView!
	private var fatRingLayer: RingProgressView!
	private var proteinRingLayer: RingProgressView!
	
	private var hasProgressView = false
	private var didFinishOnboarding = false
	
	@IBOutlet weak var tipContainerView: UIView!
	
	@IBOutlet weak var caloriesLabel: UILabel!
	@IBOutlet weak var fatCountLabel: UILabel!
	@IBOutlet weak var carbsCountLabel: UILabel!
	@IBOutlet weak var proteinCountLabel: UILabel!
	@IBOutlet weak var circularProgress: UIView!
	
	@IBOutlet weak var fatTargetLabel: UILabel!
	@IBOutlet weak var carbsTargetLabel: UILabel!
	@IBOutlet weak var proteinTargetLabel: UILabel!
	
	@IBOutlet weak var progressStackView: UIStackView!
	
	@IBOutlet weak var topBarView: BounceNavigationBarView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		changeStackSpacing()
		weightAlertsManager = WeightAlertsManager()
        IOSKeysManager.shared

		if (UserProfile.defaults.finishOnboarding ?? false) {
			viewModel.bindToMealViewModel {
				[weak self] in
				guard let self = self else { return }
				
				Spinner.shared.stop()
				self.setupProgressLabels()
				self.setUpProgressView()
			}
		}
		setupNavigationBarView()
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setupProgressLabels()
		topBarView.setImage()
		
		let queue = OperationQueue()
		queue.addOperation {
			self.setupMotivationText()
		}
		queue.addOperation {
			self.checkWeightAlert()
		}
		queue.addOperation {
			self.checkMealsState()
		}
		queue.waitUntilAllOperationsAreFinished()
	}
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		setUpProgressView()
	}
}

//MARK: - Delegates
extension HomeViewController: BounceNavigationBarDelegate {
	
	func backButtonTapped() {}
}
extension HomeViewController: PopupAlertViewDelegate {
	
	func okButtonTapped(alertNumber: Int, selectedOption: String?, textFieldValue: String?) {
		switch alertNumber {
		case 1:
			self.tabBarController?.selectedIndex = 1
		case 2:
			self.tabBarController?.selectedIndex = 3
		default:
			break
		}
	}
	func cancelButtonTapped(alertNumber: Int) {
		switch alertNumber {
		case 2:
			//turns weight tab bar icon to red for alerting the user
			if let weightTab = self.tabBarController?.tabBar.items?[3] {
				weightTab.image = UIImage(named:"Weight")?
					.withTintColor(.red, renderingMode: .alwaysOriginal)
			}
		default:
			break
		}
	}
	func thirdButtonTapped(alertNumber: Int) {
		return
	}
}

//MARK: - Functions
extension HomeViewController {
	
	private func updateWheels() {
		DispatchQueue.main.async {
			self.perform(#selector(self.animateProgress), with: nil, afterDelay: 0.5)
		}
	}
	private func setUpProgressView() {
		if hasProgressView {
			updateWheels()
			return
		}
		hasProgressView = true
		let circleContainerWidth = circularProgress.frame.width
		
		let ringWitdth: CGFloat = 28
		let proteinRingMeasure: CGFloat = 0.0
		let carbsRingMeasure: CGFloat = proteinRingMeasure + 80.0
		let fatinRingMeasure: CGFloat = carbsRingMeasure + 80.0
		
		proteinRingLayer = RingProgressView(frame: CGRect(x: 0, y: 0,
														  width: circleContainerWidth, height: circleContainerWidth))
		proteinRingLayer.startColor = viewModel.getProteinColor
		proteinRingLayer.endColor = viewModel.getProteinColor
		proteinRingLayer.ringWidth = ringWitdth
		proteinRingLayer.progress = 0.0
		proteinRingLayer.alpha = 0
		
		carbsRingLayer = RingProgressView(frame: CGRect(x: carbsRingMeasure/2, y: carbsRingMeasure/2,
														width: circleContainerWidth - carbsRingMeasure, height: circleContainerWidth - carbsRingMeasure))
		carbsRingLayer.startColor = viewModel.getCarbsColor
		carbsRingLayer.endColor = viewModel.getCarbsColor
		carbsRingLayer.ringWidth = ringWitdth
		carbsRingLayer.progress = 0.0
		carbsRingLayer.alpha = 0
		
		fatRingLayer = RingProgressView(frame: CGRect(x: fatinRingMeasure/2, y: fatinRingMeasure/2,
													  width: circleContainerWidth - fatinRingMeasure, height: circleContainerWidth - fatinRingMeasure))
		fatRingLayer.startColor = viewModel.getFatColor
		fatRingLayer.endColor = viewModel.getFatColor
		fatRingLayer.ringWidth = ringWitdth
		fatRingLayer.progress = 0.0
		fatRingLayer.alpha = 0
		
		self.circularProgress.addSubview(self.proteinRingLayer)
		self.circularProgress.addSubview(self.carbsRingLayer)
		self.circularProgress.addSubview(self.fatRingLayer)
		
		UIView.animate(withDuration: 0.2) {
			self.proteinRingLayer.alpha = 1
			self.carbsRingLayer.alpha = 1
			self.fatRingLayer.alpha = 1
			self.updateWheels()
		}
	}
	private func setupProgressLabels() {
		DispatchQueue.main.async {
			self.setUpProgressTextFields()
			
			self.fatCountLabel.text = self.viewModel.getFatCurrentValue
			self.carbsCountLabel.text = self.viewModel.getCarbsCurrentValue
			self.proteinCountLabel.text = self.viewModel.getProteinCurrentValue
			self.caloriesLabel.text = self.viewModel.getUserExceptionalCalories
		}
	}
    private func setupMotivationText() {
        viewModel.getMotivationText {
            DispatchQueue.main.async {
                self.topBarView.motivationText = UserProfile.defaults.motivationText ?? "..."
            }
        }
    }
	
	private func setupNavigationBarView() {
		topBarView.delegate = self
		topBarView.isProfileButtonHidden = false
		topBarView.nameTitle = UserProfile.defaults.name  ?? ""
		topBarView.isBackButtonHidden = true
		topBarView.isClearButtonHidden = true
        topBarView.motivationText = UserProfile.defaults.motivationText ?? "..."
	}
	private func setUpProgressTextFields() {
		fatCountLabel.text = viewModel.getFatCurrentValue
		carbsCountLabel.text = viewModel.getCarbsCurrentValue
		proteinCountLabel.text = viewModel.getProteinCurrentValue
		fatTargetLabel.text = "/\(viewModel.getFatTargateValue)"
		carbsTargetLabel.text = "/\(viewModel.getCarbsTargateValue)"
		proteinTargetLabel.text = "/\(viewModel.getProteinTargateValue)"
	}
	
	private func checkMealsState() {
		viewModel.checkDidFinishDailyMeals {
			DispatchQueue.main.async {
				self.presentAlert(withTitle: "מעקב ארוחות", withMessage: "ראינו שלא השלמת את מעקב הארחות היומי שלך", options: "עבור למסך ארוחות", "ביטול", alertNumber: 1)
			}
		}
	}
	private func checkWeightAlert() {
		let lastDate = UserProfile.defaults.lastWeightAlertPresentedDate
		
		if lastDate == nil {
			UserProfile.defaults.lastWeightAlertPresentedDate = Date()
			presentWeightAlert()
		} else if let lastDate = lastDate?.onlyDate, lastDate.isEarlier(than: Date().onlyDate) {
			UserProfile.defaults.lastWeightAlertPresentedDate = Date()
			presentWeightAlert()
		}
	}
	
	private func presentWeightAlert() {
		viewModel.checkAddWeight {
			DispatchQueue.main.async {
				self.presentAlert(withTitle: "זמן להישקל", withMessage: StaticStringsManager.shared.getGenderString?[39] ?? "", options: "מעבר למסך שקילה", "ביטול", alertNumber: 2)
			}
		}
	}
	
	@objc func animateProgress() {
		DispatchQueue.main.async {
			UIView.animate(withDuration: 1.0) {
				self.proteinRingLayer.progress = self.viewModel.proteinPercentage
				self.carbsRingLayer.progress = self.viewModel.carbsPercentage
				self.fatRingLayer.progress = self.viewModel.fatPercentage
			}
		}
	}
	func changeStackSpacing() {
		let window = UIApplication.shared.windows[0]
		let safeFrame = window.safeAreaLayoutGuide.layoutFrame
		let height = safeFrame.height
		progressStackView.spacing = height > 647.0 ? 84 : 24
	}
	
	private func presentAlert(withTitle title: String? = nil, withMessage message: String, options: (String)..., alertNumber: Int) {
		guard let window = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window else {
			return
		}
		let storyboard = UIStoryboard(name: "PopupAlertView", bundle: nil)
		let customAlert = storyboard.instantiateViewController(identifier: "PopupAlertView") as! PopupAlertView
		
		customAlert.providesPresentationContextTransitionStyle = true
		customAlert.definesPresentationContext = true
		customAlert.modalPresentationStyle = .overCurrentContext
		customAlert.modalTransitionStyle = .crossDissolve
		
		customAlert.delegate = self
		customAlert.titleText = title
		customAlert.messageText = message
		customAlert.alertNumber = alertNumber
		customAlert.okButtonText = options[0]
		customAlert.cancelButtonText = options[1]
		
		if options.count == 3 {
			customAlert.doNotShowText = options.last
		}
		
		window.rootViewController?.present(customAlert, animated: true, completion: nil)
	}
}

