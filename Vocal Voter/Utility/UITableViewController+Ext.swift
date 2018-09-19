//
//  UITableViewController+Ext.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/19/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit

extension UITableViewController {

    func addTopLine(_ view: UIView) {
        let topLineView = UIView()
        view.addSubview(topLineView)
        topLineView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.8)
        topLineView.translatesAutoresizingMaskIntoConstraints = false
        topLineView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        topLineView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topLineView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        topLineView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }
    
    func addBottomLine(_ view: UIView) {
        let bottomLineView = UIView()
        view.addSubview(bottomLineView)
        bottomLineView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.8)
        bottomLineView.translatesAutoresizingMaskIntoConstraints = false
        bottomLineView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bottomLineView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bottomLineView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomLineView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }

    func emptyHeaderView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
}
