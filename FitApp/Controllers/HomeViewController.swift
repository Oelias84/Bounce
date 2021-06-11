//
//  HomeViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 28/11/2020.
//

import UIKit
import BLTNBoard
import FirebaseAuth

class HomeViewController: UIViewController {
    
    private var userProgress: UserProgress!
    private var mealViewModel: MealViewModel!
    
    private let carbsShapeLayer = CAShapeLayer()
    private let fatShapeLayer = CAShapeLayer()
    private let proteinShapeLayer = CAShapeLayer()
	
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
    
    private var carbsColor = #colorLiteral(red: 0.1863320172, green: 0.6013119817, blue: 0.9211298823, alpha: 1)
    private var fatColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
    private var proteinColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
    
    private var fatStartValue = 0.0
    private var carbsStartValue = 0.0
    private var proteinStartValue = 0.0
	
	private var proteinCP: CircularProgressView!
	private var fatCP: CircularProgressView!
	private var carbCP: CircularProgressView!
	
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
		Spinner.shared.stop()
        mealViewModel = MealViewModel.shared
        mealViewModel.bindMealViewModelToController = {
            self.setupProgress()
        }
		if let image = UserProfile.defaults.profileImageImageUrl?.showImage {
			profileButton.setImage( image.circleMasked, for: .normal)
		}
		setupView()
		setMotivationText()
		checkAddWeight()
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
        setupProgress()
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
    
    private func setUpProgressTextFields() {
		
		navigationItem.title = "היי \(UserProfile.defaults.name  ?? ""),"
        fatCountLabel.text = "\(fatStartValue)"
        carbsCountLabel.text = "\(carbsStartValue)"
        proteinCountLabel.text = "\(proteinStartValue)"
		fatTargateLabel.text = "מתוך \(userProgress.fatTarget)"
		carbsTargateLabel.text = "מתוך \(userProgress.carbsTarget)"
		proteinTargateLabel.text = "מתוך \(userProgress.proteinTarget)"
    }
    private func configureProgress() {
        circularProgress.subviews.forEach {
            $0.removeFromSuperview()
        }
		let circleContainerHeight = circularProgress.bounds.height
		let circleContainerWidth = circularProgress.bounds.width

        let viewCenter  = CGPoint(x: circleContainerHeight / 2, y: circleContainerWidth / 2)
		proteinCP = CircularProgressView(frame: CGRect(x: viewCenter.x, y: viewCenter.y,
													   width: circleContainerWidth - 50.0, height: circleContainerWidth - 50.0))
        fatCP = CircularProgressView(frame: CGRect(x: viewCenter.x, y: viewCenter.y,
												   width: circleContainerWidth - 100.0, height: circleContainerWidth - 100.0))
        carbCP = CircularProgressView(frame: CGRect(x: viewCenter.x, y: viewCenter.y,
													width: circleContainerWidth - 150.0, height: circleContainerWidth - 150.0))
		carbCP.tag = 100
        carbCP.trackColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.5189344393)
		carbCP.center = viewCenter
        carbCP.progressColor = carbsColor
        circularProgress.addSubview(carbCP)
        
		proteinCP.tag = 102
        proteinCP.trackColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.5189344393)
		proteinCP.center = viewCenter
        proteinCP.progressColor = proteinColor
        circularProgress.addSubview(proteinCP)
        
		fatCP.tag = 101
        fatCP.trackColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.5189344393)
		fatCP.center = viewCenter
        fatCP.progressColor = fatColor
        circularProgress.addSubview(fatCP)
        
        self.perform(#selector(animateProgress), with: nil, afterDelay: 0.1)
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
    private func setupProgress() {
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
	private func setupView() {
		tipContainerView.dropShadow()
		progressDataContainerView.dropShadow()
		progressWheelsContainerView.dropShadow()
	}
    
    @objc func animateProgress() {
		carbCP.setProgressWithAnimation(duration: 1.0, value: userProgress.carbsProgress / userProgress.carbsTarget)
        fatCP.setProgressWithAnimation(duration: 1.0, value: userProgress.fatProgress / userProgress.fatTarget)
        proteinCP.setProgressWithAnimation(duration: 1.0, value: userProgress.proteinProgress / userProgress.proteinTarget)
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
		mealViewModel.checkDailyMealIsDone { mealIsDone in
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
