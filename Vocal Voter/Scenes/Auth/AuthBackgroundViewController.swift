//
//  AuthViewController.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/13/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit

class AuthBackgroundViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBackground()
    }

    func setupBackground() {
        let backgroundImageView = UIImageView(frame: self.view.bounds)
        backgroundImageView.image = UIImage(named: "bg.jpg")
        self.view.insertSubview(backgroundImageView, at: 0)
        backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let visualEffectView = UIVisualEffectView(frame: self.view.bounds)
        visualEffectView.effect = UIBlurEffect(style: UIBlurEffectStyle.light)
        self.view.insertSubview(visualEffectView, at: 1)
        visualEffectView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

}
