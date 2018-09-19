//
//  UserPhoto.swift
//  Domain
//
//  Created by Mobdev125 on 9/19/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

public struct UserPhoto {
    public let uid: String
    public let photoUrl: String
    
    public init(uid: String,
                photoUrl: String) {
        self.uid = uid
        self.photoUrl = photoUrl
    }
}
