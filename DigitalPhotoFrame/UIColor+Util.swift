//
//  UIColor+Util.swift
//  DigitalPhotoFrame
//
//  Created by Andrei Marincas on 1/4/18.
//  Copyright © 2018 Andrei Marincas. All rights reserved.
//

import Foundation
import UIKit

extension UIColor
{
    convenience init(hex: UInt32)
    {
        self.init(CGFloat((hex >> 16) & 0xff), CGFloat((hex >> 8) & 0xff), CGFloat(hex & 0xff))
    }
    
    convenience init(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat)
    {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
    convenience init(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat)
    {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: a/255)
    }
}
