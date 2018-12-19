//
//  GameViewController.swift
//  GrasshopperRound2
//
//  Created by Justin Smith on 1/7/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import Geo
import Singalong





let linesF : ([CGPoint]) -> [Line] = lineCreate
let lines2D : ([[CGPoint]]) -> [[Line]] = { $0.map(lineCreate) }
let rectangles = linesF <=> linesF
let rectangles2D = lines2D <=> lines2D
let rectangles2DFlat = rectangles2D >>> {$0.flatMap{$0}}

let corOv : (PointCollection) -> [Oval] = {
  (points) in
  // Corner Ovals
  let top = points.top, bottom = points.bottom
  let corners : [CGPoint] = [top.first!, top.last!, bottom.last!, bottom.first!]
  let corOv : [Oval] = corners.map(redCirc)
  return corOv
}


func originSwap (model: NonuniformModel2D, scale: CGFloat, bounds: CGRect) -> NonuniformModel2D
{
  //_skCordinateModel = model
  // IMPORTANT: Scale the orgin by opposite of scale! for some reason
  // rest of scaling in addChildR
  let origin = CGPoint(model.origin.x / scale, bounds.size.height / scale - model.origin.y / scale)
  let _skCordinateModel = NonuniformModel2D(origin: origin, rowSizes: Grid(model.rowSizes.map{ -$0}), colSizes: model.colSizes)
  // transform Cordinate Space
  return _skCordinateModel
}



func gridItemed(points: PointCollection, offset: CGFloat)-> [[Geometry]] {
  
  let ghp = getHandleOvals(points: BorderPoints(top: points.top, right: points.right, bottom: points.bottom, left: points.left), offset: offset)
  let flattendGHP = ghp.flatMap{$0}
  let handleLines = zip(points.boundaries, flattendGHP).map(Line.init)
  let mids = (points) |> pointCollectionToDimLabel
  // put in on screen when gameScene loads into View
  let gridItems : [[Geometry]] = [handleLines, flattendGHP, mids]
  
  return gridItems
}



public struct BorderPoints {
  public var top: [CGPoint]
  public var right: [CGPoint]
  public var bottom: [CGPoint]
  public var left: [CGPoint]
}


func addOffset<A>(a:A) -> (A, CGFloat)
{
  return (a, 80)
}

//
//func secondOffsetLabelLeft(ps:[[CGPoint]]) -> [Label]
//{
//  return ( (ps |> leftToRightToBorders).left, unitX * -80) |> offsetPoints
//}


public func leftToRightToBorders (ltR: [[CGPoint]]) -> BorderPoints
{
  return BorderPoints(top: ltR.last! ,
                  right: ltR.map{ $0.last! },
                  bottom:  ltR.first!,
                  left: ltR.map{ $0.first! })
}

func reduceLargest(a: CGFloat, b: CGFloat) -> CGFloat
{
  return a > b ? a : b
}

func reduceSmallest(a: CGFloat, b: CGFloat) -> CGFloat
{
  return a < b ? a : b
}

public typealias Corners = (top: CGFloat, right: CGFloat, bottom:  CGFloat, left: CGFloat)

public func borders(from corners: Corners) -> BorderPoints
{
  let (top, right, bottom, left) = corners
  return BorderPoints(top: [CGPoint(left, top ),
                               CGPoint(right, top)],
                         right: [CGPoint(right, bottom ),
                               CGPoint(right, top)],
                         bottom: [CGPoint( left, bottom  ),
                               CGPoint( right, bottom)],
                         left: [CGPoint(left, bottom ),
                               CGPoint( left, top)]
  )
}



func leftToRightToBordersArray (ltR: [[CGPoint]]) -> [[CGPoint]]
{
  return [
    ltR.last!,
  ltR.map{ $0.last! },
    ltR.first!,
    ltR.map{ $0.first! }
  ]
}



