//
//  EditProfile.swift
//  Domain
//
//  Created by Mobdev125 on 9/19/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

public struct UserProfile {
    public let uid: String
    public let firstName: String
    public let lastName: String
    public let email: String
    public let phone: String
    public let zipcode: String
    
    public init(uid: String,
                firstname: String,
                lastname: String,
                email: String,
                phone: String,
                zipcode: String) {
        self.uid = uid
        self.firstName = firstname
        self.lastName = lastname
        self.email = email
        self.phone = phone
        self.zipcode = zipcode
    }
    
    public init(user: User) {
        self.init(uid: user.uid,
                  firstname: user.firstName,
                  lastname: user.lastName,
                  email: user.email,
                  phone: user.phone,
                  zipcode: user.zipcode)
    }
}

extension UserProfile: Equatable {
    public static func == (lhs: UserProfile, rhs: UserProfile) -> Bool {
        return lhs.uid == rhs.uid &&
            lhs.firstName == rhs.firstName &&
            lhs.lastName == rhs.lastName &&
            lhs.email == rhs.email &&
            lhs.phone == rhs.phone &&
            lhs.zipcode == rhs.zipcode
    }
}
