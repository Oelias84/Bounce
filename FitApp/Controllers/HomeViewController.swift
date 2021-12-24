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
	private let weightAlertsManager = WeightAlertsManager()

	private var carbsRingLayer: RingProgressView!
	private var fatRingLayer: RingProgressView!
	private var proteinRingLayer: RingProgressView!
	
	private var hasProgressView = false
	private var didFinishOnboarding = false
	
	let shared = Spinner()
	var hud = JGProgressHUD()
	
	private lazy var boardManager: BLTNItemManager = {
		let item = BLTNPageItem(title: "שמחים שהצטרפת אלינו :)")
		item.isDismissable = false
		item.descriptionText = "לחצי כאן כדי שנוכל להכיר אותך ולהתאים לך את המסלול הטוב ביותר"
		item.actionButtonTitle = "בואי נתחיל"
		item.actionHandler = { _ in
			self.startQuestionnaire()
		}
		return BLTNItemManager(rootItem: item)
	}()
	private lazy var titleStackView: UIStackView = {
		let titleLabel = UILabel()
		titleLabel.textAlignment = .center
		titleLabel.text = "מעקב שקילה"
		let stackView = UIStackView(arrangedSubviews: [titleLabel])
		return stackView
	}()
	
	@IBOutlet weak var tipContainerView: UIView!
	
	@IBOutlet weak var caloriesLabel: UILabel!
	@IBOutlet weak var fatCountLabel: UILabel!
	@IBOutlet weak var carbsCountLabel: UILabel!
	@IBOutlet weak var proteinCountLabel: UILabel!
	@IBOutlet weak var circularProgress: UIView!
	
	@IBOutlet weak var fatTargateLabel: UILabel!
	@IBOutlet weak var carbsTargateLabel: UILabel!
	@IBOutlet weak var proteinTargateLabel: UILabel!
	
	@IBOutlet weak var topBarView: BounceNavigationBarView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		showLoading()
		
		if (UserProfile.defaults.finishOnboarding ?? false) {
			viewModel.fetchMeals()
			setupMotivationText()
			
			viewModel.bindToMealViewModel {
				[unowned self] in
				self.stopLoading()
				self.setupProgressLabels()
				self.setUpProgressView()
			}
		}
		setupNavigationBarView()
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.clear()
		
		if !(UserProfile.defaults.finishOnboarding ?? false) {
			boardManager.showBulletin(above: self)
			boardManager.allowsSwipeInteraction = false
		}
		setUpProgressTextFields()
		setupProgressLabels()
		checkWeightState()
		checkMealsState()
		
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

//MARK: - Functions
extension HomeViewController {
	
	private func startQuestionnaire() {
		let storyboard = UIStoryboard(name: K.StoryboardName.questionnaire, bundle: nil)
		let questionnaireVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.questionnaireNavigation)
		
		questionnaireVC.modalPresentationStyle = .fullScreen
		boardManager.dismissBulletin()
		didFinishOnboarding = true
		self.present(questionnaireVC, animated: true, completion: nil)
	}
	
	private func updateWheels() {
		DispatchQueue.main.async {
			[unowned self] in
			perform(#selector(animateProgress), with: nil, afterDelay: 0.5)
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
			[unowned self] in
			
			setUpProgressTextFields()
			
			fatCountLabel.text = viewModel.getFatCurrentValue
			carbsCountLabel.text = viewModel.getCarbsCurrentValue
			proteinCountLabel.text = viewModel.getProteinCurrentValue
			caloriesLabel.text = viewModel.getUserExceptionalCalories
			
			if let view = titleStackView.subviews[0] as? UILabel {
				view.text = viewModel.getMealDate
			}
		}
	}
	private func setupMotivationText() {
		topBarView.motivationText = UserProfile.defaults.motivationText
		
		viewModel.getMotivationText() {
			[weak self] motivation in
			guard let self = self else { return }
			
			let lastMotivationDate = UserProfile.defaults.lastMotivationDate
			
			if lastMotivationDate == nil || lastMotivationDate!.onlyDate > Date().onlyDate {
				UserProfile.defaults.lastMotivationDate = Date()
				UserProfile.defaults.motivationText = motivation
				
			} else {
				DispatchQueue.main.async {
					[unowned self] in
					self.topBarView.motivationText = UserProfile.defaults.motivationText
				}
			}
		}
	}
	private func setupNavigationBarView() {
		topBarView.delegate = self
		topBarView.nameTitle = UserProfile.defaults.name  ?? ""
		topBarView.isBackButtonHidden = true
		topBarView.isClearButtonHidden = true
	}
	private func setUpProgressTextFields() {
		fatCountLabel.text = viewModel.getFatCurrentValue
		carbsCountLabel.text = viewModel.getCarbsCurrentValue
		proteinCountLabel.text = viewModel.getProteinCurrentValue
		fatTargateLabel.text = "/\(viewModel.getFatTargateValue)"
		carbsTargateLabel.text = "/\(viewModel.getCarbsTargateValue)"
		proteinTargateLabel.text = "/\(viewModel.getProteinTargateValue)"
	}
	
	private func checkMealsState() {
		viewModel.checkDidFinishDailyMeals {
			[unowned self] in
			self.presentAlert(withTitle: "מעקב ארוחות", withMessage: "ראינו שלא השלמת את מעקב האורחות היומי שלך",
							  options: "עבור למסך ארוחות", "ביטול") {
				selection in
				switch selection {
				case 0:
					self.tabBarController?.selectedIndex = 1
				default:
					break
				}
			}
		}
	}
	private func checkWeightState() {
		viewModel.checkAddWeight {
			self.presentAlert(withTitle: "זמן להישקל", withMessage: "תזכורת קטנה לא לשכוח להישקל הבוקר לפני שאת מתחילה את היום :)", options: "עבור למסך שקילה", "ביטול") {
				[weak self] selection in
				guard let self = self else { return }
				
				switch selection {
				case 0:
					if let navC = self.tabBarController?.viewControllers?[3] as? UINavigationController {
						let weightVC = navC.viewControllers.last as! WeightProgressViewController
						
						self.tabBarController?.selectedIndex = 3
						DispatchQueue.main.async {
							weightVC.addWeightButtonAction(self)
						}
					}
				case 1:
					//turns weight tab bar icon to red for alerting the user
					if let weightTab = self.tabBarController?.tabBar.items?[3] {
						weightTab.image = UIImage(named:"ScaleIcon")?
							.withTintColor(.red, renderingMode: .alwaysOriginal)
					}
				default:
					break
				}
			}
		}
	}
	
	@objc func animateProgress() {
		DispatchQueue.main.async {
			[unowned self] in
			UIView.animate(withDuration: 1.0) {
				self.proteinRingLayer.progress = self.viewModel.proteinPercentage
				self.carbsRingLayer.progress = self.viewModel.carbsPercentage
				self.fatRingLayer.progress = self.viewModel.fatPercentage
			}
		}
	}
	
	func showLoading() {
		hud.backgroundColor = #colorLiteral(red: 0.6394728422, green: 0.659519434, blue: 0.6805263758, alpha: 0.2546477665)
		hud.textLabel.text = "טוען"
		hud.show(in: self.view)
	}
	func stopLoading() {
		hud.dismiss()
	}
}

