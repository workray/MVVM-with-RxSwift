//
//  MainViewController.swift
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

class LoginViewController: UIViewController {

    private let disposeBag = DisposeBag()
    
    var viewModel: LoginViewModel!
    private var initialTrigger: Disposable!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var backgroundOverlayView: UIView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    @IBOutlet weak var appTitleLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var signUpButton: RaisedButton!
    
    var loginFormVc: LoginFormViewController!
    
    let hud = UIViewController.getHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.clear
        
        visualEffectView.alpha = 0
        hideKeyboardWhenTappedAround()
        bindViewModel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "segueLoginForm" {
            loginFormVc = segue.destination as? LoginFormViewController
        }
    }
    private func bindViewModel() {
        assert(viewModel != nil)
        let viewDidAppear = rx.sentMessage(#selector(UIViewController.viewDidAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        let loginTrigger = loginFormVc.loginButton.rx.tap.flatMap { [unowned self] in
            return Driver.just(self.validContinue())
        }
        let input = LoginViewModel.Input(initialTrigger: viewDidAppear,
                                         loginTrigger: loginTrigger.asDriverOnErrorJustComplete(),
                                         forgotPasswordTrigger: loginFormVc.forgotPasswordButton.rx.tap.asDriver(),
                                         signupTrigger: signUpButton.rx.tap.asDriver(),
                                         email: loginFormVc.emailTextField.rx.text.orEmpty.asDriver(),
                                         password: loginFormVc.passwordTextField.rx.text.orEmpty.asDriver())
        let output = viewModel.transform(input: input)
        
        initialTrigger = output.initial.drive(initialBinding)
        initialTrigger.disposed(by: disposeBag)
        output.signup.drive().disposed(by: disposeBag)
        output.login.drive(onNext: { [unowned self] (users) in
            if users.count == 0 {
                self.showErrorMsg("Email and password are wrong!")
            }
            else if users.count == 2 {
                self.showErrorMsg("Unknown Error!!!")
            }
        }).disposed(by: disposeBag)
        output.success.drive(onNext: { [unowned self] () in
            self.loginFormVc.emailTextField.text = ""
            self.loginFormVc.passwordTextField.text = ""
            self.loginFormVc.emailTextField.isErrorRevealed = false
            self.loginFormVc.passwordTextField.isErrorRevealed = false
        }).disposed(by: disposeBag)
        output.forgotPassword.drive().disposed(by: disposeBag)
        output.error.drive(onNext: { [unowned self] (error) in
            self.showErrorMsg(error.localizedDescription)
        }).disposed(by: disposeBag)
        output.activityIndicator.drive(onNext: { [unowned self] (loading) in
            if loading {
                self.hud.textLabel.text = "Logging in..."
                self.hud.show(in: self.view)
            }
            else {
                self.hud.dismiss()
            }
        }).disposed(by: disposeBag)
    }

    var initialBinding: Binder<Void> {
        return Binder(self, binding: { (vc, _) in
            vc.initialAnimations()
        })
    }
    // MARK: - Initial Animations
    func initialAnimations() {
        if (self.initialTrigger != nil) {
            self.initialTrigger.dispose()
        }
        UIView.animate(withDuration: 0.25, animations: {
            self.visualEffectView.alpha = 1.0
            self.contentView.alpha = 1.0
            self.backgroundOverlayView.alpha = 0.0
            self.contentView.bottomAnchor.constraint(equalTo: (self.contentView.superview?.bottomAnchor)!).isActive = true
            self.appTitleLabel.alpha = 1.0
            self.view.layoutIfNeeded()
        }, completion: { (finished) in
            UIView.animate(withDuration: 0.25, animations: {
                self.contentView.alpha = 1.0
                self.signUpButton.alpha = 1.0
            }, completion: { (finished) in
                
            })
        })
    }
    
    fileprivate func validContinue() -> Bool {
        var valid = true
        valid = loginFormVc.emailTextField.isValid && valid
        valid = loginFormVc.passwordTextField.isValid && valid
        if !valid {
            showErrorMsg("Email and password should be inputed")
        }
        return valid
    }

}
