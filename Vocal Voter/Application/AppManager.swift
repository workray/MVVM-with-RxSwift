//
//  AppManager.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/12/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import Domain

enum MyError: Error {
    case existUser
}

let SUCCESS = "success"
let FAIL = "fail"

class AppManager {
    private static var instance: AppManager?
    static func sharedInstance() -> AppManager {
        if instance == nil {
            instance = AppManager()
        }
        return instance!
    }
    
    var profile: Profile?
    
    private init() {
        self.profile = Profile()
    }
    
    public func logout() {
        self.profile = Profile()
    }
}
