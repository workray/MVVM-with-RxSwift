//
//  UserUseCase.swift
//  Domain
//
//  Created by Mobdev125 on 9/4/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import RxSwift

public protocol UserUseCase {
    func login(login: Login) -> Observable<[User]>
    func checkUser(user: CheckUser) -> Observable<[User]>
    func user(userId: String) -> Observable<User>
    func register(user: User) -> Observable<User>
    func delete(user: User) -> Observable<Void>
    func update(user: User) -> Observable<User>
}
