//
//  User+Mapping.swift
//  NetworkPlatform
//
//  Created by Mobdev125 on 2/13/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import Domain
import ObjectMapper

extension User: ImmutableMappable, Identifiable {
    
    // JSON -> Object
    public init(map: Map) throws {
        self.init(uid: try map.value("id"),
                  firstname: try map.value("first_name"),
                  lastname: try map.value("last_name"),
                  email: try map.value("email"),
                  password: try map.value("password"),
                  phone: try map.value("phone"),
                  zipcode: try map.value("zipcode"),
                  photoUrl: try map.value("photo_url"),
                  verificationUrl: try map.value("verification_url"),
                  verified: try map.value("verified"))
    }
    
    // object -> JSON
    public mutating func mapping(map: Map) {
        uid             >>> map["id"]
        firstName       >>> map["first_name"]
        lastName        >>> map["last_name"]
        email           >>> map["email"]
        password        >>> map["password"]
        phone           >>> map["phone"]
        zipcode         >>> map["zipcode"]
        photoUrl        >>> map["photo_url"]
        verificationUrl >>> map["verification_url"]
        verified        >>> map["verified"]
    }
}

extension User: Encodable {
    var encoder: NETUser {
        return NETUser(with: self)
    }
}

final class NETUser: NSObject, NSCoding, DomainConvertibleType {
    struct Keys {
        static let uid = "uid"
        static let firstName = "first_name"
        static let lastName = "last_name"
        static let email = "email"
        static let password = "password"
        static let phone = "phone"
        static let zipcode = "zipcode"
        static let photoUrl = "photo_url"
        static let verificationUrl = "verification_url"
        static let verified = "verified"
    }
    let uid: String
    let firstName: String
    let lastName: String
    let email: String
    let password: String
    let phone: String
    let zipcode: String
    let photoUrl: String
    let verificationUrl: String
    let verified: Bool
    
    init(with domain: User) {
        self.uid = domain.uid
        self.firstName = domain.firstName
        self.lastName = domain.lastName
        self.email = domain.email
        self.password = domain.password
        self.phone = domain.phone
        self.zipcode = domain.zipcode
        self.photoUrl = domain.photoUrl
        self.verificationUrl = domain.verificationUrl
        self.verified = domain.verified
    }
    
    init?(coder aDecoder: NSCoder) {
        guard
            let uid = aDecoder.decodeObject(forKey: Keys.uid) as? String,
            let firstName = aDecoder.decodeObject(forKey: Keys.firstName) as? String,
            let lastName = aDecoder.decodeObject(forKey: Keys.lastName) as? String,
            let email = aDecoder.decodeObject(forKey: Keys.email) as? String,
            let password = aDecoder.decodeObject(forKey: Keys.password) as? String,
            let phone = aDecoder.decodeObject(forKey: Keys.phone) as? String,
            let zipcode = aDecoder.decodeObject(forKey: Keys.zipcode) as? String,
            let photoUrl = aDecoder.decodeObject(forKey: Keys.photoUrl) as? String,
            let verificationUrl = aDecoder.decodeObject(forKey: Keys.verificationUrl) as? String,
            let verified = aDecoder.decodeObject(forKey: Keys.verified) as? Bool
            else {
                return nil
        }
        self.uid = uid
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.password = password
        self.phone = phone
        self.zipcode = zipcode
        self.photoUrl = photoUrl
        self.verificationUrl = verificationUrl
        self.verified = verified
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(uid, forKey: Keys.uid)
        aCoder.encode(firstName, forKey: Keys.firstName)
        aCoder.encode(lastName, forKey: Keys.lastName)
        aCoder.encode(email, forKey: Keys.email)
        aCoder.encode(password, forKey: Keys.password)
        aCoder.encode(phone, forKey: Keys.phone)
        aCoder.encode(zipcode, forKey: Keys.zipcode)
        aCoder.encode(photoUrl, forKey: Keys.photoUrl)
        aCoder.encode(verificationUrl, forKey: Keys.verificationUrl)
        aCoder.encode(verified, forKey: Keys.verified)
    }
    
    func asDomain() -> User {
        return User(uid: uid,
                    firstname: firstName,
                    lastname: lastName,
                    email: email,
                    password: password,
                    phone: phone,
                    zipcode: zipcode,
                    photoUrl: photoUrl,
                    verificationUrl: verificationUrl,
                    verified: verified)
    }
}
