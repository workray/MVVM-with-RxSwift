//
//  VerificationPhotoNavigator.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/7/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import Domain
import RxSwift

protocol VerificationPhotoNavigator {
    func back()
    func toVerificationPhoto()
    func toTakePhoto(_ imageSubject: PublishSubject<UIImage>, animated: Bool)
    func toHome()
}

final class DefaultVerificationPhotoNavigator: VerificationPhotoNavigator {
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
    
    func toVerificationPhoto() {
        let viewModel = VerificationPhotoViewModel(userUseCase: services.makeUserUseCase(), imageUseCase: services.makeImageUseCase(), navigator: self)
        let vc = storyBoard.instantiateViewController(ofType: VerificationPhotoViewController.self)
        vc.viewModel = viewModel
        navigationController.pushViewController(vc, animated: true)
    }
    
    func toTakePhoto(_ imageSubject: PublishSubject<UIImage>, animated: Bool) {
        let navigationController = UINavigationController()
        navigationController.isNavigationBarHidden = true
        navigationController.isToolbarHidden = true
        let takePhotoNavigator = DefaultTakePhotoNavigator(navigationController: navigationController, imageSubject: imageSubject, isAvatar: false)
        takePhotoNavigator.toTakePhoto()
        
        self.navigationController.present(navigationController, animated: animated, completion: nil)
    }
    
    func back() {
        navigationController.popViewController(animated: true)
    }
    
    func toHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let mainNavigationController = UINavigationController()
        let homeNavigator = DefaultHomeNavigator(services: services,
                                                 navigationController: mainNavigationController,
                                                  storyBoard: storyboard)
        homeNavigator.toHome()
        
        self.navigationController.present(mainNavigationController, animated: true) { [unowned self] in
            self.navigationController.popToRootViewController(animated: false)
        }
    }
}
