//
//  VerificationCodeNavigator.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/13/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import Domain

protocol VerificationCodeNavigator {
    func toVerificationCode(param: ForgotPassword)
    func back()
    func toResetPassword(param: ForgotPassword)
}

final class DefaultVerificationCodeNavigator: VerificationCodeNavigator {
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
    
    func toVerificationCode(param: ForgotPassword) {
        let viewModel = VerificationCodeViewModel(useCase: services.makeForgotPasswordUseCase(), navigator: self, param: param)
        let vc = storyBoard.instantiateViewController(ofType: VerificationCodeViewController.self)
        vc.viewModel = viewModel
        navigationController.pushViewController(vc, animated: true)
    }
    
    func toResetPassword(param: ForgotPassword) {
        let navigator = DefaultResetPasswordNavigator(services: services, navigationController: navigationController, storyBoard: storyBoard)
        navigator.toResetPassword(param: param)
    }
}

