//
//  ForgotPasswordUseCase.swift
//  NetworkPlatform
//
//  Created by Mobdev125 on 9/13/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import Foundation
import Domain
import RxSwift

final class ForgotPasswordUseCase: Domain.ForgotPasswordUseCase {
    private let network: ForgotPasswordNetwork
    
    init(network: ForgotPasswordNetwork) {
        self.network = network
    }
   
    func sendEmail(params: ForgotPassword) -> Observable<Result> {
        return network.sendEmail(params: params)
    }
    func sendVerificationCode(params: ForgotPassword) -> Observable<Result> {
        return network.sendVerificationCode(params: params)
    }
    func resetPassword(params: ForgotPassword) -> Observable<Result> {
        return network.resetPassword(params: params)
    }
}
