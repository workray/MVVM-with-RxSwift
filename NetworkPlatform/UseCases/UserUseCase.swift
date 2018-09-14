//
//  PostsUseCase.swift
//  NetworkPlatform
//
//  Created by Mobdev125 on 2/13/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import Foundation
import Domain
import RxSwift

final class UserUseCase<Cache>: Domain.UserUseCase where Cache: AbstractCache, Cache.T == User {
       
    private let network: UsersNetwork
    private let cache: Cache
    
    init(network: UsersNetwork, cache: Cache) {
        self.network = network
        self.cache = cache
    }
    func login(login: Login) -> Observable<[User]> {
        return network.getUsers(query: NSPredicate(format: "email == %@ AND password == %@", argumentArray: [login.email, login.password]))
    }
    
    func checkUser(user: CheckUser) -> Observable<[User]> {
        return network.getUsers(query: NSPredicate(format: "email == %@ OR phone == %@", argumentArray: [user.email, user.phone]))
    }
    
    func user(userId: String) -> Observable<User> {
        return network.getUser(userId: userId)
    }
    
    func register(user: User) -> Observable<User> {
        return network.registerUser(user: user)
    }
    
    func delete(user: User) -> Observable<Void> {
        return network.deleteUser(user: user).map({_ in})
    }
    
    func update(user: User) -> Observable<User> {
        return network.updateUser(user: user)
    }
}
