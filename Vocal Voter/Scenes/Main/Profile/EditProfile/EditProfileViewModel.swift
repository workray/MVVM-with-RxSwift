//
//  EditProfileViewModel.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/19/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import Domain
import RxSwift
import RxCocoa

final class EditProfileViewModel: ViewModelType {
    
    private let userUseCase: UserUseCase
    private let navigator: EditProfileNavigator
    private var profile: UserProfile
    
    init(useCase: UserUseCase, navigator: EditProfileNavigator, user: User) {
        self.userUseCase = useCase
        self.navigator = navigator
        self.profile = UserProfile(user: user)
    }
    
    func transform(input: Input) -> Output {
        let back = input.backTrigger
            .do(onNext: navigator.back)
        
        let profileSubject = PublishSubject<UserProfile>.init()
        let profile = profileSubject.asDriverOnErrorJustComplete()
            .startWith(self.profile)
            .do(onNext: { [unowned self] (profile) in
                self.profile = profile
            })
        
        let fields = Driver.combineLatest(input.firstName,
                                          input.lastName,
                                          input.email,
                                          input.phoneNumber,
                                          input.zipcode) {
                                            return ($0, $1, $2, $3, $4)
        }
        
        let updateProfile = Driver.combineLatest(Driver.just(self.profile.uid), fields) { (uid, fields) -> UserProfile in
                return UserProfile(uid: uid,
                            firstname: fields.0,
                            lastname: fields.1,
                            email: fields.2,
                            phone: fields.3,
                            zipcode: fields.4)
            }
            .startWith(self.profile)
        
        let activityIndicator = ActivityIndicator()
        let valid = Driver.combineLatest(profile, updateProfile, input.valid, activityIndicator.asDriver()) {
            return !($0 == $1) && $2 && !$3
        }
        
        let done = input.doneTrigger.filter{ $0 }.mapToVoid()
        
        let errorTracker = ErrorTracker()
        let checkUser = done
            .withLatestFrom(updateProfile)
            .map{ (profile) in
                return CheckUser(email: profile.email, phone: profile.phone)
            }
            .flatMapLatest({ [unowned self] (user) -> SharedSequence<DriverSharingStrategy, Bool> in
                if user.email == self.profile.email && user.phone == self.profile.phone {
                    return SharedSequence.just(true)
                }
                return self.userUseCase.checkUser(user: user)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
                    .map({ [unowned self] (users) -> Bool in
                        if users.count == 1 && users[0].uid == self.profile.uid {
                            return true
                        }
                        else {
                            return false
                        }
                    })
            })
        let update = checkUser
            .filter{ $0 }
            .withLatestFrom(updateProfile)
            .flatMapLatest { [unowned self] profile -> SharedSequence<DriverSharingStrategy, User> in
                return self.userUseCase.updateProfile(userProfile: profile)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
                    .do(onNext: {(user) in
                        profileSubject.onNext(UserProfile(user: user))
                        AppManager.sharedInstance().profile?.user = user
                    })
        }.mapToVoid()
        
        return Output(back: back,
                      done: done,
                      profile: profile,
                      updateProfile: updateProfile.mapToVoid(),
                      update: update,
                      checkUser: checkUser,
                      valid: valid,
                      error: errorTracker.asDriver(),
                      activityIndicator: activityIndicator.asDriver()
        )
    }
}

extension EditProfileViewModel {
    struct Input {
        let backTrigger: Driver<Void>
        let doneTrigger: Driver<Bool>
        
        let firstName: Driver<String>
        let lastName: Driver<String>
        let email: Driver<String>
        let phoneNumber: Driver<String>
        let zipcode: Driver<String>
        let valid: Driver<Bool>
    }
    
    struct Output {
        let back: Driver<Void>
        let done: Driver<Void>
        let profile: Driver<UserProfile>
        let updateProfile: Driver<Void>
        let update: Driver<Void>
        let checkUser: Driver<Bool>
        let valid: Driver<Bool>
        let error: Driver<Error>
        let activityIndicator: Driver<Bool>
    }
}
