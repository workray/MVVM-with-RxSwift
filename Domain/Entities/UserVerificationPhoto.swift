//
//  UserVerificationPhoto.swift
//  Domain
//
//  Created by Mobdev125 on 9/19/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

public struct UserVerificationPhoto {
    public let uid: String
    public let verificationPhotoUrl: String
    
    public init(uid: String,
                verificationPhotoUrl: String) {
        self.uid = uid
        self.verificationPhotoUrl = verificationPhotoUrl
    }
}
