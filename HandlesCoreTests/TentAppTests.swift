//
//  TentAppTests.swift
//  
//
//  Created by Justin Smith Nussli on 12/29/19.
//

import XCTest
@testable import Interface
@testable import Modular

class TentAppTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
      
      var spriteState =  SpriteState(screen: CGRect.zero,
                                      scale : 1.0,
                                      sizePreferences: [1.0],
                                      graph: TentGraph(),
                                      editingViews: [tentPlanMap] )
      
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
