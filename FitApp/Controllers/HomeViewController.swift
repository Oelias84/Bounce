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
    
    private var userProgress: UserProgress!
    private var mealViewModel: MealViewModel!
    
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
    
    private var carbsColor = #colorLiteral(red: 0.4980392157, green: 0.4980392157, blue: 0.8352941176, alpha: 1)
    private var fatColor = #colorLiteral(red: 0.9450980392, green: 0.1529411765, blue: 0.06666666667, alpha: 1)
    private var proteinColor = #colorLiteral(red: 0.1411764706, green: 0.9960784314, blue: 0.2549019608, alpha: 1)
    
    private var fatStartValue = 0.0
    private var carbsStartValue = 0.0
    private var proteinStartValue = 0.0
	
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
		
        mealViewModel = MealViewModel.shared
        mealViewModel.bindMealViewModelToController = {
			Spinner.shared.stop()
            self.setupProgressLabels()
        }
		
		setupView()
		checkAddWeight()
		setMotivationText()
		checkDidFinishDailyMeals()
	}
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !(UserProfile.defaults.finishOnboarding ?? false) {
            boardManager.showBulletin(above: self)
            boardManager.allowsSwipeInteraction = false
        } else {
            mealViewModel.fetchData()
        }
        setupProgressLabels()
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
	private func setMotivationText() {
		let lastMotivationDate = UserProfile.defaults.lastMotivationDate
		
		getMotivationText() { [weak self] motivation in
			guard let self = self else { return }

			if lastMotivationDate == nil || lastMotivationDate!.onlyDate > Date().onlyDate {
				UserProfile.defaults.lastMotivationDate = Date()
				UserProfile.defaults.motivationText = motivation
				DispatchQueue.main.async { [weak self] in
					guard let self = self else { return }
					self.userMotivationTextLabel.text = UserProfile.defaults.motivationText
				}
			} else {
				DispatchQueue.main.async { [weak self] in
					guard let self = self else { return }
					self.userMotivationTextLabel.text = UserProfile.defaults.motivationText
				}
			}
		}
	}

	
    private func setUpProgressTextFields() {
		
		navigationItem.title = "היי \(UserProfile.defaults.name  ?? ""),"
        fatCountLabel.text = "\(fatStartValue)"
        carbsCountLabel.text = "\(carbsStartValue)"
        proteinCountLabel.text = "\(proteinStartValue)"
		fatTargateLabel.text = "מתוך \(userProgress.fatTarget)"
		carbsTargateLabel.text = "מתוך \(userProgress.carbsTarget)"
		proteinTargateLabel.text = "מתוך \(userProgress.proteinTarget)"
    }
	private func setupProgressLabels() {
		let manager = ConsumptionManager.shared
		let progress = mealViewModel.getProgress()
		
		userProgress = UserProgress(carbsTarget: manager.getDayCarbs, proteinTarget: manager.getDayProtein, fatTarget: manager.getDayFat, carbsProgress: progress.carbs, proteinProgress: progress.protein, fatProgress: progress.fats)
		
		configureProgress()
		setUpProgressTextFields()
		
		caloriesLabel.text = manager.getCalories
		fatCountLabel.text = "\(progress.fats)"
		carbsCountLabel.text = "\(progress.carbs)"
		proteinCountLabel.text = "\(progress.protein)"
		
		if let view = titleStackView.subviews[0] as? UILabel {
			view.text = mealViewModel.getMealStringDate()
		}
	}

    private func startQuestionnaire() {
        let storyboard = UIStoryboard(name: K.StoryboardName.questionnaire, bundle: nil)
        let questionnaireVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.questionnaireNavigation)
        
        questionnaireVC.modalPresentationStyle = .fullScreen
        boardManager.dismissBulletin()
        self.present(questionnaireVC, animated: true, completion: nil)
    }
	private func getMotivationText(completion: @escaping (String) -> Void) {
		
		var motivationText = "..."
		
		GoogleApiManager.shared.getMotivations { result in
			
			switch result {
			case .success(let motivations):
				if let motivations = motivations {
					if let lastMotivation = UserProfile.defaults.motivationText {
						motivationText = motivations.text.filter{ $0 != lastMotivation }[Int.random(in: 0...motivations.text.count-2)]
						completion(motivationText)
					} else {
						motivationText = motivations.text[Int.random(in: 0...motivations.text.count)]
						completion(motivationText)
					}
				}
			case .failure(let error):
				print(error)
			}
		}
	}

	private func configureProgress() {
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
		proteinRingLayer.startColor = proteinColor
		proteinRingLayer.endColor = #colorLiteral(red: 0.9921568627, green: 0.9882352941, blue: 0.2784313725, alpha: 1)
		proteinRingLayer.ringWidth = ringWitdth
		proteinRingLayer.progress = 0.0
		
		carbsRingLayer = RingProgressView(frame: CGRect(x: carbsRingMeasure/2, y: carbsRingMeasure/2,
														width: circleContainerWidth - carbsRingMeasure, height: circleContainerHeight - carbsRingMeasure))
		carbsRingLayer.startColor = carbsColor
		carbsRingLayer.endColor = #colorLiteral(red: 0.568627451, green: 0.9176470588, blue: 0.8941176471, alpha: 1)
		carbsRingLayer.ringWidth = ringWitdth
		carbsRingLayer.progress = 0.0
		
		fatRingLayer = RingProgressView(frame: CGRect(x: fatinRingMeasure/2, y: fatinRingMeasure/2,
													  width: circleContainerWidth - fatinRingMeasure, height: circleContainerHeight - fatinRingMeasure))
		fatRingLayer.startColor = fatColor
		fatRingLayer.endColor = #colorLiteral(red: 0.9607843137, green: 0.6862745098, blue: 0.09803921569, alpha: 1)
		fatRingLayer.ringWidth = ringWitdth
		fatRingLayer.progress = 0.0
		
		circularProgress.addSubview(proteinRingLayer)
		circularProgress.addSubview(carbsRingLayer)
		circularProgress.addSubview(fatRingLayer)
		
		perform(#selector(animateProgress), with: nil, afterDelay: 0.1)
	}

    @objc func animateProgress() {
		UIView.animate(withDuration: 1.0) {
			self.proteinRingLayer.progress = (self.userProgress.proteinProgress / self.userProgress.proteinTarget)
			self.carbsRingLayer.progress = (self.userProgress.carbsProgress / self.userProgress.carbsTarget)
			self.fatRingLayer.progress = (self.userProgress.fatProgress / self.userProgress.fatTarget)
		}
    }
	
	private func openChat() {
		let chatStoryboard = UIStoryboard(name: K.StoryboardName.chat, bundle: nil)
		let chatsVC = chatStoryboard.instantiateViewController(identifier: K.ViewControllerId.ChatsViewController)
			as ChatsViewController
		
		self.navigationController?.pushViewController(chatsVC, animated: true)
	}
	private func checkAddWeight() {
		WeightViewModel.checkAddWeight { showWeightAlert in
			if showWeightAlert {
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
	}
	private func checkDidFinishDailyMeals() {
		mealViewModel.checkDailyMealIsDoneBeforeHour { mealIsDone in
			if !mealIsDone {
				self.presentAlert(withTitle: "מעקב ארוחות", withMessage: "ראינו שלא השלמת את מעקב האורחות היומי שלך", options: "עבור למסך ארוחות", "ביטול") {
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
	}
}
