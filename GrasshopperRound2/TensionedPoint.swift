//
//  TensionedPoint.swift
//  HandlesRound1
//
//  Created by Justin Smith on 1/20/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import CoreGraphics


struct TensionedPoint {
  var projection: CGPoint
  var initial: CGPoint
  var anchor: CGPoint
}

// Takes a tensionedPoint (for chaining) and a lower X Bounds returns a tensionedPoint
// that is a square root of the diference


func powerSlope(_ x:CGFloat, lowerBounds:CGFloat)->CGFloat {
  return pow((abs(x-lowerBounds))*4,1/2)*2
}

func otherSlope(_ x:CGFloat, lowerBounds:CGFloat)->CGFloat {
  return pow((abs(x-lowerBounds)),1/2)*2
}

func constrained(_ x:CGFloat, lowerBounds:CGFloat)->CGFloat {
  return 0
}



extension CGPoint {
  func tensionedPoint(within bounds:CGRect) -> TensionedPoint
  {
    
    let xPoint = x.boundsTest(lowerBounds: bounds.minX, upperBounds: bounds.maxX, transform: otherSlope)
    
    let yPoint = y.boundsTest(lowerBounds: bounds.minY, upperBounds: bounds.maxY, transform: otherSlope)
    
    return TensionedPoint(
      projection: CGPoint(xPoint.0, yPoint.0),
      initial: CGPoint(
        x:xPoint.1?.0 ?? xPoint.0,
        y: yPoint.1?.0 ?? yPoint.0
      ),
      anchor: CGPoint(
        x:xPoint.1?.1 ?? xPoint.0,
        y: yPoint.1?.1 ?? yPoint.0
    ))
  }
}

extension CGFloat
{
  func boundsTest(lowerBounds: CGFloat, upperBounds: CGFloat, transform: (CGFloat, CGFloat) -> CGFloat ) -> (CGFloat, (CGFloat, CGFloat)?)
  {
    
    if self < lowerBounds
    {
      return (lowerBounds - transform(self, lowerBounds), (self, lowerBounds))
    }
    else if self > upperBounds
    {
      return (upperBounds + transform(self, upperBounds), (self, upperBounds))
    }
    else { return (self, nil) }
  }
}



