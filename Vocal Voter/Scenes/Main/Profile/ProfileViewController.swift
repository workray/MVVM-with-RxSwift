//
//  ProfileViewController.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/18/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import Domain
import RxSwift
import RxCocoa
import Material
import Kingfisher
import JGProgressHUD

class ProfileViewController: UITableViewController {

    let profileCellIdenitifer = "profileCellIdenitifer"
    @IBOutlet weak var profileImageView: ImageView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var profileImageButton: RaisedButton!
    @IBOutlet weak var cameraImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var indicatorView: UIView!
    
    private let disposeBag = DisposeBag()
    
    var viewModel: ProfileViewModel!
    
    let editProfileSubject = PublishSubject<Bool>.init()
    let changePasswordSubject = PublishSubject<Bool>.init()
    let changeVerificationPhotoSubject = PublishSubject<Bool>.init()
    let logoutSubject = PublishSubject<Bool>.init()
    
    let hud = UIViewController.getHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: profileCellIdenitifer)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        cameraImageView.image = Icon.cm.photoCamera?.tint(with: UIColor.white)
        backButton.image = Icon.cm.arrowBack
        title = "Profile"
        
        bindViewModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func bindViewModel() {
        assert(viewModel != nil)
        let input = ProfileViewModel.Input.init(backTrigger: backButton.rx.tap.asDriver(),
                                                photoTrigger: profileImageButton.rx.tap.asDriver(),
                                                editProfileTrigger: editProfileSubject.asDriverOnErrorJustComplete(),
                                                changePasswordTrigger: changePasswordSubject.asDriverOnErrorJustComplete(),
                                                changeVerificationPhotoTrigger: changeVerificationPhotoSubject.asDriverOnErrorJustComplete(),
                                                logoutTrigger: logoutSubject.asDriverOnErrorJustComplete())
        
        let output = viewModel.transform(input: input)
        output.back.drive().disposed(by: disposeBag)
        output.takePhoto.drive().disposed(by: disposeBag)
        output.editProfile.drive().disposed(by: disposeBag)
        output.changePassword.drive().disposed(by: disposeBag)
        output.changeVerificationPhoto.drive().disposed(by: disposeBag)
        output.logout.drive().disposed(by: disposeBag)
        
        output.user.drive(userBinding).disposed(by: disposeBag)
        output.image.drive(imageBinding).disposed(by: disposeBag)
        output.imageUrl.drive(imageUrlBinding).disposed(by: disposeBag)
        output.updateUser.drive(completedBinding).disposed(by: disposeBag)
        output.error.drive(errorBinding).disposed(by: disposeBag)
        output.activityIndicator.drive().disposed(by: disposeBag)
    }
    
    var imageBinding: Binder<UIImage> {
        return Binder(self, binding: { (vc, image) in
            vc.profileImageView.image = image
            vc.hud.textLabel.text = "Uploading user photo..."
            vc.hud.show(in: self.view)
        })
    }
    
    var userBinding: Binder<User> {
        return Binder(self, binding: { (vc, user) in
            vc.profileImageView.imageUrl = user.photoUrl
            vc.nameLabel.text = user.username
            vc.emailLabel.text = user.email
        })
    }
    
    var imageUrlBinding: Binder<Void> {
        return Binder(self, binding: { (vc, _) in
            vc.hud.textLabel.text = "Updating..."
        })
    }
    
    var completedBinding: Binder<Void> {
        return Binder(self, binding: { (vc, _) in
            vc.hud.dismiss(animated: true)
        })
    }
    
    var errorBinding: Binder<Error> {
        return Binder(self, binding: { (vc, error) in
            vc.hud.dismiss()
            vc.showErrorMsg(error.localizedDescription)
        })
    }
}

extension ProfileViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        }
        else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: profileCellIdenitifer, for: indexPath)
        if indexPath.section == 0 {
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.textColor = .black
            cell.accessoryType = .disclosureIndicator
            if indexPath.row == 0 {
                cell.textLabel?.text = "Edit Profile"
                addTopLine(cell)
            }
            else if indexPath.row == 1 {
                cell.textLabel?.text = "Change Password"
            }
            else {
                cell.textLabel?.text = "Change Verification Photo"
                addBottomLine(cell)
            }
        }
        else {
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .red
            cell.accessoryType = .none
            cell.textLabel?.text = "Log out"
            cell.separatorInset = UIEdgeInsets.zero
            addTopLine(cell)
            addBottomLine(cell)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return emptyHeaderView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 10
        }
        else {
            return 30
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                editProfileSubject.onNext(true)
            }
            else if indexPath.row == 1 {
                changePasswordSubject.onNext(true)
            }
            else {
                changeVerificationPhotoSubject.onNext(true)
            }
        }
        else {
            logoutSubject.onNext(true)
        }
    }
}
