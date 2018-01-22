//
//  TensionedPoint.swift
//  HandlesRound1
//
//  Created by Justin Smith on 1/20/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import CoreGraphics

struct TensionedPoint { var x:CGFloat, y: CGFloat, anchor: CGPoint }

// Takes a tensionedPoint (for chaining) and a lower X Bounds returns a tensionedPoint
// that is a square root of the diference
func boundsLower(springX: TensionedPoint, lowerBounds: CGFloat) -> TensionedPoint
{
  let x = springX.x
  if x < lowerBounds
  {
    let newX = pow((lowerBounds-x)*4,1/2)*2
    return TensionedPoint(
      x: lowerBounds - newX,
      y: springX.y,
      anchor: CGPoint(x:lowerBounds, y:springX.anchor.y)
    )
  }
  return springX
}

func boundsXUpper(springX: TensionedPoint, upperBounds: CGFloat) -> TensionedPoint
{
  let x = springX.x
  if x > upperBounds
  {
    let newX = pow((x-upperBounds)*4,1/2)*2
    return TensionedPoint(
      x:upperBounds + newX,
      y: springX.y,
      anchor: CGPoint(x:upperBounds, y:springX.anchor.y)
    )
  }
  return springX
}

// Changes the Y in returned TensionPoint (in both the y and anchor.y) in relation to an upper bounnds check
func boundsY(springY: TensionedPoint, lowerBounds: CGFloat) -> TensionedPoint
{
  let y = springY.y
  if y < lowerBounds
  {
    let a = pow((lowerBounds-y)*4,1/2)*2
    return TensionedPoint(
      x: springY.x,
      y:lowerBounds - a,
      anchor: CGPoint(x:springY.anchor.x, y:lowerBounds)
    )
  }
  return springY
}

func boundsYUpper(springY: TensionedPoint, upperBounds: CGFloat) -> TensionedPoint
{
  let y = springY.y
  if y > upperBounds
  {
    let a = pow((y-upperBounds)*4,1/2)*2
    return TensionedPoint(
      x: springY.x,
      y: upperBounds + a,
      anchor: CGPoint(x:springY.anchor.x, y:upperBounds)
    )
  }
  return springY
}