let pointLabeled : (PointCollection)-> [LabeledPoint] = {
  $0.all.map { return LabeledPoint(position: $0, label: "Std") }
}


let lineToSegment : (Line) -> (CGSegment) = { return CGSegment(p1: $0.start, p2: $0.end) }
let segmentToOriginVector : (CGSegment) -> (CGPoint, CGVector) = { return ($0.p1, $0.vector) }
let segmentToString : (CGSegment) -> (String) = {
  let tuple = $0 |>  segmentToOriginVector
  let vectorStr = (tuple.1 |> vectorToOrthogonal).map(orthToString) ?? "Unknown"
  return "\(tuple.0),  \(vectorStr)  "
}
let vectorToOrthogonal : (CGVector) -> Orthogonal? = { return $0.dx == 0.0 ? .vertical : $0.dy == 0.0 ? .horizontal : nil}
let orthToString : (Orthogonal) -> String = { return $0 == .horizontal ? "horizontal" : "vertical" }
let lineStr = lineToSegment >>> segmentToString



public func basic(m: NonuniformModel2D) -> [Geometry]{
  let rectangles = (m.orderedPointsLeftToRight, m.orderedPointsUpToDown) |> rectangles2DFlat
  
  let mids = (m |> nonuniformToPoints) |> pointCollectionToDimLabel
  let pnts = m |> nonuniformToPoints |> pointLabeled
  let rtrn : [Geometry] = rectangles as [Geometry] + mids as [Geometry] + pnts as [Geometry]
  return rtrn
}

func baySelected(points: PointCollection) -> [Oval] {
  var selectedItems : [Oval]
  if points.top.count > 1, points.bottom.count > 1
  {
    // top left to right
    let first = points.top[0...1]
    // bottom right to left
    let second = points.bottom[0...1].reversed()
    // and back to the top
    let final = points.top[0]
    let firstBay =  Array(first + second ) + [final]
    let circles = centers(between: firstBay).map(redCirc)
    selectedItems = circles
  }
  else {
    selectedItems = []
  }
  return selectedItems
}

func circlesSelectedItems(points: PointCollection) -> [Oval] {
  if points.top.count > 1, points.bottom.count > 1
  {
    // top left to right
    let first = points.top[0...1]
    // bottom right to left
    let second = points.bottom[0...1].reversed()
    // and back to the top
    let final = points.top[0]
    let firstBay =  Array(first + second ) + [final]
    let circles = centers(between: firstBay).map(redCirc)
    return circles
  }
  return []
}



func formerReturn(m: NonuniformModel2D) -> [[Geometry]]{
  let rectangles = (m.orderedPointsLeftToRight, m.orderedPointsUpToDown) |> rectangles2DFlat
  let cornerOvals = m |> nonuniformToPoints |> corOv
  let overallDimes = (m |> nonuniformToPoints) |> pointCollectionToDimLabel
  let boundingItems : [[Geometry]] = [ rectangles, cornerOvals, overallDimes]
  
  let mids = (m |> nonuniformToPoints) |> pointCollectionToDimLabel
  let pnts = m |> nonuniformToPoints |> pointLabeled
  let gItems = (m |> nonuniformToPoints, 40) |> gridItemed
  let selectedItems1 = m |> nonuniformToPoints |> baySelected
  let selectedItems : [[Geometry]] = [selectedItems1, rectangles]
  let rtrn : [[Geometry]] = [rectangles, mids, pnts] +
    gItems + boundingItems + selectedItems
  return rtrn
}


public func toGeometry<A:Geometry>(_ a: A ) -> Geometry
{
  return a as Geometry
}





func lineZero(line: Line)-> Bool
{
  return line.start == line.end
}
public func reduceDuplicates(geo:[Line])-> [Line]
{
  var mutGeo = geo
  mutGeo.removeAll( where: lineZero )
  return mutGeo
}






// ...SceneKit Handlering



// Viewcontroller Functions


