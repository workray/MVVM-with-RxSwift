//
//  Result+Mapping.swift
//  NetworkPlatform
//
//  Created by Mobdev125 on 9/13/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import Domain
import ObjectMapper

extension Result: ImmutableMappable {
    
    // JSON -> Object
    public init(map: Map) throws {
        self.init(result: try map.value("result"),
                  msg: try map.value("msg"))
    }
    
    // object -> JSON
    public mutating func mapping(map: Map) {
        result    >>> map["result"]
        msg       >>> map["msg"]
    }
}
