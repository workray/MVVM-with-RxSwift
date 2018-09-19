//
//  ChangeVerificationPhotoNavigator.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/19/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import Domain
import RxSwift

protocol ChangeVerificationPhotoNavigator {
    func back()
    func toChangeVerificationPhoto(user: User)
    func toTakePhoto(_ imageSubject: PublishSubject<UIImage>)
}

final class DefaultChangeVerificationPhotoNavigator: ChangeVerificationPhotoNavigator {
    
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
    func logout() {
        navigationController.dismiss(animated: true, completion: nil)
    }
    func toChangeVerificationPhoto(user: User) {
        let vc = storyBoard.instantiateViewController(ofType: ChangeVerificationPhotoViewController.self)
        vc.viewModel = ChangeVerificationPhotoViewModel(useCase: services.makeUserUseCase(),
                                                        imageUseCase: services.makeImageUseCase(),
                                                        navigator: self,
                                                        user: user)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func toTakePhoto(_ imageSubject: PublishSubject<UIImage>) {
        let navigationController = UINavigationController()
        navigationController.isNavigationBarHidden = true
        navigationController.isToolbarHidden = true
        let takePhotoNavigator = DefaultTakePhotoNavigator(navigationController: navigationController, imageSubject: imageSubject, isAvatar: false)
        takePhotoNavigator.toTakePhoto()
        
        self.navigationController.present(navigationController, animated: true, completion: nil)
    }
}
