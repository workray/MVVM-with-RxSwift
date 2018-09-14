//
//  ForgotPasswordViewModel.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/6/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import Domain
import RxSwift
import RxCocoa

final class ForgotPasswordViewModel: ViewModelType {
    
    private let useCase: ForgotPasswordUseCase
    private let navigator: ForgotPasswordNavigator
    
    init(useCase: ForgotPasswordUseCase, navigator: ForgotPasswordNavigator) {
        self.navigator = navigator
        self.useCase = useCase
    }
    
    func transform(input: Input) -> Output {
        let back = input.backTrigger
            .do(onNext: navigator.toLogin)
        let register = input.registerTrigger
            .do(onNext: navigator.toRegister)
        
        let param = input.email.map { ForgotPassword(email: $0) }
        
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        let sendEmail = input.sendEmailTrigger
            .filter{ $0 }
            .withLatestFrom(param)
            .flatMapLatest { [unowned self] in
                return self.useCase.sendEmail(params: $0)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
        let next = sendEmail
            .filter{$0.result == SUCCESS}
            .withLatestFrom(param)
            .flatMapLatest { [unowned self] in
                return Driver.just(self.navigator.toVerificationCode(params: $0))
        }
        let haveAlreadyVerificationCode = input.haveAlreadyVerificationCodeTrigger
            .filter{ $0 }
            .withLatestFrom(param)
            .flatMapLatest { [unowned self] in
                return Driver.just(self.navigator.toVerificationCode(params: $0))
        }
        return Output(back: back,
                      sendEmail: sendEmail,
                      next: next,
                      register: register,
                      haveAlreadyVerificationCode: haveAlreadyVerificationCode,
                      error: errorTracker.asDriver(),
                      activityIndicator: activityIndicator.asDriver()
        )
    }
}

extension ForgotPasswordViewModel {
    struct Input {
        let backTrigger: Driver<Void>
        let sendEmailTrigger: Driver<Bool>
        let registerTrigger: Driver<Void>
        let haveAlreadyVerificationCodeTrigger: Driver<Bool>
        
        let email: Driver<String>
    }
    
    struct Output {
        let back: Driver<Void>
        let sendEmail: Driver<Result>
        let next: Driver<Void>
        let register: Driver<Void>
        let haveAlreadyVerificationCode: Driver<Void>
        
        let error: Driver<Error>
        let activityIndicator: Driver<Bool>
    }
}

