//
//  EditProfileNavigator.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/19/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import Domain

protocol EditProfileNavigator {
    func back()
    func toEditProfile(user: User)
}

final class DefaultEditProfileNavigator: EditProfileNavigator {
    
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
    func toEditProfile(user: User) {
        let vc = storyBoard.instantiateViewController(ofType: EditProfileViewController.self)
        vc.viewModel = EditProfileViewModel(useCase: services.makeUserUseCase(),
                                            navigator: self,
                                            user: user)
        vc.profile = UserProfile(user: user)
        navigationController.pushViewController(vc, animated: true)
    }
}
