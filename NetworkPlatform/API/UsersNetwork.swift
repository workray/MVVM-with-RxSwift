//
//  UsersNetwork.swift
//  NetworkPlatform
//
//  Created by Mobdev125 on 2/13/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import Domain
import RxSwift

public final class UsersNetwork {
    private let network: Network<User>
    private let tableName: String
    
    init(network: Network<User>) {
        self.network = network
        self.tableName = "user_tb"
    }
    
    public func fetchUsers() -> Observable<[User]> {
        return network.getItems(tableName)
    }
    
    public func getUser(userId: String) -> Observable<User> {
        return network.getItemWithTable(tableName, itemId: userId)
    }
    
    public func getUsers(query: NSPredicate) -> Observable<[User]> {
        return network.getItemsWithTable(tableName, query: query)
    }
    
    public func registerUser(user: User) -> Observable<User> {
        return network.postItemWithTable(tableName, item: user.toJSON())
    }
    
    public func updateUser(user: [String: Any]) -> Observable<User> {
        return network.updateItemWithTable(tableName, item: user)
    }
    
    public func deleteUser(user: User) -> Observable<Void> {
        return network.deleteItemWithTable(tableName, itemId: user.uid)
    }
}
