//
//  User.swift
//  Domain
//
//  Created by Mobdev125 on 9/4/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

public struct User {
    public let uid: String
    public let firstName: String
    public let lastName: String
    public let username: String
    public let email: String
    public let password: String
    public let phone: String
    public let zipcode: String
    public let photoUrl: String
    public let verificationUrl: String
    public let verified: Bool
    
    public init() {
        self.init(uid: UUID.init().uuidString,
                  firstname: "",
                  lastname: "",
                  email: "",
                  password: "",
                  phone: "",
                  zipcode: "",
                  photoUrl: "",
                  verificationUrl: "",
                  verified: false)
    }
    
    public init(uid: String,
                firstname: String,
                lastname: String,
                email: String,
                password: String,
                phone: String,
                zipcode: String,
                photoUrl: String,
                verificationUrl: String,
                verified: Bool) {
        self.uid = uid
        self.firstName = firstname
        self.lastName = lastname
        self.username = "\(firstname) \(lastname)"
        self.email = email
        self.password = password
        self.phone = phone
        self.zipcode = zipcode
        self.photoUrl = photoUrl
        self.verificationUrl = verificationUrl
        self.verified = verified
    }
    
    public init(firstname: String,
                lastname: String,
                email: String,
                password: String,
                phone: String,
                zipcode: String) {
        self.init(uid: NSUUID().uuidString,
                  firstname: firstname,
                  lastname: lastname,
                  email: email,
                  password: password,
                  phone: phone,
                  zipcode: zipcode,
                  photoUrl: "",
                  verificationUrl: "",
                  verified: false)
    }
    
    public init(firstname: String,
                lastname: String,
                email: String,
                password: String,
                phone: String,
                zipcode: String,
                photoUrl: String,
                verificationUrl: String) {
        self.init(uid: NSUUID().uuidString,
                  firstname: firstname,
                  lastname: lastname,
                  email: email,
                  password: password,
                  phone: phone,
                  zipcode: zipcode,
                  photoUrl: photoUrl,
                  verificationUrl: verificationUrl,
                  verified: false)
    }
}

extension User: Equatable {
    public static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uid == rhs.uid &&
            lhs.firstName == rhs.firstName &&
            lhs.lastName == rhs.lastName &&
            lhs.email == rhs.email &&
            lhs.password == rhs.password &&
            lhs.phone == rhs.phone &&
            lhs.zipcode == rhs.zipcode &&
            lhs.photoUrl == rhs.photoUrl &&
            lhs.verificationUrl == rhs.verificationUrl &&
            lhs.verified == rhs.verified
    }
}
