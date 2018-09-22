//
//  TextField+Extension.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/6/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import Material
import PhoneNumberKit

enum VocalVoterTextFieldType {
    case email
    case password
    case name
    case zipcode
    case phone
    case none
}

class VocalVoterTextField: ErrorTextField {
    
    var type: VocalVoterTextFieldType = .none
    var isRequired: Bool = true
    
    var isValid: Bool {
        checkValid()
        return !self.isErrorRevealed
    }
    var activeColor:UIColor {
        return Color.purple.base
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepare() {
        super.prepare()
        leftViewOffset = 2
        dividerActiveColor = activeColor
        placeholderActiveColor = activeColor
        leftViewActiveColor = activeColor
        errorColor = Color.deepPurple.base
        
        isPlaceholderUppercasedWhenEditing = true
        errorLabel.textAlignment = .right
    }
    
    func checkValid() {
        if (self.text?.isEmpty)! {
            if !isRequired {
                handleError(nil)
                return
            }
            else {
                handleError("required field")
                return
            }
        }
        switch type {
        case .email:
            checkValidEmail("Incorrect email")
        case .password:
            checkValidPassword("At least 6 characters")
        case .phone:
            checkValidPhoneNumber("Invalid phone number")
        case .zipcode:
            checkValidZipcode("Invalid zipcode")
        case .name: break
        case .none: break
        }
    }
    
    func handleError(_ errorString: String?) {
        if let errorString = errorString {
            self.error = errorString
            self.isErrorRevealed = true
        }
        else {
            self.isErrorRevealed = false
        }
    }
    
    func checkValidEmail(_ errorString: String) {
        let emailRegEx = "(?:[a-zA-Z0-9!#$%\\&‘*+/=?\\^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%\\&'*+/=?\\^_`{|}" +
        "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
        "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-" +
        "z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5" +
        "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
        "9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
        "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        if emailTest.evaluate(with: self.text) {
            handleError(nil)
        }
        else {
            handleError(errorString)
        }
    }
    
    func checkValidPassword(_ errorString: String) {
        if (self.text?.count)! >= 6 {
            handleError(nil)
        }
        else {
            handleError(errorString)
        }
    }
    
    func checkValidPhoneNumber(_ errorString: String) {
        let phoneNumberKit = PhoneNumberKit()
        do {
            _ = try phoneNumberKit.parse(self.text!)
            handleError(nil)
        }
        catch {
            handleError(errorString)
        }
    }
    
    func checkValidZipcode(_ errorString: String) {
        let test = NSPredicate(format: "SELF MATCHES %@", "\\d{5}")
        if test.evaluate(with: self.text!) {
            handleError(nil)
        }
        else {
            handleError(errorString)
        }
    }
}
