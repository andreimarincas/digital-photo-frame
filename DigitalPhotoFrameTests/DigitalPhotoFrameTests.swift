//
//  DigitalPhotoFrameTests.swift
//  DigitalPhotoFrameTests
//
//  Created by Andrei Marincas on 12/27/17.
//  Copyright © 2017 Andrei Marincas. All rights reserved.
//

import XCTest
@testable import DigitalPhotoFrame

class DigitalPhotoFrameTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    private func allUnique(in array: [Int]) -> Bool? {
        guard array.count > 0 else { return nil }
        var occurrences = Array(repeating: 0, count: array.count)
        for i in 0..<array.count {
            let e = array[i]
            guard e >= 0 && e < array.count else { return nil }
            let occ = occurrences[e] + 1
            if occ > 1 {
                return false
            }
            occurrences[e] = occ
        }
        return true
    }
    
    func testRandomValues(_ upper_bound: Int) {
        let randomValues = random_integers_unique(upper_bound)
        assert(randomValues.count == upper_bound)
        assert(allUnique(in: randomValues)!)
    }
    
    func testRandomObject(_ upper_bound: Int) {
        let random = Random(upper_bound)
        var randomValues = [Int]()
        while let r = random.next {
            randomValues.append(r)
        }
        print(randomValues)
        assert(randomValues.count == upper_bound)
        assert(allUnique(in: randomValues)!)
    }
    
    func doTestRandom(_ upper_bound: Int) {
        testRandomValues(upper_bound)
        testRandomObject(upper_bound)
    }
    
    func testRandom() {
        doTestRandom(10)
        doTestRandom(100)
        doTestRandom(1000)
        doTestRandom(10000)
        doTestRandom(100000)
    }
}
