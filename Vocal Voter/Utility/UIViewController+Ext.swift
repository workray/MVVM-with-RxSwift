//
//  UIViewController+Extension.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/6/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import SwiftMessages
import Material
import JGProgressHUD

let kErrorMsgTitle = "Error"
let kWarningMsgTitle = "Warning"
let kInfoMsgTitle = "Notice"

extension UIViewController {

    func showErrorMsg(_ errorString: String) {
        showMessage(kErrorMsgTitle, errorString, Theme.error)
    }
    
    func showWarningMessage(_ warningString: String) {
        showMessage(kWarningMsgTitle, warningString, Theme.warning)
    }
    
    func showInfoMessage(_ infoString: String) {
        showMessage(kInfoMsgTitle, infoString, Theme.info)
    }
    
    func showMessage(_ titleString: String, _ msgString: String, _ theme: Theme) {
        let view = MessageView.viewFromNib(layout: MessageView.Layout.cardView)
        view.configureTheme(theme)
        view.configureContent(title: titleString, body: msgString)
        view.button?.isHidden = true
        
        var config = SwiftMessages.Config()
        config.presentationContext = .viewController(self)//self.navigationController == nil ? self:self.navigationController!)
        config.duration = .forever
        config.dimMode = .gray(interactive: true)
        config.preferredStatusBarStyle = .lightContent
        config.eventListeners.append() { event in
            
        }
        
        SwiftMessages.show(config: config, view: view)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
//        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func present(_ vc: UIViewController, sender: UIView? = nil) {
        vc.modalPresentationStyle = UIModalPresentationStyle.popover
        self.present(vc, animated: true, completion: nil)
        if let sender = sender {
            let popController = vc.popoverPresentationController
            popController?.permittedArrowDirections = UIPopoverArrowDirection.up
            popController?.sourceView = sender
            popController?.sourceRect = sender.bounds
        }
    }
    
    static func getHUD() -> JGProgressHUD {
        let hud = JGProgressHUD(style: .dark)
        hud.interactionType = .blockAllTouches
        return hud
    }
}
