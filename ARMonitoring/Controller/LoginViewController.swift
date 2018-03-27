//
//  LoginViewController.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 16/03/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var errorMessageLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.emailTxt.layer.borderColor = UIColor.red.cgColor
        self.emailTxt.layer.cornerRadius = 6.0
        self.passwordTxt.layer.borderColor = UIColor.red.cgColor
        self.passwordTxt.layer.cornerRadius = 6.0

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func LoginButtonPressed(_ sender: Any) {
        
        if let email = self.emailTxt.text?.getNonEmpty(),
            let password = self.passwordTxt.text?.getNonEmpty() {
            
            let login = LoginDto(email: email, password: password)
            self.login(loginDto: login)
            
            self.emailTxt.layer.borderWidth = 0.0
            self.passwordTxt.layer.borderWidth = 0.0
        }
        else {
            // Highlight textfields
            self.emailTxt.layer.borderWidth = 0.25
            self.passwordTxt.layer.borderWidth = 0.25
        }
        
    }
    
    private func login(loginDto: LoginDto) {
        let authService: AuthenticationRestService = AuthenticationRestService()
        
        authService.authenticate(loginDto: loginDto, success: { user in
            // Authentication Succeeded
            SessionService.sharedInstance.setUserAccount(user: user)
            print("sucess")
            // Call segue?
            self.performSegue(withIdentifier: "arViewSegue", sender: self)
            
        }, failed: { error in
            var errorMessage: String = ""
            switch (error.code) {
            case -10:
                // Wrong credentials
                errorMessage = "Wrong email and/or password"
                print(error.userInfo)
                break;
            case -15:
                // Mapping error
                errorMessage = "Server error, unexpected response"
                print(error.userInfo)
                break;
            case -20:
                // Connection error
                print(error.userInfo)
                errorMessage = "Connection error, please check your connection"
                break;
            default:
                print("unexpected error..")
                errorMessage = "An unexpected error has occurred.."
                break;
            }
            
            self.errorMessageLbl.text = errorMessage
        })
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "arViewSegue" {
            // let destinationVC = segue.destination as! ARViewController
            let _ = DBInitializer()
        }
    }

}
