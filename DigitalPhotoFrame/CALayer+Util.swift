//
//  CALayer+Util.swift
//  DigitalPhotoFrame
//
//  Created by Andrei Marincas on 1/5/18.
//  Copyright © 2018 Andrei Marincas. All rights reserved.
//

import Foundation
import QuartzCore

extension CALayer {
    
    static func pauseLayer(_ layer: CALayer) {
        let pausedTime: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pausedTime
    }
    
    static func pauseAllSublayers(in layer: CALayer, recursive: Bool = true) {
        guard let sublayers = layer.sublayers else { return }
        for sublayer in sublayers {
            CALayer.pauseLayer(sublayer)
            if recursive {
                pauseAllSublayers(in: sublayer)
            }
        }
    }
    
    static func resumeLayer(_ layer: CALayer) {
        let pausedTime: CFTimeInterval = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        let timeSincePause: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
    }
}
