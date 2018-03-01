//
//  ScaffViewCore.swift
//  HandlesRound1
//
//  Created by Justin Smith on 2/28/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import CoreGraphics


func uiToSprite(height: CGFloat, rect: CGRect) -> CGRect
{
  return CGRect(x:rect.x ,
                 y: height - rect.y,
                 width: rect.width,
                 height: -rect.height).standardized
}
func uiToSprite(height: CGFloat, y: CGFloat ) -> CGFloat
{
  return height - y
}
func uiToSprite(height: CGFloat, point: CGPoint) -> CGPoint {
  return CGPoint(x: point.x, y: height - point.y )
}

func mirrorVertically(point: CGPoint, along y: CGFloat) -> CGPoint {
  let delta = y - point.y
  let newOriginY = y + delta
  return CGPoint(x: point.x, y: newOriginY)
}
func mirrorVertically(rect: CGRect, along y: CGFloat) -> CGRect {
  let delta = y - rect.origin.y
  let newOriginY = y + delta
  let newRect = CGRect(x: rect.x, y: newOriginY, width: rect.width, height: -rect.height)
  return newRect.standardized
}

func viewSpaceToModelSpace (viewPoint: CGPoint, viewModelFrame: CGRect) -> (CGPoint) {
  return CGPoint( viewPoint.x - viewModelFrame.origin.x, viewPoint.y - viewModelFrame.origin.y)
}
let pointToGridIndices : (GraphPositions2DSorted, CGPoint) -> (Int?, Int?) =
{
  func middle( check: CGFloat, values: [CGFloat] ) -> Int?
  {
    return Array(zip(values, values.dropFirst())).index{ (a1, a2) -> Bool in
      return a1 < check && check < a2
      
    }
  }
  
  return ( ($1.x, $0.pX) |> middle,
           ($1.y, $0.pY) |> middle)
}
let modelRect : ((Int, Int), GraphPositions2DSorted) -> (CGRect) = {
  i, pos in
  return CGPoint(pos.pX[i.0], pos.pY[i.1]) + CGPoint(pos.pX[i.0 + 1], pos.pY[i.1 + 1])
}
func handleTupleOptionOrFail<A>(a:(Optional<A>, Optional<A>)) -> (A,A) {
  if let v1 = a.0, let v2 = a.1 {
    return (v1, v2)
  }
  else {
    fatalError()
  }
}
let frontGraphSorted : (GraphPositions) -> GraphPositions2DSorted = {
  return GraphPositions2DSorted.init(pX: $0.pX, pY: $0.pZ)
}
