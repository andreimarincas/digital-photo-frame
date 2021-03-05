//
//  Utils.swift
//  DigitalPhotoFrame
//
//  Created by Andrei Marincas on 12/31/17.
//  Copyright © 2017 Andrei Marincas. All rights reserved.
//

import Foundation
import UIKit

func random_int(_ upper_bound: Int) -> Int {
    return Int(arc4random_uniform(UInt32(upper_bound)))
}

func random_integers_unique(_ upper_bound: Int) -> [Int] {
    var res = [Int]()
    guard upper_bound > 0 else { return res }
    var values = [Int]()
    for i in 0..<upper_bound {
        values.append(i)
    }
    while !values.isEmpty {
        let idx = random_int(values.count)
        res.append(values[idx])
        values[idx] = values[values.count - 1]
        values.removeLast()
    }
    return res
}

extension UIView {
    
    func disableDelaysContentTouches() {
        if let scrollView = self as? UIScrollView {
            scrollView.delaysContentTouches = false
        }
        for view in subviews {
            view.disableDelaysContentTouches()
        }
    }
}

extension CGFloat {
    
    static var pi_12: CGFloat = { CGFloat.pi / 12.0 }()
}

extension CGPoint {
    
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x + dx, y: y + dy)
    }
}
