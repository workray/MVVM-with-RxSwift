//
//  ChangePasswordNavigator.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/19/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import Domain

protocol ChangePasswordNavigator {
    func back()
    func toChangePassword(user: User)
}

final class DefaultChangePasswordNavigator: ChangePasswordNavigator {
    
    private let storyBoard: UIStoryboard
    private let navigationController: UINavigationController
    private let services: UseCaseProvider
    
    init(services: UseCaseProvider,
         navigationController: UINavigationController,
         storyBoard: UIStoryboard) {
        self.services = services
        self.navigationController = navigationController
        self.storyBoard = storyBoard
    }
    
    func back() {
        navigationController.popViewController(animated: true)
    }
    func toChangePassword(user: User) {
        let vc = storyBoard.instantiateViewController(ofType: ChangePasswordViewController.self)
        vc.viewModel = ChangePasswordViewModel(useCase: services.makeUserUseCase(),
                                            navigator: self,
                                            user: user)
        navigationController.pushViewController(vc, animated: true)
    }
}
