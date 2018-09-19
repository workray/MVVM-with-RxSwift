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
        let back = input.backTrigger
            .do(onNext: navigator.back)
        let logout = input.logoutTrigger
            .filter{ $0 }
            .do(onNext: { [unowned self] _ in
                self.navigator.logout()
            })
        
        let takePhoto = input.photoTrigger
            .do(onNext: { [unowned self] in
                self.navigator.toTakePhoto(imageSubject)
            })
        
        let uid = AppManager.sharedInstance().profile!.user.uid
        
        let initial = input.initialTrigger
            .map{ AppManager.sharedInstance().profile!.user }
        
        let activityIndicator = ActivityIndicator()
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
            }.flatMapLatest { [unowned self] (userPhoto) -> SharedSequence<DriverSharingStrategy, User> in
                return self.useCase.updatePhoto(photo: userPhoto)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
        }
        
        let deleteOldPhoto = updateUser
            .filter{ !($0 == AppManager.sharedInstance().profile!.user)}
            .map({ (user) -> String in
                let photoUrl = user.photoUrl
                AppManager.sharedInstance().profile?.user = user
                return photoUrl
            })
            .flatMapLatest { (photoUrl) -> SharedSequence<DriverSharingStrategy, Void> in
                return self.imageUseCase.deleteImage(photoUrl)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
        }
        
        let user = Driver.merge(initial, updateUser)
        let editProfile = input.editProfileTrigger
            .filter{ $0 }
            .withLatestFrom(user)
            .do(onNext: {[unowned self] (user) in
                self.navigator.toEditProfile(user: user)
            })
        
        let changePassword = input.changePasswordTrigger
            .filter{ $0 }
            .withLatestFrom(user)
            .do(onNext: {[unowned self] (user) in
                self.navigator.toChangePassword(user: user)
            })
        
        let changeVerificationPhoto = input.changeVerificationPhotoTrigger
            .filter{ $0 }
            .withLatestFrom(user)
            .do(onNext: {[unowned self] (user) in
                self.navigator.toChangeVerificationPhoto(user: user)
            })
        
        return Output(
            initial: initial.mapToVoid(),
            back: back,
            user: user,
            updateUser: updateUser,
            deleteOldPhoto: deleteOldPhoto,
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
        let initialTrigger: Driver<Void>
        let backTrigger: Driver<Void>
        let photoTrigger: Driver<Void>
        let editProfileTrigger: Driver<Bool>
        let changePasswordTrigger: Driver<Bool>
        let changeVerificationPhotoTrigger: Driver<Bool>
        let logoutTrigger: Driver<Bool>
    }
    
    struct Output {
        let initial: Driver<Void>
        let back: Driver<Void>
        let user: Driver<User>
        let updateUser: Driver<User>
        let deleteOldPhoto: Driver<Void>
        let image: Driver<UIImage>
        let imageUrl: Driver<Void>
        let takePhoto: Driver<Void>
        let editProfile: Driver<Void>
        let changePassword: Driver<Void>
        let changeVerificationPhoto: Driver<Void>
        let logout: Driver<Bool>
        let error: Driver<Error>
        let activityIndicator: Driver<Bool>
    }
}
