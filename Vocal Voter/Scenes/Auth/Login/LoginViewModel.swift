//
//  MainViewModel.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/5/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import Domain
import RxSwift
import RxCocoa

final class LoginViewModel: ViewModelType {
    
    private let useCase: UserUseCase
    private let navigator: LoginNavigator
    
    init(useCase: UserUseCase, navigator: LoginNavigator) {
        self.navigator = navigator
        self.useCase = useCase
    }
    
    func transform(input: Input) -> Output {
        let initialTrigger = input.initialTrigger.debounce(2)
        
        let emailAndPassword = Driver.combineLatest(input.email, input.password) {
            return ($0, $1.password())
        }
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        
        let login = input.loginTrigger
            .filter { $0 }
            .withLatestFrom(emailAndPassword)
            .map{ (email, password) in
                return Login(email: email, password: password)
            }
            .flatMapLatest { [unowned self] (login) -> SharedSequence<DriverSharingStrategy, [User]> in
                return self.useCase.login(login: login)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
        }
        
        let success = login.filter({ (users) -> Bool in
            let count = users.count == 1
            return count
        })
            .flatMapLatest { [unowned self] (users) -> SharedSequence<DriverSharingStrategy, ()> in
                AppManager.sharedInstance().profile = Profile(user: users.first!)
                return Driver.just(self.navigator.toHome())
        }
        
        let forgotPassword = input.forgotPasswordTrigger
            .flatMapLatest{ [unowned self] in
                return Driver.just(self.navigator.toForgotPassword())
        }
        
        let signup = input.signupTrigger
            .flatMapLatest{ [unowned self] in
                return Driver.just(self.navigator.toRegister())
            }
        
        return Output(initial: initialTrigger,
                      login: login,
                      success: success,
                      forgotPassword: forgotPassword,
                      signup: signup,
                      error: errorTracker.asDriver(),
                      activityIndicator: activityIndicator.asDriver()
        )
    }
}

extension LoginViewModel {
    struct Input {
        let initialTrigger: Driver<Void>
        let loginTrigger: Driver<Bool>
        let forgotPasswordTrigger: Driver<Void>
        let signupTrigger: Driver<Void>
        
        let email: Driver<String>
        let password: Driver<String>
    }
    
    struct Output {
        let initial: Driver<Void>
        let login: Driver<[User]>
        let success: Driver<Void>
        let forgotPassword: Driver<Void>
        let signup: Driver<Void>
        let error: Driver<Error>
        let activityIndicator: Driver<Bool>
    }
}
