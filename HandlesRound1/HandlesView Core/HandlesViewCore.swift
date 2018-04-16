//
//  File.swift
//  HandlesRound1
//
//  Created by Justin Smith on 4/9/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import CoreGraphics



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




struct BoundingBoxState {
  var centers: (CGRect) -> [CGPoint]
  let redefine : (CGPoint, Int, [CGPoint]) -> CGRect
  // Int, [CGPoint] -> CGRect + intrinsic selection bias
  // MirrorOrigin, Corner -> CGRect
  // MirrorOrigin, Extents, NewEdge -> CGRect
  let positions: (Int) -> Position2D
  let boundaries: (Position2D) -> (CGRect, CGRect) -> CGRect // (OuterRect, InnerRect)
  let innerRect: (CGPoint, Position2D, CGRect) -> CGRect
  
  
  static let centeredEdge = BoundingBoxState(
    centers: edges(in:),
    redefine: mirrorDefinedRect,
    positions: edgePositions,
    boundaries: edgeBoundsCheck,
    innerRect : edgeInnerRect
)

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

// Mirror functions
func cornerInnerRect(at point: CGPoint, position: Position2D, inner: CGRect)  -> CGRect
{
  return ((position, inner) |> positionsToPoint ) + point
}

// FIXME could be replacingEdge(at position: Position2D, with: CGFloat)->(CGRect)->CGRect
func edgeInnerRect(at mirror: CGPoint, position: Position2D, inner: CGRect) -> CGRect
{
  return ((position, inner) |> positionsToPoint )
    + mirror
    + (position |> clockwise, inner) |> positionsToPoint
    + (position |> counterClockwise, inner) |> positionsToPoint
}

// FIXME could be replacingEdge(at position: Position2D, with: CGFloat)->(CGRect)->CGRect
let edgeBoundsCheck : (Position2D) -> (CGRect, CGRect) -> CGRect =
{
  position in
  return { outerRect, innerRect in
    (position, outerRect) |> positionsToPoint
    + (position |> opposite, innerRect) |> positionsToPoint
    + (position |> clockwise, innerRect) |> positionsToPoint
    + (position |> counterClockwise, innerRect) |> positionsToPoint
  }
}





