//
//  ResetPasswordViewController.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/13/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import Domain
import RxSwift
import RxCocoa
import Material
import JGProgressHUD

class ResetPasswordViewController: AuthBackgroundViewController {
    
    private let disposeBag = DisposeBag()
    
    var viewModel: ResetPasswordViewModel!
    
    @IBOutlet weak var backButton: BackButton!
    @IBOutlet weak var passwordTextField: VocalVoterTextField!
    @IBOutlet weak var confirmPasswordTextField: VocalVoterTextField!
    @IBOutlet weak var resetPasswordButton: RaisedButton!
    
    let hud = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear
        
        hideKeyboardWhenTappedAround()
        bindViewModel()
        
        preparePassword()
        prepareConfirmPassword()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func bindViewModel() {
        assert(viewModel != nil)
        let resetPasswordTrigger = resetPasswordButton.rx.tap.flatMap { [unowned self] in
            return Driver.just(self.validResetPassword())
        }
        let input = ResetPasswordViewModel.Input(backTrigger: backButton.rx.tap.asDriver(),
                                                  resetPasswordTrigger: resetPasswordTrigger.asDriverOnErrorJustComplete(),
                                                  password: passwordTextField.rx.text.orEmpty.asDriver())
        
        let output = viewModel.transform(input: input)
        
        output.back.drive().disposed(by: disposeBag)
        output.next.drive().disposed(by: disposeBag)
        output.resetPassword.drive(onNext: { [unowned self] (result) in
            if result.result == FAIL {
                self.showErrorMsg(result.msg)
            }
            else {
                let hud = JGProgressHUD(style: .dark)
                hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                hud.textLabel.text = "Successfully reset password!"
                hud.show(in: self.view)
                hud.dismiss(afterDelay: 2.0, animated: true)
            }
        }).disposed(by: disposeBag)
        output.error.drive(onNext: { [unowned self] (error) in
            self.showErrorMsg(error.localizedDescription)
        }).disposed(by: disposeBag)
        output.activityIndicator.drive(onNext: { [unowned self] (loading) in
            if (loading) {
                self.hud.textLabel.text = "Sending email..."
                self.hud.show(in: self.view)
            }
            else {
                self.hud.dismiss()
            }
        }).disposed(by: disposeBag)
    }
    
}

extension ResetPasswordViewController {
    fileprivate func validResetPassword() -> Bool {
        var valid = true
        valid = passwordTextField.isValid && valid
        valid = validConfirmPassword() && valid
        return valid
    }
    
    fileprivate func preparePassword() {
        passwordTextField.placeholder = "Password"
        passwordTextField.type = .password
        passwordTextField.clearButtonMode = .always
        passwordTextField.isVisibilityIconButtonEnabled = false
        passwordTextField.delegate = self
        
        let leftView = UIImageView()
        leftView.image = IconImage.lock
        passwordTextField.leftView = leftView
    }
    
    fileprivate func prepareConfirmPassword() {
        confirmPasswordTextField.placeholder = "Confirm Password"
        confirmPasswordTextField.error = "Not matched password"
        confirmPasswordTextField.type = .none
        confirmPasswordTextField.clearButtonMode = .always
        confirmPasswordTextField.isVisibilityIconButtonEnabled = false
        confirmPasswordTextField.delegate = self
        
        let leftView = UIImageView()
        leftView.image = IconImage.lock
        confirmPasswordTextField.leftView = leftView
    }
    
    fileprivate func validConfirmPassword() -> Bool {
        if confirmPasswordTextField.text == passwordTextField.text {
            confirmPasswordTextField.isErrorRevealed = false
        }
        else {
            confirmPasswordTextField.isErrorRevealed = true
        }
        return !confirmPasswordTextField.isErrorRevealed
    }
}

extension ResetPasswordViewController: TextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == confirmPasswordTextField {
            _ = validConfirmPassword()
        }
        else {
            (textField as? VocalVoterTextField)?.checkValid()
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        (textField as? VocalVoterTextField)?.isErrorRevealed = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == passwordTextField) {
            _ = self.confirmPasswordTextField.becomeFirstResponder()
        }
        else if (textField == confirmPasswordTextField) {
            dismissKeyboard()
        }
        return true
    }
}
