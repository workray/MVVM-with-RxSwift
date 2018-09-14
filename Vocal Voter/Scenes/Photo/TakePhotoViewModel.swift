//
//  TakePhotoViewModel.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/6/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import RxSwift
import RxCocoa

class TakePhotoViewModel: ViewModelType {
    
    private let navigator: TakePhotoNavigator
    
    init(navigator: TakePhotoNavigator) {
        self.navigator = navigator
    }
    
    func transform(input: Input) -> Output {
        let close = input.closeTrigger
            .do(onNext: navigator.close)
        let image = input.imageTrigger.do(onNext: { (image) in
            self.navigator.didTakePhoto(image)
        })
        return Output(close: close,
                      library: input.libraryTrigger,
                      flip: input.flipTrigger,
                      flash: input.flashTrigger,
                      image: image)
    }
}

extension TakePhotoViewModel {
    struct Input {
        let closeTrigger: Driver<Void>
        let libraryTrigger: Driver<Void>
        let flipTrigger: Driver<Void>
        let flashTrigger: Driver<Void>
        let imageTrigger: Driver<UIImage>
    }
    
    struct Output {
        let close: Driver<Void>
        let library: Driver<Void>
        let flip: Driver<Void>
        let flash: Driver<Void>
        let image: Driver<UIImage>
    }
}

