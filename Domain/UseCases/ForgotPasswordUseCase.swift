//
//  ForgotPasswordUseCase.swift
//  Domain
//
//  Created by Mobdev125 on 9/13/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import RxSwift

public protocol ForgotPasswordUseCase {
    func sendEmail(params: ForgotPassword) -> Observable<Result>
    func sendVerificationCode(params: ForgotPassword) -> Observable<Result>
    func resetPassword(params: ForgotPassword) -> Observable<Result>
}
