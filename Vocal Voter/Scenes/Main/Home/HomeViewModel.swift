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
        let logout = input.logoutTrigger
            .do(onNext: navigator.toLogin)
        return Output(logout: logout)
    }
}

extension HomeViewModel {
    struct Input {
        let logoutTrigger: Driver<Void>
    }
    
    struct Output {
        let logout: Driver<Void>
    }
}
