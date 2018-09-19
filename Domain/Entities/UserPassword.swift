//
//  UserPassword.swift
//  Domain
//
//  Created by Mobdev125 on 9/19/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

public struct UserPassword {
    public let uid: String
    public let password: String
    
    public init(uid: String,
                password: String) {
        self.uid = uid
        self.password = password
    }
}
