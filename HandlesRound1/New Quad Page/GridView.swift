//
//  GridView.swift
//  Modular
//
//  Created by Justin Smith on 8/11/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation

import Singalong
import Geo

public func zflip<A,C>(_ t: @escaping (A)->()->C ) -> (A)->(C) {
  return zurry(flip(t))
}


class GridView : UIView {
  override func draw(_ rect: CGRect) {
    if let context = UIGraphicsGetCurrentContext()
    {
      context.saveGState()
      
      func divide(segment: CGSegment, by numberOfPoints: Int) -> [CGPoint] {
        return (0...numberOfPoints).map{
          let mag = segment.length / CGFloat(numberOfPoints)
          let p = segment.p1 + (segment.vector.unitForm * mag) * CGFloat($0)
          return p
        }
      }
      
      
      func linesDivide(seg1: CGSegment, seg2: CGSegment, by: Int)->[CGSegment]{
        return Array(zip(
          divide(segment: seg1, by: by),
          divide(segment: seg2, by: by)
          ).map(CGSegment.init))
      }
      
      let top = (rect.topLeft, rect.topRight) |> CGSegment.init
      let bottom = (rect.bottomLeft, rect.bottomRight) |> CGSegment.init
      let left = (rect.topLeft, rect.bottomLeft) |> CGSegment.init
      let right = (rect.topRight, rect.bottomRight) |> CGSegment.init
      
      let grid = linesDivide(seg1: top, seg2: bottom, by: 10)
        + linesDivide(seg1: left, seg2: right, by: 10)
        + linesDivide(seg1: right, seg2: top, by: 10)
        + linesDivide(seg1: bottom, seg2: left, by: 10)
        + linesDivide(seg1: left, seg2: top.reversed, by: 10)
        + linesDivide(seg1: right.reversed, seg2: bottom, by: 10)
      
      
      
      grid.forEach {
        context.move(to: $0.p1)
        context.addLine(to: $0.p2)
      }
      
      context.setStrokeColor(UIColor.white.cgColor)
      context.setLineWidth(1.0)
      context.strokePath()
      context.restoreGState()
    }
  }
}
