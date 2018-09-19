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
        let imageSubject = PublishSubject<UIImage>.init()
        let back = input.backTrigger
            .do(onNext: navigator.back)
        
        let takePhoto = input.photoTrigger
            .do(onNext: { [unowned self] in
                self.navigator.toTakePhoto(imageSubject)
            })
        
        let activityIndicator = ActivityIndicator()
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
            }.flatMapLatest { [unowned self] (verificationPhoto) -> SharedSequence<DriverSharingStrategy, User> in
                self.useCase.updateVerificationPhoto(verificationPhoto: verificationPhoto)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
        let initial = input.initialTrigger.withLatestFrom(Driver.just(AppManager.sharedInstance().profile!.user))
        let verificationPhoto = Driver.merge(initial, updateVerificationPhoto).map{ $0.verificationUrl }
        let deleteOldVerificationPhoto = updateVerificationPhoto
            .filter{ !($0 == AppManager.sharedInstance().profile!.user)}
            .map({ (user) -> String in
                let verificationUrl = user.verificationUrl
                AppManager.sharedInstance().profile?.user = user
                return verificationUrl
            })
            .flatMapLatest { (verificationUrl) -> SharedSequence<DriverSharingStrategy, Void> in
                return self.imageUseCase.deleteImage(verificationUrl)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
        }
        return Output(
            verificationPhoto: verificationPhoto,
            back: back,
            image: image,
            imageUrl: imageUrl.mapToVoid(),
            deleteOldVerificationPhoto: deleteOldVerificationPhoto,
            takePhoto: takePhoto,
            updateVerificationPhoto: updateVerificationPhoto.mapToVoid(),
            error: errorTracker.asDriver(),
            activityIndicator: activityIndicator.asDriver()
        )
    }
}

extension ChangeVerificationPhotoViewModel {
    struct Input {
        let initialTrigger: Driver<Void>
        let backTrigger: Driver<Void>
        let photoTrigger: Driver<Void>
    }
    
    struct Output {
        let verificationPhoto: Driver<String>
        let back: Driver<Void>
        let image: Driver<UIImage>
        let imageUrl: Driver<Void>
        let deleteOldVerificationPhoto: Driver<Void>
        let takePhoto: Driver<Void>
        let updateVerificationPhoto: Driver<Void>
        let error: Driver<Error>
        let activityIndicator: Driver<Bool>
    }
}
