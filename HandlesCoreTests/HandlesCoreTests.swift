//
//  HandlesRound1Tests2.swift
//  HandlesRound1Tests2
//
//  Created by Justin Smith on 4/12/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import XCTest

class HandlesRound1Tests2: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
  func testRectIndex() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    XCTAssert( RectIndex(3).opposite == RectIndex(1) )
    XCTAssert( RectIndex(2).opposite == RectIndex(0) )
    XCTAssert( RectIndex(1).opposite == RectIndex(3) )
    XCTAssert( RectIndex(0).opposite == RectIndex(2) )
    
    XCTAssert( RectIndex(3).clockwise  == RectIndex(0) )
    XCTAssert(RectIndex(2).clockwise == RectIndex(3) )
    XCTAssert(RectIndex(1).clockwise == RectIndex(2) )
    XCTAssert(RectIndex(0).clockwise == RectIndex(1) )
    
    XCTAssert(RectIndex(3).counterClockwise == RectIndex(2) )
    XCTAssert(RectIndex(2).counterClockwise == RectIndex(1) )
    XCTAssert(RectIndex(1).counterClockwise == RectIndex(0) )
    XCTAssert(RectIndex(0).counterClockwise == RectIndex(3) )
  }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
