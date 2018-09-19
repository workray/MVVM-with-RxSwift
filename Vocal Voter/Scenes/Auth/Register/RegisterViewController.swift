//
//  RegisterViewController.swift
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
import Kingfisher

class RegisterViewController: AuthBackgroundViewController {

    private let disposeBag = DisposeBag()
    
    var viewModel: RegisterViewModel!
    
    @IBOutlet weak var backButton: BackButton!
    @IBOutlet weak var cameraImageView: UIImageView!
    @IBOutlet weak var imageButton: RaisedButton!
    @IBOutlet weak var imageView: CircleImageView!
    
    @IBOutlet weak var firstnameTextField: VocalVoterTextField!
    @IBOutlet weak var lastnameTextField: VocalVoterTextField!
    @IBOutlet weak var emailTextField: VocalVoterTextField!
    @IBOutlet weak var passwordTextField: VocalVoterTextField!
    @IBOutlet weak var confirmPasswordTextField: VocalVoterTextField!
    @IBOutlet weak var phoneTextField: VocalVoterTextField!
    @IBOutlet weak var zipcodeTextField: VocalVoterTextField!
    
    @IBOutlet weak var continueButton: RaisedButton!
    
    let hud = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.clear
        
        cameraImageView.image = Icon.photoCamera?.tint(with: UIColor.white)

        hideKeyboardWhenTappedAround()
        prepareFirstName()
        prepareLastName()
        prepareEmail()
        preparePassword()
        prepareConfirmPassword()
        preparePhone()
        prepareZipcode()
        
        bindViewModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    private func bindViewModel() {
        assert(viewModel != nil)
        let continueTrigger = continueButton.rx.tap.flatMap { [unowned self] in
            return Driver.just(self.validContinue())
        }
        let input = RegisterViewModel.Input(backTrigger: backButton.rx.tap.asDriver(),
                                            photoTrigger: imageButton.rx.tap.asDriver(),
                                            continueTrigger: continueTrigger.asDriverOnErrorJustComplete(),
                                            firstName: firstnameTextField.rx.text.orEmpty.asDriver(),
                                            lastName: lastnameTextField.rx.text.orEmpty.asDriver(),
                                            email: emailTextField.rx.text.orEmpty.asDriver(),
                                            password: passwordTextField.rx.text.orEmpty.asDriver(),
                                            phoneNumber: phoneTextField.rx.text.orEmpty.asDriver(),
                                            zipcode: zipcodeTextField.rx.text.orEmpty.asDriver())
        let output = viewModel.transform(input: input)
        
        output.back.drive().disposed(by: disposeBag)
        output.photo.drive().disposed(by: disposeBag)
        output.next.drive().disposed(by: disposeBag)
        output.profile.drive(profileBinding).disposed(by: disposeBag)
        output.checkUser.drive(onNext: { (users) in
            if users.count > 0 {
                self.showErrorMsg("This email or phone number are already exist!")
            }
        }).disposed(by: disposeBag)
        output.error.drive(onNext: { [unowned self] (error) in
            self.showErrorMsg(error.localizedDescription)
        }).disposed(by: disposeBag)
        output.activityIndicator.drive(onNext: { [unowned self] (loading) in
            if (loading) {
                self.hud.textLabel.text = "Checking user..."
                self.hud.show(in: self.view)
            }
            else {
                self.hud.dismiss()
            }
        }).disposed(by: disposeBag)
    }

    var profileBinding: Binder<Profile> {
        return Binder(self, binding: { (vc, profile) in
            vc.bindProfile(profile)
        })
    }
    
}

extension RegisterViewController {
    fileprivate func bindProfile(_ profile: Profile) {
        let user = profile.user
        firstnameTextField.text = user.firstName
        lastnameTextField.text = user.lastName
        emailTextField.text = user.email
        phoneTextField.text = user.phone
        zipcodeTextField.text = user.zipcode
        
        if let image = profile.userPhoto {
            self.imageView.image = image
            self.imageView.isHidden = false
        }
        else if !profile.user.photoUrl.isEmpty {
            self.imageView.kf.setImage(with: URL(string: profile.user.photoUrl))
            self.imageView.isHidden = false
        }
    }
    fileprivate func validContinue() -> Bool {
        var valid = true
        valid = firstnameTextField.isValid && valid
        valid = lastnameTextField.isValid && valid
        valid = emailTextField.isValid && valid
        valid = passwordTextField.isValid && valid
        valid = validConfirmPassword() && valid
        valid = phoneTextField.isValid && valid
        valid = zipcodeTextField.isValid && valid
        valid = !self.imageView.isHidden && valid
        if self.imageView.isHidden {
            showErrorMsg("A photo is empty!")
        }
        else if !valid {
            showErrorMsg("All required fields must be completed!")
        }
        return valid
    }
    fileprivate func prepareFirstName() {
        firstnameTextField.placeholder = "First Name"
        firstnameTextField.type = .name
        firstnameTextField.isClearIconButtonEnabled = true
        firstnameTextField.delegate = self
        
        let leftView = UIImageView()
        leftView.image = IconImage.username
        firstnameTextField.leftView = leftView
    }
    
    fileprivate func prepareLastName() {
        lastnameTextField.placeholder = "Last Name"
        lastnameTextField.type = .name
        lastnameTextField.isClearIconButtonEnabled = true
        lastnameTextField.delegate = self
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
    
    fileprivate func preparePhone() {
        phoneTextField.placeholder = "Phone Number"
        phoneTextField.type = .phone
        phoneTextField.isClearIconButtonEnabled = true
        phoneTextField.delegate = self
        
        let leftView = UIImageView()
        leftView.image = Icon.phone
        phoneTextField.leftView = leftView
    }
    
    fileprivate func prepareZipcode() {
        zipcodeTextField.placeholder = "Zipcode"
        zipcodeTextField.type = .zipcode
        zipcodeTextField.isClearIconButtonEnabled = true
        zipcodeTextField.delegate = self
        
        let leftView = UIImageView()
        leftView.image = IconImage.zipcode
        zipcodeTextField.leftView = leftView
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

extension RegisterViewController: TextFieldDelegate {
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
        if (textField == firstnameTextField) {
            _ = self.lastnameTextField.becomeFirstResponder()
        }
        else if (textField == lastnameTextField) {
            _ = self.emailTextField.becomeFirstResponder()
        }
        else if (textField == emailTextField) {
            _ = self.passwordTextField.becomeFirstResponder()
        }
        else if (textField == passwordTextField) {
            _ = self.confirmPasswordTextField.becomeFirstResponder()
        }
        else if (textField == confirmPasswordTextField) {
            _ = self.phoneTextField.becomeFirstResponder()
        }
        else if (textField == phoneTextField) {
            _ = self.zipcodeTextField.becomeFirstResponder()
        }
        else if (textField == zipcodeTextField) {
            dismissKeyboard()
        }
        return true
    }
}
