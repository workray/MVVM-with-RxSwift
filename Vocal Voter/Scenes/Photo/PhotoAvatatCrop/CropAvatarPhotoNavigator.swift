//
//  PhotoAvatarCropNavigator.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/6/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import RxSwift

protocol CropAvatarPhotoNavigator {
    func back()
    func toCropPhoto(image: UIImage, imageSubject: PublishSubject<UIImage>)
    func didCroppedPhoto(_ image: UIImage)
    func close()
}

final class DefaultCropAvatarPhotoNavigator: CropAvatarPhotoNavigator {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func back() {
        navigationController.popViewController(animated: true)
    }
    
    func toCropPhoto(image: UIImage, imageSubject: PublishSubject<UIImage>) {
        let cropPhotoVc = CropAvatarPhotoViewController(nibName: "CropAvatarPhotoViewController", bundle: nil)
        cropPhotoVc.viewModel = CropAvatarPhotoViewModel(navigator: self)
        cropPhotoVc.imageSubject = imageSubject
        cropPhotoVc.image = image
        navigationController.pushViewController(cropPhotoVc, animated: true)
    }
    
    func didCroppedPhoto(_ image: UIImage) {
        close()
    }
    
    func close() {
        navigationController.dismiss(animated: true, completion: nil)
    }
}

