//
//  UseCaseProvider.swift
//  NetworkPlatform
//
//  Created by Mobdev125 on 2/13/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import Foundation
import Domain
import RxSwift

public final class UseCaseProvider: Domain.UseCaseProvider {
    
    private let networkProvider: NetworkProvider
    
    public init() {
        networkProvider = NetworkProvider()
    }
    
    public func makeUserUseCase() -> Domain.UserUseCase {
        return UserUseCase(network: networkProvider.makeUsersNetwork(),
                            cache: Cache<User>(path: "users"))
    }
    public func makeImageUseCase() -> Domain.ImageUseCase {
        return ImageUseCase(blob: networkProvider.makeImageNetwork())
    }
    
    public func makeForgotPasswordUseCase() -> Domain.ForgotPasswordUseCase {
        return ForgotPasswordUseCase(network: networkProvider.makeForgotPasswordNetwork())
    }
}

struct MapFromNever: Error {}
extension ObservableType where E == Never {
    func map<T>(to: T.Type) -> Observable<T> {
        return self.flatMap { _ in
            return Observable<T>.error(MapFromNever())
        }
    }
}
