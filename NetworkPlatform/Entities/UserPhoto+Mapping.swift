//
//  UserPhoto+Mapping.swift
//  NetworkPlatform
//
//  Created by Mobdev125 on 9/19/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import Domain
import ObjectMapper

extension UserPhoto: ImmutableMappable, Identifiable {
    
    // JSON -> Object
    public init(map: Map) throws {
        self.init(uid: try map.value("id"),
                  photoUrl: try map.value("photo_url"))
    }
    
    // object -> JSON
    public mutating func mapping(map: Map) {
        uid             >>> map["id"]
        photoUrl        >>> map["photo_url"]
    }
}
