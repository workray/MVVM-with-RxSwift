//
//  PhotoViewController.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/6/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import CropViewController
import Material
import RxSwift
import RxCocoa

class CropAvatarPhotoViewController: UIViewController {

    private let disposeBag = DisposeBag()
    
    var viewModel: CropAvatarPhotoViewModel!
    
    @IBOutlet weak var closeButton: CloseButton!
    @IBOutlet weak var backButton: BackButton!
    @IBOutlet weak var chooseButton: RaisedButton!
    
    var imageSubject: PublishSubject<UIImage>!
    var cropView: TOCropView!
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cropView = TOCropView(croppingStyle: TOCropViewCroppingStyle.circular, image: image)
        cropView.frame = self.view.bounds
        self.view.insertSubview(cropView, at: 0)
        cropView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        cropView.internalLayoutDisabled = true
        cropView.cropRegionInsets = UIEdgeInsets.zero;
        cropView.performInitialSetup();
        
        closeButton.image = Icon.close?.tint(with: UIColor.white)
        
        bindViewModel()
    }

    private func bindViewModel() {
        assert(viewModel != nil)
        assert(imageSubject != nil)
        let input = CropAvatarPhotoViewModel.Input(closeTrigger: closeButton.rx.tap.asDriver(),
                                             backTrigger: backButton.rx.tap.asDriver(),
                                             cropTrigger: chooseButton.rx.tap.asDriver(),
                                             imageTrigger: imageSubject.asDriverOnErrorJustComplete())
        let output = viewModel.transform(input: input)
        
        output.close.drive().disposed(by: disposeBag)
        output.back.drive().disposed(by: disposeBag)
        output.crop.drive(cropBinding).disposed(by: disposeBag)
        output.cropPhoto.drive().disposed(by: disposeBag)
    }
    
    var cropBinding: Binder<Void> {
        return Binder(self, binding: { (vc, _) in
            let cropFrame = vc.cropView.imageCropFrame
            let angle = vc.cropView.angle
            
            var image: UIImage
            if angle == 0 && cropFrame.equalTo(CGRect.init(origin: CGPoint.zero, size: self.image.size)) {
                image = self.image;
            }
            else {
                image = self.image.croppedImage(withFrame: cropFrame, angle: angle, circularClip: true)
            }
            self.imageSubject.onNext(image)
        })
    }
}

