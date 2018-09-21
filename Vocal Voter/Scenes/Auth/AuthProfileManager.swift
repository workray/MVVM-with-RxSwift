//
//  AuthProfileManager.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/21/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import Domain
import RxSwift
import RxCocoa

class AuthProfileManager {

    private static var instance: AuthProfileManager?
    private let profileSubject: PublishSubject<Profile>
    private let disposeBag = DisposeBag()
    
    var profile: Profile = Profile()
    
    var profileBinding: Binder<Profile> {
        return Binder(self, binding: { (manager, profile) in
            manager.profile = profile
        })
    }
    static func sharedInstance() -> AuthProfileManager {
        if instance == nil {
            instance = AuthProfileManager()
        }
        return instance!
    }
    
    private init() {
        profileSubject = PublishSubject<Profile>.init()
        
        profileSubject.asDriverOnErrorJustComplete().drive(profileBinding).disposed(by: disposeBag)
    }
    
    public static func loggedIn() {
        AuthProfileManager.sharedInstance().profile.clear()
    }
    
    public static func getProfile() -> Profile {
        return AuthProfileManager.sharedInstance().profile
    }
    
    public static func getProfilePublishSubject() -> PublishSubject<Profile> {
        return AuthProfileManager.sharedInstance().profileSubject
    }
}
