//
//  EditProfileViewController.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/19/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import Domain
import RxSwift
import RxCocoa
import Material
import JGProgressHUD

class EditProfileViewController: UIViewController {

    private let disposeBag = DisposeBag()
    
    var viewModel: EditProfileViewModel!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var firstnameTextField: VocalVoterTextField!
    @IBOutlet weak var lastnameTextField: VocalVoterTextField!
    @IBOutlet weak var emailTextField: VocalVoterTextField!
    @IBOutlet weak var phoneTextField: VocalVoterTextField!
    @IBOutlet weak var zipcodeTextField: VocalVoterTextField!
    
    let hud = UIViewController.getHUD()
    var profile: UserProfile!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        backButton.image = Icon.cm.arrowBack
        hideKeyboardWhenTappedAround()
        
        prepareFirstName()
        prepareLastName()
        prepareEmail()
        preparePhone()
        prepareZipcode()
        
        bindProfile(profile)
        
        bindViewModel()
    }

    private func bindViewModel() {
        assert(viewModel != nil)
        let doneTrigger = doneButton.rx.tap.flatMap { [unowned self] in
            return Driver.just(self.validContinue())
        }
        let input = EditProfileViewModel.Input(
                                            backTrigger: backButton.rx.tap.asDriver(),
                                            doneTrigger: doneTrigger.asDriverOnErrorJustComplete(),
                                            firstName: firstnameTextField.rx.text.orEmpty.asDriver(),
                                            lastName: lastnameTextField.rx.text.orEmpty.asDriver(),
                                            email: emailTextField.rx.text.orEmpty.asDriver(),
                                            phoneNumber: phoneTextField.rx.text.orEmpty.asDriver(),
                                            zipcode: zipcodeTextField.rx.text.orEmpty.asDriver())
        let output = viewModel.transform(input: input)
        
        output.back.drive().disposed(by: disposeBag)
        output.profile.drive(profileBinding).disposed(by: disposeBag)
        output.updateProfile.drive().disposed(by: disposeBag)
        output.done.drive(checkingBinding).disposed(by: disposeBag)
        output.checkUser.drive(updateBinding).disposed(by: disposeBag)
        output.update.drive(completedBinding).disposed(by: disposeBag)
        output.valid.drive(doneButton.rx.isEnabled).disposed(by: disposeBag)
        output.error.drive(errorBinding).disposed(by: disposeBag)
        output.activityIndicator.drive().disposed(by: disposeBag)
    }
    
    var profileBinding: Binder<UserProfile> {
        return Binder(self, binding: { (vc, profile) in
            vc.bindProfile(profile)
        })
    }
    
    var checkingBinding: Binder<Void> {
        return Binder(self, binding: { (vc, _) in
            vc.hud.textLabel.text = "Checking user..."
            vc.hud.show(in: self.view)
        })
    }
    
    var updateBinding: Binder<Bool> {
        return Binder(self, binding: { (vc, valid) in
            if !valid {
                vc.hud.dismiss()
                vc.showErrorMsg("This email or phone number are already exist!")
            }
            else {
                vc.hud.textLabel.text = "Updating..."
            }
        })
    }
    
    var completedBinding: Binder<Void> {
        return Binder(self, binding: { (vc, _) in
            vc.hud.dismiss()
            let hud = JGProgressHUD(style: .dark)
            hud.indicatorView = JGProgressHUDSuccessIndicatorView()
            hud.textLabel.text = "User profile updated successfully!"
            hud.show(in: vc.view)
            hud.dismiss(afterDelay: 2.0, animated: true)
        })
    }

    var errorBinding: Binder<Error> {
        return Binder(self, binding: { (vc, error) in
            vc.hud.dismiss()
            vc.showErrorMsg(error.localizedDescription)
        })
    }
}

extension EditProfileViewController {

    fileprivate func bindProfile(_ profile: UserProfile) {
        self.firstnameTextField.text = profile.firstName
        self.lastnameTextField.text = profile.lastName
        self.emailTextField.text = profile.email
        self.phoneTextField.text = profile.phone
        self.zipcodeTextField.text = profile.zipcode
    }
    fileprivate func validContinue() -> Bool {
        var valid = true
        valid = firstnameTextField.isValid && valid
        valid = lastnameTextField.isValid && valid
        valid = emailTextField.isValid && valid
        valid = phoneTextField.isValid && valid
        valid = zipcodeTextField.isValid && valid
        if !valid {
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
}

extension EditProfileViewController: TextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        (textField as? VocalVoterTextField)?.checkValid()
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
