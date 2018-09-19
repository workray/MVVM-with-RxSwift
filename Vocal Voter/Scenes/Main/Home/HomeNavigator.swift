//
//  HomeNavigator.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/12/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import Domain

protocol HomeNavigator {
    func toLogin()
    func toHome()
    func toProfile()
}

final class DefaultHomeNavigator: HomeNavigator {
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
    
    func toHome() {
        let vc = storyBoard.instantiateViewController(ofType: HomeViewController.self)
        vc.viewModel = HomeViewModel(useCase: services.makeUserUseCase(),
                                      navigator: self)
        navigationController.pushViewController(vc, animated: true)
    }
    func toLogin() {
        AppManager.sharedInstance().logout()
        navigationController.dismiss(animated: true, completion: nil)
    }
    
    func toProfile() {
        let navigator = DefaultProfileNavigator(services: services, navigationController: navigationController, storyBoard: storyBoard)
        navigator.toProfile()
    }
}


