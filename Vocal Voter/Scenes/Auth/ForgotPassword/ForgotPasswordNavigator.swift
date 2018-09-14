//
//  ForgotPasswordNavigator.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/6/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import Domain

protocol ForgotPasswordNavigator {
    func toForgotPassword()
    func toLogin()
    func toRegister()
    func toVerificationCode(params: ForgotPassword)
}

final class DefaultForgotPasswordNavigator: ForgotPasswordNavigator {
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
    
    func toLogin() {
        navigationController.popViewController(animated: true)
    }
    
    func toForgotPassword() {
        let viewModel = ForgotPasswordViewModel(useCase: services.makeForgotPasswordUseCase(), navigator: self)
        let vc = storyBoard.instantiateViewController(ofType: ForgotPasswordViewController.self)
        vc.viewModel = viewModel
        navigationController.pushViewController(vc, animated: true)
    }
    
    func toRegister() {
        let navigator = DefaultRegisterNavigator(services: services, navigationController: navigationController, storyBoard: storyBoard)
        navigator.toRegister()
    }
    
    func toVerificationCode(params: ForgotPassword) {
        let navigator = DefaultVerificationCodeNavigator(services: services, navigationController: navigationController, storyBoard: storyBoard)
        navigator.toVerificationCode(param: params)
    }
}

