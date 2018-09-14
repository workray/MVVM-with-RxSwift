//
//  LoginFormViewController.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/5/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import Material

class LoginFormViewController: UIViewController {

    @IBOutlet weak var emailTextField: VocalVoterTextField!
    @IBOutlet weak var passwordTextField: VocalVoterTextField!
    
    @IBOutlet weak var loginButton: RaisedButton!
    @IBOutlet weak var forgotPasswordButton: RaisedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.clear
        
        preparePasswordField()
        prepareEmailField()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LoginFormViewController {
    fileprivate func prepareEmailField() {
        emailTextField.placeholder = "Email"
        emailTextField.type = .email
        emailTextField.isClearIconButtonEnabled = true
        emailTextField.delegate = self
        
        let leftView = UIImageView()
        leftView.image = Icon.email
        emailTextField.leftView = leftView
    }
    
    fileprivate func preparePasswordField() {
        passwordTextField.placeholder = "Password"
        passwordTextField.type = .password
        passwordTextField.clearButtonMode = .always
        passwordTextField.isVisibilityIconButtonEnabled = true
        
        let leftView = UIImageView()
        leftView.image = IconImage.lock
        passwordTextField.leftView = leftView
    }
}


extension LoginFormViewController: TextFieldDelegate {
    public func textFieldDidEndEditing(_ textField: UITextField) {
        _ = (textField as? VocalVoterTextField)?.checkValid()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        (textField as? VocalVoterTextField)?.isErrorRevealed = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == emailTextField) {
            _ = self.passwordTextField.becomeFirstResponder()
        }
        else if (textField == passwordTextField) {
            dismissKeyboard()
        }
        return true
    }
}
