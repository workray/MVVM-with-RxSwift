//
//  VerificationCodeViewController.swift
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
import IQKeyboardManagerSwift

class VerificationCodeViewController: AuthBackgroundViewController {

    private let disposeBag = DisposeBag()
    
    var viewModel: VerificationCodeViewModel!
    
    @IBOutlet weak var backButton: BackButton!
    @IBOutlet weak var verificationCodeTextField1: VerificationCodeTextField!
    @IBOutlet weak var verificationCodeTextField2: VerificationCodeTextField!
    @IBOutlet weak var verificationCodeTextField3: VerificationCodeTextField!
    @IBOutlet weak var verificationCodeTextField4: VerificationCodeTextField!
    @IBOutlet weak var verificationCodeTextField5: VerificationCodeTextField!
    @IBOutlet weak var verificationCodeTextField6: VerificationCodeTextField!
    @IBOutlet weak var submitButton: RaisedButton!
    @IBOutlet weak var resendButton: RaisedButton!
    
    let hud = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hideKeyboardWhenTappedAround()
        bindViewModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    private func bindViewModel() {
        assert(viewModel != nil)
        let submitTrigger = submitButton.rx.tap.do(onNext: { [unowned self] () in
            self.hud.textLabel.text = "Submitting..."
        })
        let resendTrigger = resendButton.rx.tap.do(onNext: { [unowned self] in
            self.hud.textLabel.text = "Resending..."
        })
        
        let input = VerificationCodeViewModel.Input(backTrigger: backButton.rx.tap.asDriver(),
                                                  submitTrigger: submitTrigger.asDriverOnErrorJustComplete(),
                                                  resendTrigger: resendTrigger.asDriverOnErrorJustComplete(),
                                                  verificationCode1: verificationCodeTextField1.rx.text.orEmpty.asDriver(),
                                                  verificationCode2: verificationCodeTextField2.rx.text.orEmpty.asDriver(),
                                                  verificationCode3: verificationCodeTextField3.rx.text.orEmpty.asDriver(),
                                                  verificationCode4: verificationCodeTextField4.rx.text.orEmpty.asDriver(),
                                                  verificationCode5: verificationCodeTextField5.rx.text.orEmpty.asDriver(),
                                                  verificationCode6: verificationCodeTextField6.rx.text.orEmpty.asDriver())
        
        let output = viewModel.transform(input: input)
        
        output.back.drive().disposed(by: disposeBag)
        output.canSubmit.drive(submitButton.rx.isEnabled).disposed(by: disposeBag)
        output.next.drive().disposed(by: disposeBag)
        output.submit.drive(onNext: { [unowned self] (result) in
            if result.result == FAIL {
                self.showErrorMsg(result.msg)
            }
        }).disposed(by: disposeBag)
        output.resend.drive(onNext: { (result) in
            if result.result == FAIL {
                self.showErrorMsg(result.msg)
            }
            else {
                let hud = JGProgressHUD(style: .dark)
                hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                hud.textLabel.text = "Successfully resent verification code!\nPlease check your email!"
                hud.show(in: self.view)
                hud.dismiss(afterDelay: 2.0, animated: true)
            }
        }).disposed(by: disposeBag)
        output.error.drive(onNext: { [unowned self] (error) in
            self.showErrorMsg(error.localizedDescription)
        }).disposed(by: disposeBag)
        output.activityIndicator.drive(onNext: { [unowned self] (loading) in
            if (loading) {
                self.hud.show(in: self.view)
            }
            else {
                self.hud.dismiss()
            }
        }).disposed(by: disposeBag)
    }
    
    
}

extension VerificationCodeViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.backgroundColor = UIColor.init(white: 1.0, alpha: 0.8)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectAll(nil)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.backgroundColor = UIColor.init(white: 1.0, alpha: 0.3)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let char = string.cString(using: .utf8)
        let isBackSpace = strcmp(char, "\\b")
        
        if isBackSpace == -92 {
            textField.text = ""
            if IQKeyboardManager.shared.canGoPrevious {
                IQKeyboardManager.shared.goPrevious()
            }
        }
        else {
            textField.text = string
            if IQKeyboardManager.shared.canGoNext {
                IQKeyboardManager.shared.goNext()
            }
        }
        return false
    }
}
