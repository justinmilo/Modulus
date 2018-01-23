//
//  PlanModel.swift
//  Control
//
//  Created by Justin Smith on 3/6/17.
//  Copyright © 2017 Justin Smith. All rights reserved.
//

import Foundation
import CoreGraphics


protocol Plan {
  var x : Grid { get set }
  var y : Grid { get set }
}
// based on an on and off map in theory
// as of feb 17 just is a grid
struct PlanModel : Plan {
  var x : Grid = [50, 200, 200, 200, 50]
  var y : Grid = [50, 200, 50, 200, 50]
  
  
  //  [200] [200]
  //  [200] [200]
  //  SizeIndexMap(x: 0, y: 1)
  //  [ x ] [200]
  //  [200] [200]
  //  SizeIndexMap(x: 1, y: 1)
  //  [200] [ x ]
  //  [200] [200]
  //  SizeIndexMap(x: 0, y: 0), SizeIndexMap(x: 1, y: 0), SizeIndexMap(x: 1, y: 1)
  //  [200] [ x ]
  //  [ x ] [ x ]
  
  //
  // L4 _______________________
  //    |      |    |         |
  //    |      |    |         |  200   y2
  //    |      |    |         |
  // L3 +------+----+---------+
  //    |      |    |         |  100   y1
  // L2 +------+----+---------+
  //    |      |    |         |  150
  //    |      |    |         |        y0
  // L1 +------+----+---------+
  //
  //   Q1     Q2   Q3         Q4
  //       x0    x1     x2
  //       200  100    300
  // Q's are in the y dimension along the x axis
  // L's are in the x dimension along the y axis
  
  
  mutating func addToTheFrontOfHorizontalGrid( sizes: [CGFloat] )
  {
    let xs = sizes + self.x.sizes
    self.x = Grid(xs)
  }
  mutating func addToTheBackOfHorizontalGrid( sizes: [CGFloat] )
  {
    let xs = self.x.sizes + sizes
    self.x =  Grid(xs)
  }
}
