//
//  ProfileNavigator.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/18/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import Domain
import RxSwift

protocol ProfileNavigator {
    func back()
    func toProfile()
    func toEditProfile(user: User)
    func toChangePassword(user: User)
    func toChangeVerificationPhoto(user: User)
    func toTakePhoto(_ imageSubject: PublishSubject<UIImage>)
    func logout()
}

final class DefaultProfileNavigator: ProfileNavigator {
    
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
    func toProfile() {
        let vc = storyBoard.instantiateViewController(ofType: ProfileViewController.self)
        vc.viewModel = ProfileViewModel(useCase: services.makeUserUseCase(),
                                        imageUseCase: services.makeImageUseCase(),
                                        navigator: self)
        navigationController.pushViewController(vc, animated: true)
    }
    func toEditProfile(user: User) {
        let editProfileNavigator = DefaultEditProfileNavigator(services: services, navigationController: navigationController, storyBoard: storyBoard)
        editProfileNavigator.toEditProfile(user: user)
    }
    
    func toChangePassword(user: User) {
        let changePasswordNavigator = DefaultChangePasswordNavigator(services: services, navigationController: navigationController, storyBoard: storyBoard)
        changePasswordNavigator.toChangePassword(user: user)
    }
    
    func toChangeVerificationPhoto(user: User) {
        let changeVerificationPhotoNavigator = DefaultChangeVerificationPhotoNavigator(services: services, navigationController: navigationController, storyBoard: storyBoard)
        changeVerificationPhotoNavigator.toChangeVerificationPhoto(user: user)
    }
    
    func toTakePhoto(_ imageSubject: PublishSubject<UIImage>) {
        let navigationController = UINavigationController()
        navigationController.isNavigationBarHidden = true
        navigationController.isToolbarHidden = true
        let takePhotoNavigator = DefaultTakePhotoNavigator(navigationController: navigationController, imageSubject: imageSubject, isAvatar: true)
        takePhotoNavigator.toTakePhoto()
        
        self.navigationController.present(navigationController, animated: true, completion: nil)
    }
}
