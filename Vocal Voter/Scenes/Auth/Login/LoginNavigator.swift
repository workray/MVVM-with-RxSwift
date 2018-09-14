//
//  MainNavigator.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/5/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import Domain

protocol LoginNavigator {
    func toLogin()
    func toRegister()
    func toForgotPassword()
    func toHome()
}

final class DefaultLoginNavigator: LoginNavigator {
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
    
    func toLogin() {
        let vc = storyBoard.instantiateViewController(ofType: LoginViewController.self)
        vc.viewModel = LoginViewModel(useCase: services.makeUserUseCase(),
                                      navigator: self)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func toRegister() {
        let navigator = DefaultRegisterNavigator(services: services, navigationController: navigationController, storyBoard: storyBoard)
        navigator.toRegister()
    }
    
    func toForgotPassword() {
        let navigator = DefaultForgotPasswordNavigator(services: services, navigationController: navigationController, storyBoard: storyBoard)
        navigator.toForgotPassword()
    }
    
    func toHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let mainNavigationController = UINavigationController()
        let homeNavigator = DefaultHomeNavigator(services: services,
                                                 navigationController: mainNavigationController,
                                                 storyBoard: storyboard)
        homeNavigator.toHome()
        
        self.navigationController.present(mainNavigationController, animated: true, completion: nil)
    }
}
