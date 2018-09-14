//
//  VerificationCodeViewModel.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/13/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import Domain
import RxSwift
import RxCocoa

final class VerificationCodeViewModel: ViewModelType {
    
    private let useCase: ForgotPasswordUseCase
    private let navigator: VerificationCodeNavigator
    private var param: ForgotPassword
    
    init(useCase: ForgotPasswordUseCase, navigator: VerificationCodeNavigator, param: ForgotPassword) {
        self.navigator = navigator
        self.useCase = useCase
        self.param = param;
    }
    
    func transform(input: Input) -> Output {
        let back = input.backTrigger
            .do(onNext: navigator.back)
        
        let verificationCode = Driver.combineLatest(input.verificationCode1,
                                                    input.verificationCode2,
                                                    input.verificationCode3,
                                                    input.verificationCode4,
                                                    input.verificationCode5,
                                                    input.verificationCode6) {
                                                        return ($0, $1, $2, $3, $4, $5)
        }
        
        let activityIndicator = ActivityIndicator()
        
        let canSubmit = Driver.combineLatest(verificationCode, activityIndicator.asDriver()) { (codes, indicator)  -> Bool in
            print(codes)
            return !codes.0.isEmpty && !codes.1.isEmpty && !codes.2.isEmpty && !codes.3.isEmpty && !codes.4.isEmpty && !codes.5.isEmpty && !indicator
//            return !$0.0.isEmpty && !$0.1.isEmpty && !$0.2.isEmpty && !$0.3.isEmpty && !$0.4.isEmpty && !$0.5.isEmpty && !$1
        }
        
        let param = Driver.combineLatest(Driver.just(self.param), verificationCode) { (param, verificationCode) -> ForgotPassword in
            return ForgotPassword(email: param.email, verificationCode: "\(verificationCode.0)\(verificationCode.1)\(verificationCode.2)\(verificationCode.3)\(verificationCode.4)\(verificationCode.5)")
        }.startWith(self.param)
        
        let errorTracker = ErrorTracker()
        let submit = input.submitTrigger
            .withLatestFrom(param)
            .flatMapLatest { [unowned self] in
                return self.useCase.sendVerificationCode(params: $0)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
        }
        
        let next = submit
            .filter{$0.result == SUCCESS}
            .withLatestFrom(param)
            .flatMapLatest { [unowned self] in
                return Driver.just(self.navigator.toResetPassword(param: $0))
        }
        
        let resend = input.resendTrigger.withLatestFrom(Driver.just(self.param.email))
            .flatMapLatest { [unowned self] in
                return self.useCase.sendEmail(params: ForgotPassword(email: $0))
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
        }
        
        return Output(back: back,
                      submit: submit,
                      resend: resend,
                      next: next,
                      canSubmit: canSubmit,
                      error: errorTracker.asDriver(),
                      activityIndicator: activityIndicator.asDriver()
        )
    }
}

extension VerificationCodeViewModel {
    struct Input {
        let backTrigger: Driver<Void>
        let submitTrigger: Driver<Void>
        let resendTrigger: Driver<Void>
        
        let verificationCode1: Driver<String>
        let verificationCode2: Driver<String>
        let verificationCode3: Driver<String>
        let verificationCode4: Driver<String>
        let verificationCode5: Driver<String>
        let verificationCode6: Driver<String>
    }
    
    struct Output {
        let back: Driver<Void>
        let submit: Driver<Result>
        let resend: Driver<Result>
        let next: Driver<Void>
        let canSubmit: Driver<Bool>
        
        let error: Driver<Error>
        let activityIndicator: Driver<Bool>
    }
}

