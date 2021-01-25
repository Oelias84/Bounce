//
//  RegisterViewController.swift
//  FitApp
//
//  Created by Ofir Elias on 24/11/2020.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var confirmPasswordTextfield: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        raiseScreenWhenKeyboardAppears()
        addScreenTappGesture()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeKeyboardListener()
    }
    
    @IBAction func singUpButtonAction(_ sender: Any) {
        
        if passwordTextfield.text != confirmPasswordTextfield.text {
            presentOkAlert(withTitle: "סיסמה שגויה", withMessage: "אנא נסי שוב") {}
        } else {
            Auth.auth().createUser(withEmail: emailTextfield.text!, password: passwordTextfield.text!){ (user, error) in
                if error == nil {
                    let storyboard = UIStoryboard(name: K.StoryboardName.home, bundle: nil)
                    let homeVC = storyboard.instantiateViewController(identifier: K.ViewControllerId.HomeTabBar)
                    
                    homeVC.modalPresentationStyle = .fullScreen
                    self.present(homeVC, animated: true)
                } else {
                    self.presentOkAlert(withTitle: "שגיאה", withMessage: error!.localizedDescription) {}
                }
            }
        }
    }
}
