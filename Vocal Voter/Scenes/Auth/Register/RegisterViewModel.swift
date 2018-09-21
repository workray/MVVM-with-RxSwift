//
//  RegisterViewModel.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/6/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import Domain
import RxSwift
import RxCocoa

final class RegisterViewModel: ViewModelType {
    
    private let userUseCase: UserUseCase
    private let navigator: RegisterNavigator
    private let imageSubject = PublishSubject<UIImage>()
    private let profile: Profile
    
    init(useCase: UserUseCase, navigator: RegisterNavigator) {
        self.userUseCase = useCase
        self.navigator = navigator
        self.profile = AuthProfileManager.getProfile()
    }
    
    func transform(input: Input) -> Output {
        let activityIndicator = ActivityIndicator()
        let activity = activityIndicator.asDriver()
        
        let back = input.backTrigger
            .withLatestFrom(activity)
            .filter{ !$0 }
            .mapToVoid()
            .do(onNext: navigator.back)
        
        let photo = input.photoTrigger
            .withLatestFrom(activity)
            .filter{ !$0 }
            .mapToVoid()
            .do(onNext: { [unowned self] in
                self.navigator.toTakePhoto(self.imageSubject)
            })
        
        let image = imageSubject.asDriverOnErrorJustComplete()
        let fields = Driver.combineLatest(input.firstName,
                                           input.lastName,
                                           input.email,
                                           input.password,
                                           input.phoneNumber,
                                           input.zipcode) {
                                            return ($0, $1, $2, $3.password(), $4, $5)
        }
        let profile1 = Driver.combineLatest(Driver.just(self.profile), fields) { (profile, fields) -> Profile in
            let user = User(uid: profile.user.uid,
                                     firstname: fields.0,
                                     lastname: fields.1,
                                     email: fields.2,
                                     password: fields.3,
                                     phone: fields.4,
                                     zipcode: fields.5,
                                     photoUrl: profile.user.photoUrl,
                                     verificationUrl: profile.user.verificationUrl,
                                     verified: profile.user.verified)
            let newProfile = Profile(user: user, userPhoto: profile.userPhoto, verificationPhoto: profile.verificationPhoto)
            AuthProfileManager.getProfilePublishSubject().onNext(newProfile)
            return newProfile
        }
        let profile = Driver.combineLatest(profile1, image) { (profile, image) -> Profile in
            let newProfile = Profile(user: profile.user, userPhoto: image, verificationPhoto: profile.verificationPhoto)
            AuthProfileManager.getProfilePublishSubject().onNext(newProfile)
            return newProfile
        }.startWith(self.profile)
        
        let errorTracker = ErrorTracker()
        let checkUser = input.continueTrigger
            .filter{ $0 }
            .withLatestFrom(activity)
            .filter{ !$0 }
            .mapToVoid()
            .withLatestFrom(profile)
            .map{ (profile) in
                return CheckUser(email: profile.user.email, phone: profile.user.phone)
            }
            .flatMapLatest({ (user) -> SharedSequence<DriverSharingStrategy, Bool> in
                return self.userUseCase.checkUser(user: user)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            })
        let next = checkUser
            .filter{ $0 }
            .flatMapLatest { [unowned self] _ in
                return Driver.just(self.navigator.toContinue())
            }
        
        return Output(back: back,
                      photo: photo,
                      profile: profile,
                      next: next,
                      checkUser: checkUser,
                      error: errorTracker.asDriver(),
                      activityIndicator: activityIndicator.asDriver()
        )
    }
}

extension RegisterViewModel {
    struct Input {
        let backTrigger: Driver<Void>
        let photoTrigger: Driver<Void>
        let continueTrigger: Driver<Bool>
        
        let firstName: Driver<String>
        let lastName: Driver<String>
        let email: Driver<String>
        let password: Driver<String>
        let phoneNumber: Driver<String>
        let zipcode: Driver<String>
    }
    
    struct Output {
        let back: Driver<Void>
        let photo: Driver<Void>
        let profile: Driver<Profile>
        let next: Driver<Void>
        let checkUser: Driver<Bool>
        let error: Driver<Error>
        let activityIndicator: Driver<Bool>
    }
}

