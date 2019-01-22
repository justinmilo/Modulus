//
//  GrasshopperFunctions.swift
//  GrasshopperRound2
//
//  Created by Justin Smith on 1/7/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation

//: A SpriteKit based Playground


import CoreGraphics
import UIKit
import Singalong
import Geo

enum Orthogonal {
  case horizontal
  case vertical
}
enum BorderCase {
  case top, left, right, bottom
}

struct LabeledPoint : Geometry {
  var position : CGPoint
  var label : String
}


// Extensions
extension CGPoint : Geometry{
  public var position: CGPoint {
    get { return self }
    set { self = newValue}
    
  }
}

extension CGRect : Geometry {
  public var position : CGPoint {
    get {
      return origin
    }
    set {
      self.origin = newValue
    }
  }
}



import Geo


extension Array
{
  mutating func moveFirstToLast() -> ()
  {
    let first = dropFirst()
    self = self + first
  }
}

// Helper
let unitX = CGVector(dx: 1, dy: 0)
let unitY = CGVector(dx: 0, dy: 1)

let redCirc = { pointToCircle2($0, #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1))}
let blueCirc = { pointToCircle2($0, #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.5504655855, alpha: 1))}


func offsetPoints( points: [CGPoint], offset d: CGVector) -> [Geometry]
{
  let a =  LongestList(points, [d] ).map(move)
  return a
}


func getHandleOvals(points: BorderPoints, offset d: CGFloat)->[[Oval]] {
  // convert outside points to handle points
  let t = LongestList(points.top, [unitY * d]).map(moveByVector).map(redCirc)
  let l = LongestList(points.left, [unitX * d]).map(moveByVector).map(redCirc)
  let b = LongestList(points.bottom, [unitY * -d]).map(moveByVector).map(redCirc)
  let r = LongestList(points.right, [unitX * -d]).map(moveByVector).map(redCirc)
  let gridHandlePoints = [t , l , b , r]
  return gridHandlePoints
}





