//
//  Scaffolding.swift
//  Meccano
//
//  Created by Justin Smith on 7/29/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import GrapheNaked
import BlackCricket
import Singalong
import Geo

struct Scaff2D {
  enum ScaffType {
    case ledger
    case basecollar
    case jack
    case diag
    case standard
  }
  enum DrawingType {
    case plan
    case cross
    case longitudinal
  }
  
  var start: CGPoint
  var end: CGPoint
  let part : ScaffType
  let view : DrawingType
}
extension Scaff2D : Geometry {
  var position: CGPoint {
    get { return (self.start + self.end).center }
    set(newValue){
      let previous = (self.start + self.end).center
      let dif = newValue - previous
      start = start + dif
      end = end + dif
    }
  }
}
extension Scaff2D {
  var upToTheRight : Bool  {
    return start.x < end.x && start.y < end.y
  }
}
extension Scaff2D : CustomStringConvertible {
  var description: String {
    return "\(part) \(view) - \(CGSegment(p1:start, p2:end).length), \(position)"
  }
}

import Interface
import SpriteKit
extension Scaff2D : CacheRepresentable {
  func node(pool: inout [SKSpriteNode]) -> SKNode? {
    return createScaff2DNode(item: self, cache: &pool)
  }

}



