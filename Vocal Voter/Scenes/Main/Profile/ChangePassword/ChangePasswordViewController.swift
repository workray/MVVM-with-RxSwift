//
//  ChangePasswordViewController.swift
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

class ChangePasswordViewController: UITableViewController {

    private let disposeBag = DisposeBag()
    
    var viewModel: ChangePasswordViewModel!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var changeButton: UIBarButtonItem!
    
    let passwordCellIdentifier = "passwordCell"
    
    let oldPasswordSubject = PublishSubject<String>.init()
    let newPasswordSubject = PublishSubject<String>.init()
    
    let hud = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backButton.image = Icon.cm.arrowBack
        bindViewModel()
    }
    
    private func bindViewModel() {
        assert(viewModel != nil)
        let input = ChangePasswordViewModel.Input(
            backTrigger: backButton.rx.tap.asDriver(),
            changeTrigger: changeButton.rx.tap.asDriver(),
            oldPassword: oldPasswordSubject.asDriverOnErrorJustComplete(),
            newPassword: newPasswordSubject.asDriverOnErrorJustComplete())
        let output = viewModel.transform(input: input)
        
        output.back.drive().disposed(by: disposeBag)
        output.change.drive(completedBinding).disposed(by: disposeBag)
        output.next.drive().disposed(by: disposeBag)
        output.valid.drive(changeButton.rx.isEnabled).disposed(by: disposeBag)
        output.error.drive(errorBinding).disposed(by: disposeBag)
        output.activityIndicator.drive(changeBinding).disposed(by: disposeBag)
    }
    
    var changeBinding: Binder<Bool> {
        return Binder(self, binding: { (vc, loading) in
            if loading {
                vc.hud.textLabel.text = "Changing password..."
                vc.hud.show(in: self.view)
            }
            else {
                vc.hud.dismiss()
            }
        })
    }
    
    var completedBinding: Binder<Void> {
        return Binder(self, binding: { (vc, _) in
            let hud = JGProgressHUD(style: .dark)
            hud.indicatorView = JGProgressHUDSuccessIndicatorView()
            hud.textLabel.text = "Password changed successfully!"
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

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: passwordCellIdentifier, for: indexPath) as! PasswordTableViewCell

        if indexPath.row == 0 {
            cell.passwordLabel.text = "Old Password"
            cell.passwordTextField.placeholder = "enter old password"
            cell.passwordTextField.rx.text.orEmpty.asDriver().drive(oldPasswordSubject).disposed(by: disposeBag)
        }
        else {
            cell.passwordLabel.text = "New Password"
            cell.passwordTextField.placeholder = "enter new password"
            cell.passwordTextField.rx.text.orEmpty.asDriver().drive(newPasswordSubject).disposed(by: disposeBag)
        }

        return cell
    }

}
