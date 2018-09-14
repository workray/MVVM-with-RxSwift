//
//  Application.swift
//  MVVMRxSwift
//
//  Created by Mobdev125 on 2/13/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import Foundation
import Domain
import NetworkPlatform

final class Application {
    static let shared = Application()
    
    private let networkUseCaseProvider: Domain.UseCaseProvider
    
    private init() {
        self.networkUseCaseProvider = NetworkPlatform.UseCaseProvider()
    }
    
    func configureMainInterface(in window: UIWindow) {
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
        
        let authNavigationController = UINavigationController()
        authNavigationController.isNavigationBarHidden = true
        let authNavigator = DefaultLoginNavigator(services: networkUseCaseProvider,
                                                     navigationController: authNavigationController,
                                                     storyBoard: storyboard)
        
        window.rootViewController = authNavigationController
        
        authNavigator.toLogin()
    }
}

