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
        if (AppManager.sharedInstance().profile == nil) {
            self.profile = Profile()
        }
        else {
            self.profile = AppManager.sharedInstance().profile!
        }
        print(self.profile.user.toJSON())
    }
    func transform(input: Input) -> Output {
        
        let initial = input.initialTrigger
            .filter({ [unowned self] () -> Bool in
                return self.profile.verificationPhoto == nil && self.profile.user.verificationUrl.isEmpty
            })
            .do(onNext: { () in
                self.navigator.toTakePhoto(self.imageSubject, animated: true)
            })
        let back = input.backTrigger
            .do(onNext: navigator.back)
        
        let photo = input.photoTrigger
            .do(onNext: { [unowned self] () in
                self.navigator.toTakePhoto(self.imageSubject, animated: true)
            })
        
        let image = imageSubject.asDriverOnErrorJustComplete()
        let profile = Driver.combineLatest(Driver.just(self.profile), image) { [unowned self] (profile, image) -> Profile in
            self.profile.verificationPhoto = image
            AppManager.sharedInstance().profile = self.profile
            return self.profile
        }.startWith(self.profile)
        
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        let uploadUserPhoto = input.doneTrigger
            .filter({ (valid) -> Bool in
                return valid
            })
            .withLatestFrom(profile)
            .flatMapLatest { [unowned self] profile -> SharedSequence<DriverSharingStrategy, Profile> in
                if profile.userPhoto != nil {
                    let blobName = self.generateBlobName("photo")
                    return self.imageUseCase.uploadImage(blobName, data: UIImageJPEGRepresentation(profile.userPhoto!, 1.0)!)
                                    .trackActivity(activityIndicator)
                                    .trackError(errorTracker)
                                    .asDriverOnErrorJustComplete()
                                    .map { [unowned self] (imageUrl) -> Profile in
                                        self.profile = Profile(user: User(firstname: profile.user.firstName,
                                                                          lastname: profile.user.lastName,
                                                                          email: profile.user.email,
                                                                          password: profile.user.password,
                                                                          phone: profile.user.phone,
                                                                          zipcode: profile.user.zipcode,
                                                                          photoUrl: imageUrl,
                                                                          verificationUrl: profile.user.verificationUrl),
                                                               userPhoto: nil,
                                                               verificationPhoto: profile.verificationPhoto)
                                        AppManager.sharedInstance().profile = self.profile
                                        return self.profile
                                }
                }
                else {
                    return Driver.just(profile)
                }
        }
        
        let uploadVerificationPhoto = uploadUserPhoto
            .flatMapLatest { [unowned self] (profile) -> SharedSequence<DriverSharingStrategy, Profile> in
                if profile.verificationPhoto != nil {
                    let blobName = self.generateBlobName("verification")
                    return self.imageUseCase.uploadImage(blobName, data: UIImageJPEGRepresentation(profile.verificationPhoto!, 1.0)!)
                        .trackActivity(activityIndicator)
                        .trackError(errorTracker)
                        .asDriverOnErrorJustComplete()
                        .map { [unowned self] (imageUrl) -> Profile in
                            self.profile = Profile(user: User(firstname: profile.user.firstName,
                                                              lastname: profile.user.lastName,
                                                              email: profile.user.email,
                                                              password: profile.user.password,
                                                              phone: profile.user.phone,
                                                              zipcode: profile.user.zipcode,
                                                              photoUrl: profile.user.photoUrl,
                                                              verificationUrl: imageUrl),
                                                   userPhoto: nil,
                                                   verificationPhoto: nil)
                            AppManager.sharedInstance().profile = self.profile
                            return self.profile
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
            .flatMapLatest({ (user) -> SharedSequence<DriverSharingStrategy, Void> in
                AppManager.sharedInstance().profile = Profile(user: user)
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
    
    private func generateBlobName(_ subfix: String) -> String {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return "\(dateFormatter.string(from: now))/\(profile.user.username)_\(subfix)_\(now.timeIntervalSince1970).jpg"
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


