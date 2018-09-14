//
//  VerificationCodeTextField.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/14/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class VerificationCodeTextField: UITextField {

    override func deleteBackward() {
        self.text = ""
        if IQKeyboardManager.shared.canGoPrevious {
            IQKeyboardManager.shared.goPrevious()
        }
    }

}
