//
//  VerificationPhotoViewController.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/6/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import Domain
import RxSwift
import RxCocoa
import Material
import JGProgressHUD
import Kingfisher

class VerificationPhotoViewController: ImageViewController {
    
    private let disposeBag = DisposeBag()
    
    var viewModel: VerificationPhotoViewModel!
    
    @IBOutlet weak var backButton: BackButton!
    @IBOutlet weak var imageButton: RaisedButton!
    @IBOutlet weak var doneButton: RaisedButton!
    @IBOutlet weak var contentView: UIView!
    
    let hud = UIViewController.getHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageButton.image = Icon.cm.photoCamera?.tint(with: UIColor.white)
        
        bindViewModel()
    }
    
    private func bindViewModel() {
        assert(viewModel != nil)
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .take(1)
            .asDriverOnErrorJustComplete()
        let doneTrigger = doneButton.rx.tap.flatMap { [unowned self] in
            return Driver.just(self.imageView.image != nil)
        }
        let input = VerificationPhotoViewModel.Input(initialTrigger: viewWillAppear,
                                            backTrigger: backButton.rx.tap.asDriver(),
                                            photoTrigger: imageButton.rx.tap.asDriver(),
                                            doneTrigger: doneTrigger.asDriverOnErrorJustComplete())
        let output = viewModel.transform(input: input)
        
        output.initial.drive().disposed(by: disposeBag)
        output.back.drive().disposed(by: disposeBag)
        output.photo.drive().disposed(by: disposeBag)
        output.profile.drive(profileBinding).disposed(by: disposeBag)
        output.done.drive(onNext: { [unowned self] (valid) in
            if (valid) {
                self.hud.textLabel.text = "Uploading user photo..."
                self.hud.show(in: self.view)
            }
            else {
                self.showErrorMsg("Verification photo should be existed!")
            }
        }).disposed(by: disposeBag)
        output.uploadUserPhoto.drive(onNext: { [unowned self] (profile) in
            self.hud.textLabel.text = "Uploading verification photo..."
        }).disposed(by: disposeBag)
        output.uploadVerificationPhoto.drive(onNext: { [unowned self] (profile) in
            self.hud.textLabel.text = "Registering..."
        }).disposed(by: disposeBag)
        output.registerUser.drive(onNext: { [unowned self] (profile) in
            self.hud.dismiss()
        }).disposed(by: disposeBag)
        output.error.drive(onNext: { [unowned self] (error) in
            self.hud.dismiss()
            self.showErrorMsg(error.localizedDescription)
        }).disposed(by: disposeBag)
        output.activityIndicator.drive().disposed(by: disposeBag)
    }
    
    var profileBinding: Binder<Profile> {
        return Binder(self, binding: { (vc, profile) in
            if profile.verificationPhoto != nil {
                vc.imageView.image = profile.verificationPhoto
            }
            else if !profile.user.verificationUrl.isEmpty {
                vc.imageView.imageUrl = profile.user.verificationUrl
            }
        })
    }
    
    override func getContentView() -> UIView {
        return self.contentView
    }
}
