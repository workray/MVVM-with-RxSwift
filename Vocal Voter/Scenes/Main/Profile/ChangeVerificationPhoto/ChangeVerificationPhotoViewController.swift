//
//  ChangeVerificationPhotoViewController.swift
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
import Kingfisher

class ChangeVerificationPhotoViewController: ImageViewController {

    private let disposeBag = DisposeBag()
    
    var viewModel: ChangeVerificationPhotoViewModel!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var takePhotoButton: UIBarButtonItem!
    
    @IBOutlet weak var contentView: UIView!
    
    let hud = UIViewController.getHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backButton.image = Icon.cm.arrowBack
        takePhotoButton.image = Icon.cm.photoCamera
        
        bindViewModel()
    }
    
    override func getContentView() -> UIView {
        return self.contentView
    }
    
    private func bindViewModel() {
        assert(viewModel != nil)
        let input = ChangeVerificationPhotoViewModel.Input(
            backTrigger: backButton.rx.tap.asDriver(),
            photoTrigger: takePhotoButton.rx.tap.asDriver())
        let output = viewModel.transform(input: input)
        
        output.back.drive().disposed(by: disposeBag)
        output.image.drive(imageBinding).disposed(by: disposeBag)
        output.imageUrl.drive(updateBinding).disposed(by: disposeBag)
        output.takePhoto.drive().disposed(by: disposeBag)
        output.updateVerificationPhoto.drive(completedBinding).disposed(by: disposeBag)
        output.verificationPhoto.drive(verificationPhotoBinding).disposed(by: disposeBag)
        output.error.drive(errorBinding).disposed(by: disposeBag)
        output.activityIndicator.drive().disposed(by: disposeBag)
    }
    
    var imageBinding: Binder<UIImage> {
        return Binder(self, binding: { (vc, image) in
            vc.imageView.image = image
            vc.zoomingScrollView.maximumZoomScale = vc.maxZoomScale()
            
            vc.hud.textLabel.text = "Uploading verification photo..."
            vc.hud.show(in: self.view)
        })
    }
    
    var updateBinding: Binder<Void> {
        return Binder(self, binding: { (vc, _) in
            vc.hud.textLabel.text = "Updating..."
        })
    }
    
    var verificationPhotoBinding: Binder<String> {
        return Binder(self, binding: { (vc, verificationUrl) in
            vc.imageView.imageUrl = verificationUrl
        })
    }
    
    var completedBinding: Binder<Void> {
        return Binder(self, binding: { (vc, _) in
            vc.hud.dismiss()
            let hud = JGProgressHUD(style: .dark)
            hud.indicatorView = JGProgressHUDSuccessIndicatorView()
            hud.textLabel.text = "Verification photo changed successfully!"
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


