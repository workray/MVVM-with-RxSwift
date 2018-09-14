//
//  ResetPasswordViewModel.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/13/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import Domain
import RxSwift
import RxCocoa

final class ResetPasswordViewModel: ViewModelType {
    
    private let useCase: ForgotPasswordUseCase
    private let navigator: ResetPasswordNavigator
    private var param: ForgotPassword
    
    init(useCase: ForgotPasswordUseCase, navigator: ResetPasswordNavigator, param: ForgotPassword) {
        self.navigator = navigator
        self.useCase = useCase
        self.param = param
    }
    
    func transform(input: Input) -> Output {
        let back = input.backTrigger
            .do(onNext: navigator.back)
        
        let param = Driver.combineLatest(Driver.just(self.param), input.password) { (param, password) -> ForgotPassword in
            return ForgotPassword(email: param.email, verificationCode: param.verificationCode, newPassword: password.password())
        }.startWith(self.param)
        
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        let resetPassword = input.resetPasswordTrigger
            .filter{ $0 }
            .withLatestFrom(param)
            .flatMapLatest { [unowned self] in
                return self.useCase.resetPassword(params: $0)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
        }
        let next = resetPassword
            .filter{$0.result == SUCCESS}
            .debounce(3)
            .flatMapLatest({ (_) -> SharedSequence<DriverSharingStrategy, Void> in
                return Driver.just(self.navigator.toLogin())
            })
        return Output(back: back,
                      resetPassword: resetPassword,
                      next: next,
                      error: errorTracker.asDriver(),
                      activityIndicator: activityIndicator.asDriver()
        )
    }
}

extension ResetPasswordViewModel {
    struct Input {
        let backTrigger: Driver<Void>
        let resetPasswordTrigger: Driver<Bool>
        
        let password: Driver<String>
    }
    
    struct Output {
        let back: Driver<Void>
        let resetPassword: Driver<Result>
        let next: Driver<Void>
        
        let error: Driver<Error>
        let activityIndicator: Driver<Bool>
    }
}

