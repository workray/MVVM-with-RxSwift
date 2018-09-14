//
//  ResetPasswordNavigator.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/13/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import Domain

protocol ResetPasswordNavigator {
    func toResetPassword(param: ForgotPassword)
    func back()
    func toLogin()
}

final class DefaultResetPasswordNavigator: ResetPasswordNavigator {
    private let navigationController: UINavigationController
    private let services: UseCaseProvider
    private let storyBoard: UIStoryboard
    
    init(services: UseCaseProvider,
         navigationController: UINavigationController,
         storyBoard: UIStoryboard) {
        self.storyBoard = storyBoard
        self.services = services
        self.navigationController = navigationController
    }
    
    func back() {
        navigationController.popViewController(animated: true)
    }
    
    func toResetPassword(param: ForgotPassword) {
        let viewModel = ResetPasswordViewModel(useCase: services.makeForgotPasswordUseCase(), navigator: self, param: param)
        let vc = storyBoard.instantiateViewController(ofType: ResetPasswordViewController.self)
        vc.viewModel = viewModel
        navigationController.pushViewController(vc, animated: true)
    }
    
    func toLogin() {
        navigationController.popToRootViewController(animated: true)
    }
}

