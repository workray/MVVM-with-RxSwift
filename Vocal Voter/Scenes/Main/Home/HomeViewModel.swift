//
//  HomeViewModel.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/12/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import Domain
import RxSwift
import RxCocoa

final class HomeViewModel: ViewModelType {
    
    private let useCase: UserUseCase
    private let navigator: HomeNavigator
    
    init(useCase: UserUseCase, navigator: HomeNavigator) {
        self.navigator = navigator
        self.useCase = useCase
    }
    
    func transform(input: Input) -> Output {
        let profile = input.profileTrigger
            .do(onNext: navigator.toProfile)
        let logout = input.logoutTrigger
            .do(onNext: {[unowned self] () in
                AppManager.loggedOut()
                self.navigator.toLogin()
            })
        return Output(
            profile: profile,
            logout: logout)
    }
}

extension HomeViewModel {
    struct Input {
        let profileTrigger: Driver<Void>
        let logoutTrigger: Driver<Void>
    }
    
    struct Output {
        let profile: Driver<Void>
        let logout: Driver<Void>
    }
}
