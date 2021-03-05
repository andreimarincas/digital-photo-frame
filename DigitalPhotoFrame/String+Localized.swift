//
//  String+Localized.swift
//  DigitalPhotoFrame
//
//  Created by Andrei Marincas on 1/3/18.
//  Copyright © 2018 Andrei Marincas. All rights reserved.
//

import Foundation

extension String {
    
    static func localized(_ key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
    
    static func localized(_ key: String, _ arguments: CVarArg...) -> String {
        return String(format: NSLocalizedString(key, comment: ""), arguments: arguments)
    }
}
