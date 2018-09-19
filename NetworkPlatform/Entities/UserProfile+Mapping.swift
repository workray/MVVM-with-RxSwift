//
//  UserProfile+Mapping.swift
//  NetworkPlatform
//
//  Created by Mobdev125 on 9/19/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import Domain
import ObjectMapper

extension UserProfile: ImmutableMappable, Identifiable {
    
    // JSON -> Object
    public init(map: Map) throws {
        self.init(uid: try map.value("id"),
                  firstname: try map.value("first_name"),
                  lastname: try map.value("last_name"),
                  email: try map.value("email"),
                  phone: try map.value("phone"),
                  zipcode: try map.value("zipcode"))
    }
    
    // object -> JSON
    public mutating func mapping(map: Map) {
        uid             >>> map["id"]
        firstName       >>> map["first_name"]
        lastName        >>> map["last_name"]
        email           >>> map["email"]
        phone           >>> map["phone"]
        zipcode         >>> map["zipcode"]
    }
}
