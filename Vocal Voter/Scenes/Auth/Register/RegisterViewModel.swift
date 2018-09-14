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
    private var profile: Profile
    
    init(useCase: UserUseCase, navigator: RegisterNavigator) {
        self.userUseCase = useCase
        self.navigator = navigator
        
        if (AppManager.sharedInstance().profile == nil) {
            self.profile = Profile()
        }
        else {
            self.profile = AppManager.sharedInstance().profile!
        }
    }
    
    func transform(input: Input) -> Output {
        let back = input.backTrigger
            .do(onNext: navigator.back)
        
        let photo = input.photoTrigger
            .do(onNext: { [unowned self] in
                self.navigator.toTakePhoto(self.imageSubject)
            })
        
        let image = imageSubject.asDriverOnErrorJustComplete()
        let fields = Driver.combineLatest(input.firstName,
                                           input.lastName,
                                           input.email,
                                           input.password,
                                           input.phoneNumber,
                                           input.zipcode,
                                           image) {
                                            return ($0, $1, $2, $3.password(), $4, $5, $6)
        }
        let profile = Driver.combineLatest(Driver.just(self.profile), fields) { (profile, fields) -> Profile in
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
            
            let profile = Profile(user: user, userPhoto: fields.6, verificationPhoto: profile.verificationPhoto)
            AppManager.sharedInstance().profile = profile
            return profile
        }.startWith(self.profile)
        
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        let checkUser = input.continueTrigger
            .filter({ (valid) -> Bool in
                return valid
            })
            .withLatestFrom(profile)
            .map{ (profile) in
                return CheckUser(email: profile.user.email, phone: profile.user.phone)
            }
            .flatMapLatest({ (user) -> SharedSequence<DriverSharingStrategy, [User]> in
                return self.userUseCase.checkUser(user: user)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            })
        let next = checkUser
            .filter{ $0.count == 0 }
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
        let checkUser: Driver<[User]>
        let error: Driver<Error>
        let activityIndicator: Driver<Bool>
    }
}

