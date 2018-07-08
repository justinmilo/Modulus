//
//  GraphicsCoreTests.swift
//  GraphicsCoreTests
//
//  Created by Justin Smith on 4/19/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import XCTest

class GraphicsCoreTests: XCTestCase {
    
  //
  //  HandlesRound1Tests2.swift
  //  HandlesRound1Tests2
  //
  //  Created by Justin Smith on 4/12/18.
  //  Copyright © 2018 Justin Smith. All rights reserved.
  //
  
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
      XCTAssert(
        translate(
          from: CGRect(0,0,10,20),
          toSKCoordIn: CGRect(0,0,10,20))( CGPoint(0,0) )
          == SKPoint(0,20)
      )
      XCTAssert(
        translate(
          from: CGRect(0,0,10,20),
          toSKCoordIn: CGRect(0,0,10,20)
        )(CGPoint(0,5)) == SKPoint(0,15) )
      
       XCTAssert(
        translate(
          from: CGRect(0,0,10,10),
          toSKCoordIn: CGRect(5,5,5,5)
          )( CGPoint(0,0) ) == SKPoint(-5,10) )
      
       XCTAssert(
        translate(
          from: CGRect(0,0,10,10),
          toSKCoordIn: CGRect(5,5,5,5)
          )( CGPoint(5,5) ) == SKPoint(0,5) )
       XCTAssert(
        translate(
          from: CGRect(0,0,10,10),
          toSKCoordIn: CGRect(5,5,5,5)
        )(CGPoint(10,10) ) == SKPoint(5,0) )
      
    }
    
    
    func testPerformanceExample() {
      // This is an example of a performance test case.
      self.measure {
        // Put the code you want to measure the time of here.
      }
    }
    
}
