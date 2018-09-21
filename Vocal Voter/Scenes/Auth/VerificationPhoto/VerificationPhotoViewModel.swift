//
//  VerificationPhotoViewModel.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/7/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import Domain
import RxSwift
import RxCocoa

final class VerificationPhotoViewModel: ViewModelType {
    
    private let userUseCase: UserUseCase
    private let imageUseCase: ImageUseCase
    private let navigator: VerificationPhotoNavigator
    private let imageSubject = PublishSubject<UIImage>()
    private var profile: Profile
    
    init(userUseCase: UserUseCase, imageUseCase: ImageUseCase, navigator: VerificationPhotoNavigator) {
        self.navigator = navigator
        self.userUseCase = userUseCase
        self.imageUseCase = imageUseCase
        self.profile = AuthProfileManager.getProfile()
    }
    func transform(input: Input) -> Output {
        let activityIndicator = ActivityIndicator()
        let activity = activityIndicator.asDriver()
        
        let initial = input.initialTrigger
            .filter({ [unowned self] () -> Bool in
                return self.profile.verificationPhoto == nil && self.profile.user.verificationUrl.isEmpty
            })
            .do(onNext: { () in
                self.navigator.toTakePhoto(self.imageSubject, animated: true)
            })
        let back = input.backTrigger
            .withLatestFrom(activity)
            .filter{ !$0 }
            .mapToVoid()
            .do(onNext: navigator.back)
        
        let photo = input.photoTrigger
            .withLatestFrom(activity)
            .filter{ !$0 }
            .mapToVoid()
            .do(onNext: { [unowned self] () in
                self.navigator.toTakePhoto(self.imageSubject, animated: true)
            })
        
        let image = imageSubject.asDriverOnErrorJustComplete()
        let profile = Driver.combineLatest(Driver.just(self.profile), image) { (profile, image) -> Profile in
            let profile = Profile(user: profile.user, userPhoto: profile.userPhoto, verificationPhoto: image)
            AuthProfileManager.getProfilePublishSubject().onNext(profile)
            return profile
        }.startWith(self.profile)
        
        let errorTracker = ErrorTracker()
        let uploadUserPhoto = input.doneTrigger
            .filter{ $0 }
            .withLatestFrom(activity)
            .filter{ !$0 }
            .mapToVoid()
            .withLatestFrom(profile)
            .flatMapLatest { [unowned self] profile -> SharedSequence<DriverSharingStrategy, Profile> in
                if profile.userPhoto != nil {
                    let blobName = String.generateBlobName(prefix: profile.user.uid, subfix:"photo")
                    return self.imageUseCase.uploadImage(blobName, data: profile.userPhoto!.jpegData(compressionQuality: 1.0)!)
                                    .trackActivity(activityIndicator)
                                    .trackError(errorTracker)
                                    .asDriverOnErrorJustComplete()
                                    .map { (imageUrl) -> Profile in
                                        let newProfile = Profile(user: User(firstname: profile.user.firstName,
                                                                          lastname: profile.user.lastName,
                                                                          email: profile.user.email,
                                                                          password: profile.user.password,
                                                                          phone: profile.user.phone,
                                                                          zipcode: profile.user.zipcode,
                                                                          photoUrl: imageUrl,
                                                                          verificationUrl: profile.user.verificationUrl),
                                                               userPhoto: nil,
                                                               verificationPhoto: profile.verificationPhoto)
                                        AuthProfileManager.getProfilePublishSubject().onNext(newProfile)
                                        return newProfile
                                }
                }
                else {
                    return Driver.just(profile)
                }
        }
        
        let uploadVerificationPhoto = uploadUserPhoto
            .flatMapLatest { [unowned self] (profile) -> SharedSequence<DriverSharingStrategy, Profile> in
                if profile.verificationPhoto != nil {
                    let blobName = String.generateBlobName(prefix:profile.user.uid, subfix:"verification")
                    return self.imageUseCase.uploadImage(blobName, data: profile.verificationPhoto!.jpegData(compressionQuality: 1.0)!)
                        .trackActivity(activityIndicator)
                        .trackError(errorTracker)
                        .asDriverOnErrorJustComplete()
                        .map { (imageUrl) -> Profile in
                            let newProfile = Profile(user: User(firstname: profile.user.firstName,
                                                              lastname: profile.user.lastName,
                                                              email: profile.user.email,
                                                              password: profile.user.password,
                                                              phone: profile.user.phone,
                                                              zipcode: profile.user.zipcode,
                                                              photoUrl: profile.user.photoUrl,
                                                              verificationUrl: imageUrl),
                                                   userPhoto: nil,
                                                   verificationPhoto: nil)
                            AuthProfileManager.getProfilePublishSubject().onNext(newProfile)
                            return newProfile
                    }
                }
                else {
                    return Driver.just(profile)
                }
        }
        
        let registerUser = uploadVerificationPhoto
            .flatMapLatest { [unowned self] (profile) -> SharedSequence<DriverSharingStrategy, User> in
                return self.userUseCase.register(user: profile.user)
                            .trackActivity(activityIndicator)
                            .trackError(errorTracker)
                            .asDriverOnErrorJustComplete()
        }
            .flatMapLatest({[unowned self] (user) -> SharedSequence<DriverSharingStrategy, Void> in
                AuthProfileManager.getProfilePublishSubject().onNext(Profile())
                AppManager.getUserPublishSubject().onNext(user)
                return Driver.just(self.navigator.toHome())
            })
        
        return Output(initial: initial,
                      back: back,
                      photo: photo,
                      profile: profile,
                      done: input.doneTrigger,
                      uploadUserPhoto: uploadUserPhoto,
                      uploadVerificationPhoto: uploadVerificationPhoto,
                      registerUser: registerUser,
                      error: errorTracker.asDriver(),
                      activityIndicator: activityIndicator.asDriver()
        )
    }
}

extension VerificationPhotoViewModel {
    struct Input {
        let initialTrigger: Driver<Void>
        let backTrigger: Driver<Void>
        let photoTrigger: Driver<Void>
        let doneTrigger: Driver<Bool>
    }
    
    struct Output {
        let initial: Driver<Void>
        let back: Driver<Void>
        let photo: Driver<Void>
        let profile: Driver<Profile>
        let done: Driver<Bool>
        let uploadUserPhoto: Driver<Profile>
        let uploadVerificationPhoto: Driver<Profile>
        let registerUser: Driver<Void>
        let error: Driver<Error>
        let activityIndicator: Driver<Bool>
    }
}


