//
//  ForgotPasswordViewController.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/5/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import Domain
import RxSwift
import RxCocoa
import Material
import JGProgressHUD

class ForgotPasswordViewController: AuthBackgroundViewController {

    private let disposeBag = DisposeBag()
    
    var viewModel: ForgotPasswordViewModel!
    
    @IBOutlet weak var backButton: BackButton!
    @IBOutlet weak var emailTextField: VocalVoterTextField!
    @IBOutlet weak var sendEmailButton: RaisedButton!
    @IBOutlet weak var registerButton: RaisedButton!
    @IBOutlet weak var haveAlreadyVerificationCodeButton: RaisedButton!
    
    let hud = UIViewController.getHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.clear
        
        hideKeyboardWhenTappedAround()
        bindViewModel()
        
        prepareEmail()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    private func bindViewModel() {
        assert(viewModel != nil)
        let sendEmailTrigger = sendEmailButton.rx.tap.flatMap { [unowned self] in
            return Driver.just(self.isValidEmail())
        }
        let haveAlreadyVerificationCodeTrigger = haveAlreadyVerificationCodeButton.rx.tap.flatMap { [unowned self] in
            return Driver.just(self.isValidEmail())
        }
            
        let input = ForgotPasswordViewModel.Input(backTrigger: backButton.rx.tap.asDriver(),
                                                  sendEmailTrigger: sendEmailTrigger.asDriverOnErrorJustComplete(),
                                                  registerTrigger: registerButton.rx.tap.asDriver(),
                                                  haveAlreadyVerificationCodeTrigger: haveAlreadyVerificationCodeTrigger.asDriverOnErrorJustComplete(),
                                                  email: emailTextField.rx.text.orEmpty.asDriver())
        
        let output = viewModel.transform(input: input)
        
        output.back.drive().disposed(by: disposeBag)
        output.register.drive().disposed(by: disposeBag)
        output.next.drive().disposed(by: disposeBag)
        output.haveAlreadyVerificationCode.drive().disposed(by: disposeBag)
        output.sendEmail.drive(onNext: { (result) in
            if result.result == FAIL {
                self.showErrorMsg(result.msg)
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

extension ForgotPasswordViewController {
    fileprivate func isValidEmail() -> Bool {
        if !self.emailTextField.isValid {
            self.showErrorMsg("You should input the your registered email address.")
            return false
        }
        return true
    }
    fileprivate func prepareEmail() {
        emailTextField.placeholder = "Email"
        emailTextField.type = .email
        emailTextField.isClearIconButtonEnabled = true
        emailTextField.delegate = self
        
        let leftView = UIImageView()
        leftView.image = Icon.email
        emailTextField.leftView = leftView
    }
}

extension ForgotPasswordViewController: TextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        (textField as? VocalVoterTextField)?.checkValid()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        (textField as? VocalVoterTextField)?.isErrorRevealed = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
}

