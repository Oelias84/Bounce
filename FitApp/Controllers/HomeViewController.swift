//
//  HomeViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 28/11/2020.
//

import UIKit
import BLTNBoard
import FirebaseAuth
import MKRingProgressView

class HomeViewController: UIViewController {
	
	private var viewModel = HomeViewModel()
	
	private var carbsRingLayer: RingProgressView!
	private var fatRingLayer: RingProgressView!
	private var proteinRingLayer: RingProgressView!
	
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
	@IBOutlet weak var progressWheelsContainerView: UIView!
	@IBOutlet weak var progressDataContainerView: UIView!
	
	@IBOutlet weak var userMotivationTextLabel: UILabel!
	
	@IBOutlet weak var caloriesLabel: UILabel!
	@IBOutlet weak var fatCountLabel: UILabel!
	@IBOutlet weak var carbsCountLabel: UILabel!
	@IBOutlet weak var proteinCountLabel: UILabel!
	@IBOutlet weak var circularProgress: UIView!
	
	@IBOutlet weak var fatTargateLabel: UILabel!
	@IBOutlet weak var carbsTargateLabel: UILabel!
	@IBOutlet weak var proteinTargateLabel: UILabel!
	
	@IBOutlet weak var profileButton: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.titleView = titleStackView
		
		setupView()
		setupMotivationText()

		checkMealsState()
		checkWeightState()
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if !(UserProfile.defaults.finishOnboarding ?? false) {
			boardManager.showBulletin(above: self)
			boardManager.allowsSwipeInteraction = false
		} else {
			viewModel.fetchMeals()
			viewModel.bindToMealViewModel {
				[unowned self] in
				Spinner.shared.stop()
				setupProgressLabels()
			}
		}
		self.setupProgressLabels()
	}
	
	@IBAction func chatButtonAction(_ sender: Any) {
		openChat()
	}
	@IBAction func profileButtonAction(_ sender: Any) {
		let storyboard = UIStoryboard(name: K.StoryboardName.settings, bundle: nil)
		let settingsVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.SettingsViewController)
		
		self.navigationController!.pushViewController(settingsVC, animated: true)
	}
}

extension HomeViewController {
	
	private func setupView() {
		tipContainerView.dropShadow()
		progressDataContainerView.dropShadow()
		progressWheelsContainerView.dropShadow()
		if let image = UserProfile.defaults.profileImageImageUrl?.showImage {
			profileButton.setImage( image.circleMasked, for: .normal)
		}
	}
	private func setUpProgressView() {
		
		circularProgress.subviews.forEach {
			$0.removeFromSuperview()
		}
		let circleContainerHeight = circularProgress.bounds.height
		let circleContainerWidth = circularProgress.bounds.width
		
		let ringWitdth: CGFloat = 30
		let proteinRingMeasure: CGFloat = 20.0
		let carbsRingMeasure: CGFloat = 100.0
		let fatinRingMeasure: CGFloat = 180.0
		
		proteinRingLayer = RingProgressView(frame: CGRect(x: proteinRingMeasure/2, y: proteinRingMeasure/2,
														  width: circleContainerWidth - proteinRingMeasure, height: circleContainerHeight - proteinRingMeasure))
		proteinRingLayer.startColor = viewModel.getProteinColor
		proteinRingLayer.endColor = #colorLiteral(red: 0.9921568627, green: 0.9882352941, blue: 0.2784313725, alpha: 1)
		proteinRingLayer.ringWidth = ringWitdth
		proteinRingLayer.progress = 0.0
		
		carbsRingLayer = RingProgressView(frame: CGRect(x: carbsRingMeasure/2, y: carbsRingMeasure/2,
														width: circleContainerWidth - carbsRingMeasure, height: circleContainerHeight - carbsRingMeasure))
		carbsRingLayer.startColor = viewModel.getCarbsColor
		carbsRingLayer.endColor = #colorLiteral(red: 0.568627451, green: 0.9176470588, blue: 0.8941176471, alpha: 1)
		carbsRingLayer.ringWidth = ringWitdth
		carbsRingLayer.progress = 0.0
		
		fatRingLayer = RingProgressView(frame: CGRect(x: fatinRingMeasure/2, y: fatinRingMeasure/2,
													  width: circleContainerWidth - fatinRingMeasure, height: circleContainerHeight - fatinRingMeasure))
		fatRingLayer.startColor = viewModel.getFatColor
		fatRingLayer.endColor = #colorLiteral(red: 0.9607843137, green: 0.6862745098, blue: 0.09803921569, alpha: 1)
		fatRingLayer.ringWidth = ringWitdth
		fatRingLayer.progress = 0.0
		
		circularProgress.addSubview(proteinRingLayer)
		circularProgress.addSubview(carbsRingLayer)
		circularProgress.addSubview(fatRingLayer)
		
		DispatchQueue.main.async {
			[unowned self] in
			
			perform(#selector(animateProgress), with: nil, afterDelay: 0.1)
		}

	}
	private func setupProgressLabels() {
		
		setUpProgressView()
		setUpProgressTextFields()
		
		caloriesLabel.text = viewModel.getUserCalories
		fatCountLabel.text = viewModel.getFatCurrentValue
		carbsCountLabel.text = viewModel.getCarbsCurrentValue
		proteinCountLabel.text = viewModel.getProteinCurrentValue

		if let view = titleStackView.subviews[0] as? UILabel {
			view.text = viewModel.getMealDate
		}
	}
	private func setupMotivationText() {
		
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
					self.userMotivationTextLabel.text = UserProfile.defaults.motivationText
				}
			}
		}
	}
	private func setUpProgressTextFields() {
		
		navigationItem.title = "היי \(UserProfile.defaults.name  ?? ""),"
		fatCountLabel.text = viewModel.getFatCurrentValue
		carbsCountLabel.text = viewModel.getCarbsCurrentValue
		proteinCountLabel.text = viewModel.getProteinCurrentValue
		fatTargateLabel.text = "מתוך \(viewModel.getFatTargateValue)"
		carbsTargateLabel.text = "מתוך \(viewModel.getCarbsTargateValue)"
		proteinTargateLabel.text = "מתוך \(viewModel.getProteinTargateValue)"
	}
	private func checkWeightState() {
		viewModel.checkAddWeight {
			self.presentAlert(withTitle: "זמן להישקל", withMessage: "תזכורת קטנה לא לשכוח להישקל הבוקר לפני שאת מתחילה את היום :)", options: "עבור למסך שקילה", "ביטול") {
				selection in
				switch selection {
				case 0:
					if let navC = self.tabBarController?.viewControllers?[3] as? UINavigationController {
						let weightVC = navC.viewControllers.last as! WeightProgressViewController
						
						self.tabBarController?.selectedIndex = 3
						DispatchQueue.main.async { [weak self] in
							guard let self = self else { return }
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
	private func openChat() {
		let chatStoryboard = UIStoryboard(name: K.StoryboardName.chat, bundle: nil)
		let chatsVC = chatStoryboard.instantiateViewController(identifier: K.ViewControllerId.ChatsViewController)
			as ChatsViewController
		
		self.navigationController?.pushViewController(chatsVC, animated: true)
	}
	private func startQuestionnaire() {
		let storyboard = UIStoryboard(name: K.StoryboardName.questionnaire, bundle: nil)
		let questionnaireVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.questionnaireNavigation)
		
		questionnaireVC.modalPresentationStyle = .fullScreen
		boardManager.dismissBulletin()
		self.present(questionnaireVC, animated: true, completion: nil)
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
}
