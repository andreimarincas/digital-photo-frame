//
//  Utils.swift
//  DigitalPhotoFrame
//
//  Created by Andrei Marincas on 12/31/17.
//  Copyright © 2017 Andrei Marincas. All rights reserved.
//

import Foundation

func random_int(_ upper_bound: Int) -> Int {
    return Int(arc4random_uniform(UInt32(upper_bound)))
}
