//
//  Result.swift
//  Domain
//
//  Created by Mobdev125 on 9/13/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

public struct Result {
    public let result: String
    public let msg: String
    
    public init(result: String, msg: String) {
        self.result = result
        self.msg = msg
    }
}

