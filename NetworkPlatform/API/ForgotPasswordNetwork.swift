//
//  ForgotPasswordNetwork.swift
//  NetworkPlatform
//
//  Created by Mobdev125 on 9/13/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import Domain
import RxSwift

public final class ForgotPasswordNetwork {
    private let network: Network<Result>
    
    init(network: Network<Result>) {
        self.network = network
    }
    
    func sendEmail(params: ForgotPassword) -> Observable<Result> {
        return network.postItem("api/forgotpass", parameters: params.toJSON())
    }
    func sendVerificationCode(params: ForgotPassword) -> Observable<Result> {
        return network.postItem("api/verification_forgotpass", parameters: params.toJSON())
    }
    
    func resetPassword(params: ForgotPassword) -> Observable<Result> {
        return network.postItem("api/resetpass", parameters: params.toJSON())
    }
}
