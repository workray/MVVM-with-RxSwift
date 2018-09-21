//
//  Profile.swift
//  Domain
//
//  Created by Mobdev125 on 9/7/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

public struct Profile {
    public var user: User
    public var userPhoto: UIImage?
    public var verificationPhoto: UIImage?
    
    public init() {
        self.init(user: User())
    }
    
    public init(user: User) {
        self.init(user: user, userPhoto: nil, verificationPhoto: nil)
    }
    
    public init(user: User, userPhoto: UIImage?) {
        self.init(user: user, userPhoto: userPhoto, verificationPhoto: nil)
    }
    
    public init(user: User, userPhoto: UIImage?, verificationPhoto: UIImage?) {
        self.user = user
        self.userPhoto = userPhoto
        self.verificationPhoto = verificationPhoto
    }
    
    public mutating func clear() {
        self.user = User()
        self.userPhoto = nil
        self.verificationPhoto = nil
    }
}
