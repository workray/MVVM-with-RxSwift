//
//  ChangeVerificationPhotoViewModel.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/19/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import Domain
import RxSwift
import RxCocoa

final class ChangeVerificationPhotoViewModel: ViewModelType {
    
    private let useCase: UserUseCase
    private let imageUseCase: ImageUseCase
    private let navigator: ChangeVerificationPhotoNavigator
    private let user: User
    
    init(useCase: UserUseCase, imageUseCase: ImageUseCase, navigator: ChangeVerificationPhotoNavigator, user: User) {
        self.navigator = navigator
        self.useCase = useCase
        self.imageUseCase = imageUseCase
        self.user = user
    }
    
    func transform(input: Input) -> Output {
        let activityIndicator = ActivityIndicator()
        let activity = activityIndicator.asDriver()
        
        let back = input.backTrigger
            .withLatestFrom(activity)
            .filter{ !$0 }
            .mapToVoid()
            .do(onNext: navigator.back)
        
        let imageSubject = PublishSubject<UIImage>.init()
        let takePhoto = input.photoTrigger
            .withLatestFrom(activity)
            .filter{ !$0 }
            .mapToVoid()
            .do(onNext: { [unowned self] in
                self.navigator.toTakePhoto(imageSubject)
            })
        
        let errorTracker = ErrorTracker()
        let image = imageSubject.asDriverOnErrorJustComplete()
        let imageUrl = Driver.combineLatest(Driver.just(self.user.uid), image)
            .flatMapLatest { [unowned self] (uid, image) -> SharedSequence<DriverSharingStrategy, String> in
                let blobName = String.generateBlobName(prefix:uid, subfix:"verification")
                return self.imageUseCase.uploadImage(blobName, data: image.jpegData(compressionQuality: 1.0)!)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
        }
        let updateVerificationPhoto = Driver.combineLatest(Driver.just(self.user.uid), imageUrl) { (uid, imageUrl) -> UserVerificationPhoto in
                return UserVerificationPhoto(uid: uid, verificationPhotoUrl: imageUrl)
            }.flatMapLatest { [unowned self] (verificationPhoto) -> SharedSequence<DriverSharingStrategy, Void> in
                self.useCase.updateVerificationPhoto(verificationPhoto: verificationPhoto)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
                    .map({ (user) -> String in
                        let oldVerificationUrl = AppManager.getCurrentUser().verificationUrl
                        AppManager.getUserPublishSubject().onNext(user)
                        return oldVerificationUrl
                    }).filter{ !$0.isEmpty }
                    .flatMapLatest({ [unowned self] (oldVerificationUrl) -> SharedSequence<DriverSharingStrategy, Void> in
                        return self.imageUseCase.deleteImage(oldVerificationUrl)
                            .trackActivity(activityIndicator)
                            .trackError(errorTracker)
                            .asDriverOnErrorJustComplete()
                    })
            }
        
        let verificationPhoto = AppManager.getUserPublishSubject().asDriverOnErrorJustComplete().startWith(AppManager.getCurrentUser()).map{ $0.verificationUrl }
        
        return Output(
            verificationPhoto: verificationPhoto,
            back: back,
            image: image,
            imageUrl: imageUrl.mapToVoid(),
            takePhoto: takePhoto,
            updateVerificationPhoto: updateVerificationPhoto.mapToVoid(),
            error: errorTracker.asDriver(),
            activityIndicator: activityIndicator.asDriver()
        )
    }
}

extension ChangeVerificationPhotoViewModel {
    struct Input {
        let backTrigger: Driver<Void>
        let photoTrigger: Driver<Void>
    }
    
    struct Output {
        let verificationPhoto: Driver<String>
        let back: Driver<Void>
        let image: Driver<UIImage>
        let imageUrl: Driver<Void>
        let takePhoto: Driver<Void>
        let updateVerificationPhoto: Driver<Void>
        let error: Driver<Error>
        let activityIndicator: Driver<Bool>
    }
}
