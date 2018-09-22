//
//  Icon+Extension.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/6/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import Material

public struct IconImage {
    
    /// Get the icon by the file name.
    public static func icon(_ name: String) -> UIImage? {
        return UIImage(named: name, in: nil, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    }
    
    public static var lock = IconImage.icon("ic_lock_white")
    public static var username = IconImage.icon("ic_username_white")
    public static var zipcode = IconImage.icon("ic_zipcode_white")
}
