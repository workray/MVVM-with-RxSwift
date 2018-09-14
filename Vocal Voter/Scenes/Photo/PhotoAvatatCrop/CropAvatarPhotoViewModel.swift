//
//  PhotoCropAvatarViewModelViewController.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/6/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import RxSwift
import RxCocoa

class CropAvatarPhotoViewModel: ViewModelType {
    
    private let navigator: CropAvatarPhotoNavigator
    
    init(navigator: CropAvatarPhotoNavigator) {
        self.navigator = navigator
    }
    
    func transform(input: Input) -> Output {
        let close = input.closeTrigger
            .do(onNext: navigator.close)
        let back = input.backTrigger
            .do(onNext: navigator.back)
        let image = input.imageTrigger.do(onNext: { (image) in
            self.navigator.didCroppedPhoto(image)
        })
        return Output(close: close,
                      back: back,
                      crop: input.cropTrigger,
                      cropPhoto: image)
    }
}

extension CropAvatarPhotoViewModel {
    struct Input {
        let closeTrigger: Driver<Void>
        let backTrigger: Driver<Void>
        let cropTrigger: Driver<Void>
        let imageTrigger: Driver<UIImage>
    }
    
    struct Output {
        let close: Driver<Void>
        let back: Driver<Void>
        let crop: Driver<Void>
        let cropPhoto: Driver<UIImage>
    }
}
