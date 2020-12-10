//
//  HomeViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 28/11/2020.
//

import UIKit

class HomeViewController: UIViewController {
    
    var userProgress: UserProgress!

    private let carbsShapeLayer = CAShapeLayer()
    private let fatShapeLayer = CAShapeLayer()
    private let proteinShapeLayer = CAShapeLayer()
    
    private var carbsColor = #colorLiteral(red: 0.1863320172, green: 0.6013119817, blue: 0.9211298823, alpha: 1)
    private var fatColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
    private var proteinColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
    
    @IBOutlet weak var fatCountLabel: UILabel!
    @IBOutlet weak var carbsCountLabel: UILabel!
    @IBOutlet weak var proteinCountLabel: UILabel!
    @IBOutlet weak var questionnaireStartButton: UIButton!
    @IBOutlet weak var circularProgress: UIView!

    
    @IBOutlet weak var fatTargateLabel: UILabel!
    @IBOutlet weak var carbsTargateLabel: UILabel!
    @IBOutlet weak var proteinTargateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userProgress = UserProgress(carbsTargate: 100.0, proteinTargate: 100.0, fatTargate: 100.0, carbsProgress: 75.0, proteinProgress: 50.0, fatProgress: 25.0)
        
        configureProgress()
        setUpProgressTextFields()
    }
    
    @IBAction func questionnaireStartButtonAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: K.StoryboardName.questionnaire, bundle: nil)
        let questionnaireVC = storyboard.instantiateViewController(identifier: K.StoryboardNameId.questionnaireNavigation)
        //Optional ???
        questionnaireVC.modalPresentationStyle = .fullScreen
        self.present(questionnaireVC, animated: true, completion: nil)
    }
}

extension HomeViewController {
    
    func setUpProgressTextFields() {
        fatCountLabel.text = "\(userProgress.fatProgress)"
        carbsCountLabel.text = "\(userProgress.carbsProgress)"
        proteinCountLabel.text = "\(userProgress.proteinProgress)"
        fatTargateLabel.text = "\(userProgress.fatTargate)"
        carbsTargateLabel.text = "\(userProgress.carbsTargate)"
        proteinTargateLabel.text = "\(userProgress.proteinTargate)"
    }
    
    func configureProgress(){
        let viewCenter = CGPoint(x: circularProgress.frame.height / 2, y: circularProgress.frame.width / 2)
        
        let carbCP = CircularProgressView(frame: CGRect(x: 10.0, y: 10.0, width: 100.0, height: 100.0))
        carbCP.trackColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.5189344393)
        carbCP.progressColor = carbsColor
        carbCP.tag = 100
        circularProgress.addSubview(carbCP)
        carbCP.center = viewCenter
        
        let proteinCP = CircularProgressView(frame: CGRect(x: 10.0, y: 10.0, width: 150.0, height: 150.0))
        proteinCP.trackColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.5189344393)
        proteinCP.progressColor = proteinColor
        proteinCP.tag = 102
        circularProgress.addSubview(proteinCP)
        proteinCP.center = viewCenter
        
        let fatCP = CircularProgressView(frame: CGRect(x: 10.0, y: 10.0, width: 200.0, height: 200.0))
        fatCP.trackColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.5189344393)
        fatCP.progressColor = fatColor
        fatCP.tag = 101
        circularProgress.addSubview(fatCP)
        fatCP.center = viewCenter
        
        self.perform(#selector(animateProgress), with: nil, afterDelay: 1.0)
    }

    @objc func animateProgress() {
        let carbP = self.view.viewWithTag(100) as! CircularProgressView
        carbP.setProgressWithAnimation(duration: 1.0, value: userProgress.carbsProgress / userProgress.carbsTargate)
        
        let fatP = self.view.viewWithTag(101) as! CircularProgressView
        fatP.setProgressWithAnimation(duration: 1.0, value: userProgress.fatProgress / userProgress.fatTargate)
        
        let proteinP = self.view.viewWithTag(102) as! CircularProgressView
        proteinP.setProgressWithAnimation(duration: 1.0, value: userProgress.proteinProgress / userProgress.proteinTargate)
    }
}
