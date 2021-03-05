//
//  Random.swift
//  DigitalPhotoFrame
//
//  Created by Andrei Marincas on 1/4/18.
//  Copyright © 2018 Andrei Marincas. All rights reserved.
//

import Foundation

/* 
 Generates unique values up to an upper bound and cycles through them.
 Re-generates all values on each cycle ensuring no value appears twice in a row.
 */
class Random {
    
    private var upperBound: Int
    private var randomValues: [Int]
    private var index = 0
    
    init(_ upperBound: Int) {
        self.upperBound = upperBound
        randomValues = random_integers_unique(upperBound)
    }
    
    var next: Int? {
        guard randomValues.count > 0 else { return nil }
        guard randomValues.count > 1 else { return randomValues[0] }
        let value = randomValues[index]
        if index < randomValues.count - 1 {
            index = index + 1
        } else {
            index = 0
            randomValues = random_integers_unique(upperBound)
            if randomValues[0] == value {
                randomValues[0] = randomValues[randomValues.count - 1]
                randomValues[randomValues.count - 1] = value
            }
        }
        return value
    }
}
