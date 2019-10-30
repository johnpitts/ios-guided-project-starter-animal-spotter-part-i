//
//  LoginViewController.swift
//  AnimalSpotter
//
//  Created by Ben Gohlke on 4/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

enum LoginType {
    case signUp
    case signIn
}

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var loginTypeSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var signInButton: UIButton!
    
    var apiController: APIController?
    var loginType = LoginType.signUp

    override func viewDidLoad() {
        super.viewDidLoad()

        signInButton.backgroundColor = UIColor(hue: 190/360, saturation: 70/100, brightness: 80/100, alpha: 1.0)
            signInButton.tintColor = .white
            signInButton.layer.cornerRadius = 8.0
    }
    
    // MARK: - Action Handlers
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        // perform login or sign up operation based on loginType
        guard let apiController = apiController else { return }
        guard let username = usernameTextField.text,
              !username.isEmpty,
              let password = passwordTextField.text,
            !password.isEmpty else { return }
        
        let user = User(username: username, password: password)
        
        if loginType == .signUp {
            apiController.signUp(with: user) { (error) in
                if let error = error {
                    NSLog("Error occured during signup: \(error)")
                } else {
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Your signup was successful!", message: "Now please log in", preferredStyle: .alert)
                        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(alertAction)
                        self.present(alertController, animated: true) {
                            self.loginType = .signIn
                            self.loginTypeSegmentedControl.selectedSegmentIndex = 1
                            self.signInButton.setTitle("Sign In", for: .normal)
                            
                        }
                    }
                }
            }
        } else {
            apiController.signIn(with: user) { (error) in
                if let error = error {                               // Here you'd warn the user using alertController or change wording to red or some other signal that something went wrong
                    print("Error occured during signin: \(error)")
                    
                } else {
                    DispatchQueue.main.sync {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func signInTypeChanged(_ sender: UISegmentedControl) {
        // switch UI between login types
        if sender.selectedSegmentIndex == 0 {
            signInButton.setTitle("Sign Up", for: .normal)
        } else {
            loginType = .signIn
            signInButton.setTitle("Sign In", for: .normal)
        }
    }
}
