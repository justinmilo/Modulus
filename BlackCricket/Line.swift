//
//  Line.swift
//  BlackCricket
//
//  Created by Justin Smith on 12/1/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation
import Singalong

public struct Line : Geometry {
  var start: CGPoint
  var end: CGPoint
  public var position : CGPoint {
    set {
      let x = newValue.x - self.position.x
      let y = newValue.y - self.position.y
      
      start.x = start.x + x
      start.y = start.y + y
      end.x = end.x + x
      end.y = end.y + y
    }
    get {
      return CGPoint(x: (start.x + end.x)/2, y: (start.y + end.y)/2)
    }
  }
  public init(start: Geometry, end:Geometry) { self.start = start.position; self.end = end.position}
}
extension Line {
  init( p1:(CGFloat,CGFloat),
        p2:(CGFloat,CGFloat)) {
    start = p1 |> CGPoint.init(x:y:);
    end = p2 |> CGPoint.init(x:y:)}
  
  init( p1:CGPoint,
        p2:CGPoint) {
    start = p1
    end = p2
  }
}


extension Line {
  var unitLine : Line { return Line(start: CGPoint(x:0,y:0), end: CGPoint(x:self.end.x - self.start.x,y: self.end.y - self.start.y))
  }
}

