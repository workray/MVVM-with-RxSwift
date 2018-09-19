//
//  UserPassword+Mapping.swift
//  NetworkPlatform
//
//  Created by Mobdev125 on 9/19/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import Domain
import ObjectMapper

extension UserPassword: ImmutableMappable, Identifiable {
    
    // JSON -> Object
    public init(map: Map) throws {
        self.init(uid: try map.value("id"),
                  password: try map.value("password"))
    }
    
    // object -> JSON
    public mutating func mapping(map: Map) {
        uid             >>> map["id"]
        password        >>> map["password"]
    }
}
