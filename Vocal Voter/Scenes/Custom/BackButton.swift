//
//  BackButton.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/7/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import Material

class BackButton: RaisedButton {
    override func prepare() {
        super.prepare()
        self.backgroundColor = UIColor.clear
        self.image = Icon.cm.arrowBack?.tint(with: UIColor.white)
    }
}
