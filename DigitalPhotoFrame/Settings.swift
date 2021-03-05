//
//  Settings.swift
//  DigitalPhotoFrame
//
//  Created by Andrei Marincas on 1/4/18.
//  Copyright © 2018 Andrei Marincas. All rights reserved.
//

import Foundation

fileprivate let time_key = "digitalphotoframe-time-key"
fileprivate let animation_key = "digitalphotoframe-animation-key"
fileprivate let is_random_key = "digitalphotoframe-is_random-key"

class Settings {
    
    private static let userDefaults = UserDefaults.standard
    
    static var time: Int {
        get {
            if let value = userDefaults.object(forKey: time_key) as? Int {
                return value
            } else {
                return 15
            }
        }
        set {
            userDefaults.set(newValue, forKey: time_key)
            userDefaults.synchronize()
        }
    }
    
    static var animation: PhotoAnimation {
        get {
            if let value = userDefaults.object(forKey: animation_key) as? Int {
                return PhotoAnimation(rawValue: value)!
            } else {
                return .any
            }
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: animation_key)
            userDefaults.synchronize()
        }
    }
    
    static var isRandom: Bool {
        get {
            return userDefaults.bool(forKey: is_random_key)
        }
        set {
            userDefaults.set(newValue, forKey: is_random_key)
            userDefaults.synchronize()
        }
    }
}
