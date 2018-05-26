//
//  ScaffViewCore.swift
//  HandlesRound1
//
//  Created by Justin Smith on 2/28/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import CoreGraphics
import Singalong
import Geo

func lowToHigh(gIndex: (x: Int,y:Int))->
  ( p1:(x:Int, y: Int),
  p2:( x:Int, y:Int))
{
  let xBoundaries = gIndex.x |> boundaries
  let yBoundaries = gIndex.y |> boundaries
  return (p1: (x: xBoundaries.0, y: yBoundaries.0),
          p2: (x: xBoundaries.1, y: yBoundaries.1))
}
func highToLow(gIndex: (x: Int,y:Int))->
  ( p1:(x:Int, y: Int),
  p2:( x:Int, y:Int))
{
  let xBoundaries = gIndex.x |> boundaries
  let yBoundaries = gIndex.y |> boundaries
  return (p1: (x: xBoundaries.0, y: yBoundaries.1),
          p2: (x: xBoundaries.1, y: yBoundaries.0))
}
func boundaries(index: Int)->(Int, Int)
{
  return (index, index+1)
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
func handleTupleOptionWith(a:(Optional<Int>, Optional<Int>)) -> (Int,Int) {
  if let v1 = a.0, let v2 = a.1 {
    return (v1, v2)
  }
  else {
    return (0,0)
  }
}
let frontGraphSorted : (GraphPositions) -> GraphPositions2DSorted = {
  return GraphPositions2DSorted.init(pX: $0.pX, pY: $0.pZ)
}
