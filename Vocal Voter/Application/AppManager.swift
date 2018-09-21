//
//  AppManager.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/12/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import Domain
import RxSwift
import RxCocoa

enum MyError: Error {
    case existUser
}

let SUCCESS = "success"
let FAIL = "fail"

class AppManager {
    
    private static var instance: AppManager?
    private let userSubject: PublishSubject<User>
    private let disposeBag = DisposeBag()
    
    var user: User = User()
    
    var userBinding: Binder<User> {
        return Binder(self, binding: { (manager, user) in
            manager.user = user
        })
    }
    static func sharedInstance() -> AppManager {
        if instance == nil {
            instance = AppManager()
        }
        return instance!
    }
    
    private init() {
        userSubject = PublishSubject<User>.init()
        
        userSubject.asDriverOnErrorJustComplete().drive(userBinding).disposed(by: disposeBag)
    }
    
    public static func loggedOut() {
        AppManager.getUserPublishSubject().onNext(User())
    }
    
    public static func getCurrentUser() -> User {
        return AppManager.sharedInstance().user
    }
    
    public static func setCurrentUser(user: User) {
        AppManager.sharedInstance().user = user
    }
    
    public static func getUserId() -> String {
        return AppManager.sharedInstance().user.uid
    }
    
    public static func getUserPublishSubject() -> PublishSubject<User> {
        return AppManager.sharedInstance().userSubject
    }
}
