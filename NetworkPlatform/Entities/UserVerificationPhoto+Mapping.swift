//
//  UserVerificationPhoto+Mapping.swift
//  NetworkPlatform
//
//  Created by Mobdev125 on 9/19/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import Domain
import ObjectMapper

extension UserVerificationPhoto: ImmutableMappable, Identifiable {
    
    // JSON -> Object
    public init(map: Map) throws {
        self.init(uid: try map.value("id"),
                  verificationPhotoUrl: try map.value("verification_url"))
    }
    
    // object -> JSON
    public mutating func mapping(map: Map) {
        uid                     >>> map["id"]
        verificationPhotoUrl    >>> map["verification_url"]
    }
}
