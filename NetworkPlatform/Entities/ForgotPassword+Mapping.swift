//
//  ForgotPassword+Mapping.swift
//  NetworkPlatform
//
//  Created by Mobdev125 on 9/13/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import Domain
import ObjectMapper

extension ForgotPassword: ImmutableMappable {
    
    // JSON -> Object
    public init(map: Map) throws {
        self.init(email: try map.value("email"),
                  verificationCode: try map.value("verification_code"),
                  newPassword: try map.value("new_password"))
    }
    
    // object -> JSON
    public mutating func mapping(map: Map) {
        email               >>> map["email"]
        verificationCode    >>> map["verification_code"]
        newPassword         >>> map["new_password"]
    }
}

