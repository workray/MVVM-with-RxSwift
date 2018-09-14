//
//  ForgotPassword.swift
//  Domain
//
//  Created by Mobdev125 on 9/13/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

public struct ForgotPassword {
    public let email: String
    public let verificationCode: String
    public let newPassword: String
    
    public init() {
        self.init(email: "", verificationCode: "", newPassword: "")
    }
    
    public init(email: String) {
        self.init(email: email, verificationCode: "", newPassword: "")
    }
    
    public init(email: String, verificationCode: String) {
        self.init(email: email, verificationCode: verificationCode, newPassword: "")
    }
    
    public init(email: String, verificationCode: String, newPassword: String) {
        self.email = email
        self.verificationCode = verificationCode
        self.newPassword = newPassword
    }
}

