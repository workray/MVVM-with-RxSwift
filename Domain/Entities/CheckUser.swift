//
//  CheckUser.swift
//  Domain
//
//  Created by Mobdev125 on 9/13/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

public struct CheckUser {
    public let email: String
    public let phone: String
    
    public init(email: String, phone: String) {
        self.email = email
        self.phone = phone
    }
}
