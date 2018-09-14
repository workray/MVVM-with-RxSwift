//
//  PhotoAvatarCropNavigator.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/6/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import RxSwift

protocol PhotoAvatarCropNavigator {
    func cancel()
    func toCropPhoto()
    func didCroppedPhoto(_ image: UIImage)
    func close()
}

final class DefaultPhotoAvatarCropNavigator: PhotoAvatarCropNavigator {
    private let navigationController: UINavigationController
    private let imageSubject:PublishSubject<UIImage>
    
    init(navigationController: UINavigationController,
         imageSubject: PublishSubject<UIImage>) {
        self.navigationController = navigationController
        self.imageSubject = imageSubject
    }
    
    func cancel() {
        navigationController.popViewController(animated: true)
    }
    
    func toCropPhoto() {
        let cropPhotoVc = PhotoAvaViewController(nibName: "TakePhotoViewController", bundle: nil)
        cropPhotoVc.viewModel = TakePhotoViewModel(navigator: self)
        navigationController.pushViewController(cropPhotoVc, animated: false)
    }
    
    func didCroppedPhoto(_ image: UIImage) {
        imageSubject.onNext(image)
        close()
    }
    
    func close() {
        navigationController.dismiss(animated: true, completion: nil)
    }
}

