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
func masterRect(from index: RectIndex, in points:[CGPoint]) -> CGRect {
  
  let opposingIndex = index.oppositeIndex
  return points[index] + points[opposingIndex]
}
// Create rect from a "last changed" index assuming counter clockwise set of edge points // ADAPATER for interface
func centerDefinedRect(from index: Int, in points:[CGPoint]) -> CGRect {
  return centerDefinedRect(from: points)
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

func centerDefinedRect(from points:[CGPoint]) -> CGRect {
  let points = points.map{$0.asRect()}
  let remaining = points.dropFirst()
  return remaining.reduce(points.first!, { (res:CGRect, point:CGRect ) -> CGRect in
    return res.union( point )
  })
}


struct BoundingBoxState {
  var centers: (CGRect) -> [CGPoint]
  let redefine : (CGPoint, Int, [CGPoint]) -> CGRect
  let positions: (Int) -> (VerticalPosition,HorizontalPosition)
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

let centeredEdge = BoundingBoxState(
  centers: edges(in:),
  redefine: mirrorDefinedRect,
  positions: edgePositions
)

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

// pure3

func insetIf(_ m1: CGRect, buttonSize bs:CGSize)->CGRect {
  let sizeW : CGFloat = (bs.width*2 <= m1.size.width) ? bs.width : 0.0
  let sizeH : CGFloat = (bs.height*2 <= m1.size.height) ? bs.height : 0.0
  return m1.insetBy(dx: sizeW, dy: sizeH)
}

