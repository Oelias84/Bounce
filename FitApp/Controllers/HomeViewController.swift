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
        item.descriptionText = "לחצי על כאן כדי שנוכל להכיר אותך ולהתאים לך את המסלול הטוב ביותר"
        item.actionButtonTitle = "בואי נתחיל"
        item.actionHandler = { _ in
            self.startQuestionnaire()
        }
        return BLTNItemManager(rootItem: item)
    }()
    
    private var carbsColor = #colorLiteral(red: 0.1863320172, green: 0.6013119817, blue: 0.9211298823, alpha: 1)
    private var fatColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
    private var proteinColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
    
    private var fatStartValue = 0.0
    private var carbsStartValue = 0.0
    private var proteinStartValue = 0.0
    
    @IBOutlet weak var helloUserTextLabel: UILabel!
    @IBOutlet weak var userMotivationTextLabel: UILabel!
    
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
        
        mealViewModel = MealViewModel.shared
        mealViewModel.bindMealViewModelToController = {
            self.setupProgress()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(true, animated: animated)

        if !(UserProfile.defaults.finishOnboarding ?? false) {
            boardManager.showBulletin(above: self)
            boardManager.allowsSwipeInteraction = false
        } else {
            mealViewModel.fetchData()
        }
        setupProgress()
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.setNavigationBarHidden(false, animated: animated)
	}
    
    @IBAction func profileButtonAction(_ sender: Any) {
		let storyboard = UIStoryboard(name: K.StoryboardName.settings, bundle: nil)
		let settingsVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.SettingsViewController)
		
		self.navigationController!.pushViewController(settingsVC, animated: true)
	}
}

extension HomeViewController {
    
    private func setUpProgressTextFields() {
        helloUserTextLabel.text = "היי \(UserProfile.defaults.name  ?? ""),"
        // change progress sentence
        //        userMotivationTextLabel.text = "\()"
        fatCountLabel.text = "\(fatStartValue)"
        carbsCountLabel.text = "\(carbsStartValue)"
        proteinCountLabel.text = "\(proteinStartValue)"
		fatTargateLabel.text = "\(userProgress.fatTarget.roundHalfDown)"
		carbsTargateLabel.text = "\(userProgress.carbsTarget.roundHalfDown)"
		proteinTargateLabel.text = "\(userProgress.proteinTarget.roundHalfDown)"
    }
    private func configureProgress(){
        circularProgress.subviews.forEach {
            $0.removeFromSuperview()
        }
        let viewCenter  = CGPoint(x: circularProgress.frame.height / 2, y: circularProgress.frame.width / 2)
        let proteinCP   = CircularProgressView(frame: CGRect(x: 10.0, y: 10.0, width: 150.0, height: 150.0))
        let fatCP       = CircularProgressView(frame: CGRect(x: 10.0, y: 10.0, width: 200.0, height: 200.0))
        let carbCP      = CircularProgressView(frame: CGRect(x: 10.0, y: 10.0, width: 100.0, height: 100.0))
        
        carbCP.trackColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.5189344393)
        carbCP.progressColor = carbsColor
        carbCP.tag = 100
        circularProgress.addSubview(carbCP)
        carbCP.center = viewCenter
        
        proteinCP.trackColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.5189344393)
        proteinCP.progressColor = proteinColor
        proteinCP.tag = 102
        circularProgress.addSubview(proteinCP)
        proteinCP.center = viewCenter
        
        fatCP.trackColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.5189344393)
        fatCP.progressColor = fatColor
        fatCP.tag = 101
        circularProgress.addSubview(fatCP)
        fatCP.center = viewCenter
        
        self.perform(#selector(animateProgress), with: nil, afterDelay: 0.1)
    }
    private func startQuestionnaire(){
        let storyboard = UIStoryboard(name: K.StoryboardName.questionnaire, bundle: nil)
        let questionnaireVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.questionnaireNavigation)
        
        questionnaireVC.modalPresentationStyle = .fullScreen
        boardManager.dismissBulletin()
        self.present(questionnaireVC, animated: true, completion: nil)
    }
    private func setupProgress() {
        let manager = ConsumptionManager()
        let progress = mealViewModel.getProgress()
        userProgress = UserProgress(carbsTarget: manager.getDayCarbs, proteinTarget: manager.getDayProtein, fatTarget: manager.getDayFat, carbsProgress: progress.carbs, proteinProgress: progress.protein, fatProgress: progress.fats)
        configureProgress()
        setUpProgressTextFields()
        fatCountLabel.text = String(format: "%.1f", progress.fats)
        carbsCountLabel.text = String(format: "%.1f", progress.carbs)
        proteinCountLabel.text = String(format: "%.1f", progress.protein)
    }
    
    @objc func animateProgress() {
        let carbP = self.view.viewWithTag(100) as! CircularProgressView
        let fatP = self.view.viewWithTag(101) as! CircularProgressView
        let proteinP = self.view.viewWithTag(102) as! CircularProgressView
        
		carbP.setProgressWithAnimation(duration: 1.0, value: userProgress.carbsProgress / userProgress.carbsTarget.roundHalfDown)
        fatP.setProgressWithAnimation(duration: 1.0, value: userProgress.fatProgress / userProgress.fatTarget.roundHalfDown)
        proteinP.setProgressWithAnimation(duration: 1.0, value: userProgress.proteinProgress / userProgress.proteinTarget.roundHalfDown)
    }
}
