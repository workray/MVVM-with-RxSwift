//
//  ChangePasswordViewModel.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/19/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import Domain
import RxSwift
import RxCocoa

final class ChangePasswordViewModel: ViewModelType {
    
    private let userUseCase: UserUseCase
    private let navigator: ChangePasswordNavigator
    private var password: UserPassword
    
    init(useCase: UserUseCase, navigator: ChangePasswordNavigator, user: User) {
        self.userUseCase = useCase
        self.navigator = navigator
        self.password = UserPassword(uid: user.uid, password: user.password)
    }
    
    func transform(input: Input) -> Output {
        let activityIndicator = ActivityIndicator()
        let activity = activityIndicator.asDriver()
        
        let back = input.backTrigger
            .withLatestFrom(activity)
            .filter{ !$0 }
            .mapToVoid()
            .do(onNext: navigator.back)
        
        let passwordSubject = PublishSubject<UserPassword>.init()
        let password = passwordSubject.asDriverOnErrorJustComplete()
            .startWith(self.password)
            .do(onNext: { [unowned self] (password) in
                self.password = password
            })
        let updatePassword = Driver.combineLatest(Driver.just(self.password.uid), input.newPassword) { (uid, password) -> UserPassword in
                return UserPassword(uid: uid, password: password.password())
            }
            .startWith(self.password)
        
        let valid = Driver.combineLatest(password, input.oldPassword, input.newPassword, activity) {
            return $0.password == $1.password() && $2.count >= 6 && !$3
        }
        
        let errorTracker = ErrorTracker()
        let change = input.changeTrigger
            .withLatestFrom(activity)
            .filter{ !$0 }
            .withLatestFrom(updatePassword)
            .flatMapLatest { [unowned self] password -> SharedSequence<DriverSharingStrategy, User> in
                return self.userUseCase.updatePassword(userPassword: password)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
                    .do(onNext: {(user) in
                        AppManager.getUserPublishSubject().onNext(user)
                        passwordSubject.onNext(UserPassword(uid: user.uid, password: user.password))
                    })
            }
            .mapToVoid()
        
        let next = change
            .debounce(2)
            .do(onNext: navigator.back)
        
        return Output(back: back,
                      change: change,
                      next: next,
                      valid: valid,
                      error: errorTracker.asDriver(),
                      activityIndicator: activityIndicator.asDriver()
        )
    }
}

extension ChangePasswordViewModel {
    struct Input {
        let backTrigger: Driver<Void>
        let changeTrigger: Driver<Void>
        
        let oldPassword: Driver<String>
        let newPassword: Driver<String>
    }
    
    struct Output {
        let back: Driver<Void>
        let change: Driver<Void>
        let next: Driver<Void>
        let valid: Driver<Bool>
        let error: Driver<Error>
        let activityIndicator: Driver<Bool>
    }
}
