//
//  ProfileViewModel.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/18/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import Domain
import RxSwift
import RxCocoa

final class ProfileViewModel: ViewModelType {
    
    private let useCase: UserUseCase
    private let imageUseCase: ImageUseCase
    private let navigator: ProfileNavigator
    
    init(useCase: UserUseCase, imageUseCase: ImageUseCase, navigator: ProfileNavigator) {
        self.navigator = navigator
        self.useCase = useCase
        self.imageUseCase = imageUseCase
    }
    
    func transform(input: Input) -> Output {
        let imageSubject = PublishSubject<UIImage>.init()
        let activityIndicator = ActivityIndicator()
        let activity = activityIndicator.asDriver()
        let back = input.backTrigger
            .withLatestFrom(activity)
            .filter{ !$0 }
            .mapToVoid()
            .do(onNext: navigator.back)
        let logout = input.logoutTrigger
            .filter{ $0 }
            .withLatestFrom(activity)
            .filter{ !$0 }
            .mapToVoid()
            .do(onNext: { [unowned self] in
                AppManager.loggedOut()
                self.navigator.logout()
            })
        
        let takePhoto = input.photoTrigger
            .withLatestFrom(activity)
            .filter{ !$0 }
            .mapToVoid()
            .do(onNext: { [unowned self] in
                self.navigator.toTakePhoto(imageSubject)
            })
        
        let uid = AppManager.getUserId()
        let userPublishSubject = AppManager.getUserPublishSubject()
        let currentUser = AppManager.getCurrentUser()
        
        let user = userPublishSubject.asDriverOnErrorJustComplete().startWith(currentUser)
        
        let errorTracker = ErrorTracker()
        let image = imageSubject.asDriverOnErrorJustComplete()
        let imageUrl = Driver.combineLatest(Driver.just(uid), image)
            .flatMapLatest { [unowned self] (uid, image) -> SharedSequence<DriverSharingStrategy, String> in
                let blobName = String.generateBlobName(prefix:uid, subfix:"photo")
                return self.imageUseCase.uploadImage(blobName, data: image.jpegData(compressionQuality: 1.0)!)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
        }
        let updateUser = Driver.combineLatest(Driver.just(uid), imageUrl) { (uid, imageUrl) -> UserPhoto in
                return UserPhoto(uid: uid, photoUrl: imageUrl)
            }.flatMapLatest { [unowned self] (userPhoto) -> SharedSequence<DriverSharingStrategy, Void> in
                return self.useCase.updatePhoto(photo: userPhoto)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
                    .map({ (user) -> String in
                        let oldPhotoUrl = AppManager.getCurrentUser().photoUrl
                        userPublishSubject.onNext(user)
                        return oldPhotoUrl
                    })
                    .filter{ !$0.isEmpty }
                    .flatMapLatest({ [unowned self] (oldPhotoUrl) -> SharedSequence<DriverSharingStrategy, Void> in
                        return self.imageUseCase.deleteImage(oldPhotoUrl)
                            .trackActivity(activityIndicator)
                            .trackError(errorTracker)
                            .asDriverOnErrorJustComplete()
                    })
        }
        let editProfile = input.editProfileTrigger
            .filter{ $0 }
            .withLatestFrom(activity)
            .filter{ !$0 }
            .withLatestFrom(user)
            .do(onNext: {[unowned self] (user) in
                self.navigator.toEditProfile(user: user)
            })
        
        let changePassword = input.changePasswordTrigger
            .filter{ $0 }
            .withLatestFrom(activity)
            .filter{ !$0 }
            .withLatestFrom(user)
            .do(onNext: {[unowned self] (user) in
                self.navigator.toChangePassword(user: user)
            })
        
        let changeVerificationPhoto = input.changeVerificationPhotoTrigger
            .filter{ $0 }
            .withLatestFrom(activity)
            .filter{ !$0 }
            .withLatestFrom(user)
            .do(onNext: {[unowned self] (user) in
                self.navigator.toChangeVerificationPhoto(user: user)
            })
        
        return Output(
            back: back,
            user: user,
            updateUser: updateUser,
            image: image,
            imageUrl: imageUrl.mapToVoid(),
            takePhoto: takePhoto,
            editProfile: editProfile.mapToVoid(),
            changePassword: changePassword.mapToVoid(),
            changeVerificationPhoto: changeVerificationPhoto.mapToVoid(),
            logout: logout,
            error: errorTracker.asDriver(),
            activityIndicator: activityIndicator.asDriver()
        )
    }
}

extension ProfileViewModel {
    struct Input {
        let backTrigger: Driver<Void>
        let photoTrigger: Driver<Void>
        let editProfileTrigger: Driver<Bool>
        let changePasswordTrigger: Driver<Bool>
        let changeVerificationPhotoTrigger: Driver<Bool>
        let logoutTrigger: Driver<Bool>
    }
    
    struct Output {
        let back: Driver<Void>
        let user: Driver<User>
        let updateUser: Driver<Void>
        let image: Driver<UIImage>
        let imageUrl: Driver<Void>
        let takePhoto: Driver<Void>
        let editProfile: Driver<Void>
        let changePassword: Driver<Void>
        let changeVerificationPhoto: Driver<Void>
        let logout: Driver<Void>
        let error: Driver<Error>
        let activityIndicator: Driver<Bool>
    }
}
