//
//  File.swift
//  HandlesRound1
//
//  Created by Justin Smith on 4/9/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import CoreGraphics



// Pure functions
func corners(in rect: CGRect) -> [CGPoint]
{
  return  [rect.topLeft,
           rect.topRight,
           rect.bottomRight,
           rect.bottomLeft]
}

func edges(in rect: CGRect) -> [CGPoint]
{
  return  [rect.topCenter,
           rect.centerRight,
           rect.bottomCenter,
           rect.centerLeft]
}


// return edges from top left clockwise
func corners(of rect: CGRect)-> [CGPoint]
{
  return [rect.topLeft, rect.topRight, rect.bottomRight, rect.bottomLeft]
}
// return edges from top center clockwise
func edgeCenters(of rect: CGRect)->[CGPoint]
{
  return [rect.topCenter, rect.centerRight, rect.bottomCenter, rect.centerLeft]
}

extension Array where Element == CGPoint {
  subscript(_ rI:  RectIndex) -> CGPoint{
    return self[rI.index]
  }
}



  
// Create rect from a index that indicates master point of ref (if points dont make a rect naturally) and it's opposite corner given a counter clockwise set of corner points
func masterRect(originPoint: CGPoint, from index: Int, in points:[CGPoint]) -> CGRect {
  
  let opposingIndex = RectIndex(index).opposite
  return points[index] + points[opposingIndex]
}

// Create rect from a "last changed" index assuming counter clockwise set of edge points // ADAPATER for interface
func mirrorDefinedRect(mirroredAt position: CGPoint, from intIndex: Int, in points:[CGPoint]) -> CGRect {
  let index = RectIndex(intIndex)
  let currentPoint = points[index]
  return currentPoint |> mirrorOrtho(from: position)
      + currentPoint
      + points[index.clockwise]
      + points[index.counterClockwise]
}


func opposite(i : Int )-> Int
{
  let sides = 4
  return i + 2 < sides ?
    i + 2 : i - 2
}


// Create rect from a "last changed" index assuming counter clockwise set of edge points // ADAPATER for interface

func centerDefinedRect(from points:[CGPoint]) -> CGRect {
  let points = points.map{$0.asRect()}
  let remaining = points.dropFirst()
  return remaining.reduce(points.first!, { (res:CGRect, point:CGRect ) -> CGRect in
    return res.union( point )
  })
}

let helper : (CGPoint, Int, [CGPoint]) -> [CGPoint] = { _,_,pts in return pts }
let centerDefinedRect_interfaceAdapter = detuple(helper >>> centerDefinedRect)


struct BoundingBoxState {
  var centers: (CGRect) -> [CGPoint]
  let redefine : (CGPoint, Int, [CGPoint]) -> CGRect
  // Int, [CGPoint] -> CGRect + intrinsic selection bias
  // MirrorOrigin, Corner -> CGRect
  // MirrorOrigin, Extents, NewEdge -> CGRect
  let positions: (Int) -> Position2D
  let boundaries: (Int) -> (CGRect, CGRect) -> CGRect
  
  static let cornerState = BoundingBoxState(
    centers: corners(in:),
    redefine: masterRect,
    positions: cornerPositions,
    boundaries: curry(boundsChecking)
  )
  
  static let centeredEdge = BoundingBoxState(
    centers: edges(in:),
    redefine: mirrorDefinedRect,
    positions: edgePositions,
    boundaries: edgePositions >>> edgeBoundsCheck
)
  
  static let edgeState = BoundingBoxState(
    centers: edges(in:),
    redefine: centerDefinedRect_interfaceAdapter,
    positions: edgePositions,
    boundaries: edgePositions >>> edgeBoundsCheck
)
  

}

func cornerPositions( i: Int) -> (VerticalPosition, HorizontalPosition)
{
    switch i {
    case 0: return (.top, .left)
    case 1: return (.top, .right)
    case 2: return (.bottom, .right)
    case 3: return (.bottom, .left)
    default: fatalError()
  }
}

func edgePositions( i: Int) -> (VerticalPosition, HorizontalPosition)
{
  switch i {
  case 0: return (.top, .center)
  case 1: return (.center, .right)
  case 2: return (.bottom, .center)
  case 3: return (.center, .left)
  default: fatalError()
  }
}




// FIXME Doesn't do the right thing
let edgeBoundsCheck : (Position2D) -> (CGRect, CGRect) -> CGRect =
{
  position in
  return { outerRect, innerRect in
    (position, outerRect) |> positionsToPoint +
    (position |> opposite, innerRect) |> positionsToPoint
  }
}


// What is this trying to do??
// Createas a union/composite between two rect boundaries
func boundsChecking(_ index: Int, _ outerBoundaryRect: CGRect, _ frozenBounds: CGRect)->CGRect {
  let me : CGRect
  switch index {
  case 0:
    me = outerBoundaryRect.topLeft + frozenBounds.bottomRight
  case 1:
    me = outerBoundaryRect.topRight + frozenBounds.bottomLeft
  case 2:
    me = outerBoundaryRect.bottomRight + frozenBounds.topLeft
  case 3:
    
    
    me = outerBoundaryRect.bottomLeft + frozenBounds.topRight
    
  default:
    fatalError()
  }
  return me
}


