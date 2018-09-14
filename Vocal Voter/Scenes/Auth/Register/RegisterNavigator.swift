//
//  RegisterNavigator.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/6/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import Domain
import RxSwift

protocol RegisterNavigator {
    func toRegister()
    func back()
    func toContinue()
    func toTakePhoto(_ imageSubject: PublishSubject<UIImage>)
}

final class DefaultRegisterNavigator: RegisterNavigator {
    private let navigationController: UINavigationController
    private let services: UseCaseProvider
    private let storyBoard: UIStoryboard
    
    init(services: UseCaseProvider,
         navigationController: UINavigationController,
         storyBoard: UIStoryboard) {
        self.services = services
        self.navigationController = navigationController
        self.storyBoard = storyBoard
    }
    
    func toRegister() {
        let viewModel = RegisterViewModel(useCase: services.makeUserUseCase(), navigator: self)
        let vc = storyBoard.instantiateViewController(ofType: RegisterViewController.self)
        vc.viewModel = viewModel
        navigationController.pushViewController(vc, animated: true)
    }
    
    func back() {
        navigationController.popToRootViewController(animated: true)
    }
    
    func toContinue() {
        let verificationPhotoNavigator = DefaultVerificationPhotoNavigator(services: services, navigationController: navigationController, storyBoard: storyBoard)
        verificationPhotoNavigator.toVerificationPhoto()
    }
    
    func toTakePhoto(_ imageSubject: PublishSubject<UIImage>) {
        let navigationController = UINavigationController()
        navigationController.isNavigationBarHidden = true
        navigationController.isToolbarHidden = true
        let takePhotoNavigator = DefaultTakePhotoNavigator(navigationController: navigationController, imageSubject: imageSubject)
        takePhotoNavigator.toTakePhoto()
        
        self.navigationController.present(navigationController, animated: true, completion: nil)
    }
}
