//
//  ViewFunctions.swift
//  HandlesRound1
//
//  Created by Justin Smith on 2/10/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import CoreGraphics
import Singalong
import Geo
import GrapheNaked
import BlackCricket

func log<A>(_ loggableItem: A) -> A {
  print(loggableItem)
  return loggableItem
}

let remove3rdDimFront : (CGSize3) -> CGSize = {
  return CGSize(width: $0.width, height:  $0.elev)
}
let remove3rdDimSide : (CGSize3) -> CGSize = {
  return CGSize(width: $0.depth, height:  $0.elev)
}
let remove3rdDimPlan : (CGSize3) -> CGSize = {
  return CGSize(width: $0.width, height:  $0.depth)
}


func bindSize( master: CGRect, size: CGSize, positions: (VerticalPosition, HorizontalPosition)) -> (CGRect)
{
  // Find Orirgin
  return master.withInsetRect( ofSize: size, hugging:  (positions.0.opposite, positions.1.oposite))
}

func centeredRect( master: CGRect, size: CGSize, positions: (VerticalPosition, HorizontalPosition)) -> (CGRect)
{
  // Find Orirgin
  return master.withInsetRect( ofSize: size, hugging:  positions)
}



//

let sizeFromPlanScaff : (ScaffGraph) -> CGSize = { $0.bounds } >>> remove3rdDimPlan
let sizeFromRotatedPlanScaff : (ScaffGraph) -> CGSize = { $0.bounds } >>> remove3rdDimPlan >>> flip
let sizeFromGridScaff : (ScaffGraph) -> CGSize = { $0.boundsOfGrid.0 } >>> remove3rdDimFront
let sizeFromFullScaff : (ScaffGraph) -> CGSize = { $0.bounds } >>> remove3rdDimFront
let sizeFromFullScaffSide : (ScaffGraph) -> CGSize = { $0.bounds } >>> remove3rdDimSide

let schematicSize : (ScaffGraph) -> CGSize3 = {
  CGSize3(width: CGFloat($0.grid.pX.count * 100),
          depth: CGFloat($0.grid.pY.count * 100),
          elev: CGFloat($0.grid.pZ.count * 100))
}
let sizeSchematicFront : (ScaffGraph) -> CGSize = schematicSize >>> remove3rdDimFront




func originSwap(origin: CGRect, height: CGFloat) -> CGPoint
{
  return CGPoint(origin.x, height - origin.y - origin.height)
}

let originFromGridScaff : (ScaffGraph, CGRect, CGFloat) -> CGPoint =
{ (scaff, newRect, boundsHeight) in
  // Find Orirgin
  var origin = (newRect, boundsHeight) |> originSwap
 return ((origin, unitY * -scaff.boundsOfGrid.1) |>  moveByVector)
}
let originFromFullScaff : (ScaffGraph, CGRect, CGFloat) -> CGPoint =
{ (graph, newRect, boundsHeight) in
  // Find Orirgin
  
  return (newRect, boundsHeight) |> originSwap

}


func rotateGroup<T>(_ a: [C2Edge<T>]) -> [C2Edge<T>]{ a.map(rotate) }
func rotate<A>( edge: C2Edge<A>) -> C2Edge<A> {
  return C2Edge(content: edge.content, p1: edge.p1 |> flip, p2: edge.p2 |> flip )
}
func flip( point: CGPoint) -> CGPoint
{
  return CGPoint(point.y, point.x)
}
func flip( size: CGSize) -> CGSize
{
  return CGSize(size.height, size.width)
}


// 2D Dim Plan grid stuff ...
func graphToNonuniformPlan(gp: GraphPositions) -> NonuniformModel2D {
  return NonuniformModel2D(origin: CGPoint.zero, rowSizes: Grid(gp.pY |> posToSeg), colSizes: Grid(gp.pX |> posToSeg))
}

func graphToNonuniformFront(gp: GraphPositions) -> NonuniformModel2D {
  return NonuniformModel2D(origin: CGPoint.zero, rowSizes: Grid(gp.pZ |> posToSeg), colSizes: Grid(gp.pX |> posToSeg))
}
func graphToNonuniformSide(gp: GraphPositions) -> NonuniformModel2D {
  return NonuniformModel2D(origin: CGPoint.zero, rowSizes: Grid(gp.pZ |> posToSeg), colSizes: Grid(gp.pY |> posToSeg))
}


func edgesToPoints(edges: [C2Edge<ScaffType>]) -> [CGPoint] {
  
  let cgPoints = edges.flatMap {
    c2Edge -> [CGPoint] in
    return [c2Edge.p1, c2Edge.p2]
  }
  return cgPoints
}

 func removeDup<A : Equatable> (edges: [A]) -> [A] {
  return edges.reduce([])
  {
    res, next in
    guard !res.contains(next) else { return res }
    return res + [next]
  }
}

func leftToRightDict(points: [CGPoint]) -> [CGFloat : [CGFloat]] {
  let yOrientedDict : [CGFloat : [CGFloat] ] = [ :]
  let pointDict = points.reduce(yOrientedDict) {
    (res, next) in
    var newRes = res
    let arr = newRes[next.y] ?? []
    newRes[next.y] =  arr +  [next.x]
    return newRes
  }
  return pointDict
}

func pointDictToArray( dict: [CGFloat : [CGFloat]] ) -> [[CGPoint]]
{
  return dict.keys.sorted().map {
    key in
   return  dict[key]!.map { value in
      return CGPoint(value, key)
    }
  }
}


struct PositionsOrdered2D {
  let x: [CGFloat]
  let y: [CGFloat]
  init (x: [CGFloat], y: [CGFloat]) {
    self.x = x.sorted()
    self.y = y.sorted()
  }
}

func plan(gp: GraphPositions) -> (PositionsOrdered2D) {
  return PositionsOrdered2D(x: gp.pX, y: gp.pY)
}
func rotatedPlan(gp: GraphPositions) -> (PositionsOrdered2D) {
  return PositionsOrdered2D(x: gp.pY, y: gp.pX)
}
func front(gp: GraphPositions) -> (PositionsOrdered2D) {
  return PositionsOrdered2D(x: gp.pX, y: gp.pZ)
}
func side(gp: GraphPositions) -> (PositionsOrdered2D) {
  return PositionsOrdered2D(x: gp.pY, y: gp.pZ)
}
func graphToCorners(gp: PositionsOrdered2D) -> Corners {
  return (top: gp.y.last!, right: gp.x.last!, bottom: gp.y.first!, left: gp.x.first!)
}

func rotateUniform(nu: NonuniformModel2D)-> NonuniformModel2D {
  return NonuniformModel2D(origin: nu.origin, rowSizes: nu.colSizes, colSizes: nu.rowSizes)
}

func boundedBy(from positions: PositionsOrdered2D) -> BorderPoints {
  let firstX =   positions.x.map{ CGPoint(x: $0, y: positions.y.first!) }
  let right =  positions.y.map{ CGPoint(x: positions.x.last!, y:$0)  }
  let lastX =  positions.x.map{ CGPoint(x: $0, y: positions.y.last!) }
  let left =  positions.y.map{ CGPoint(x: positions.x.first!, y:$0)  }
  return BorderPoints(
    top: lastX,
    right: right,
    bottom: firstX,
    left: left
  )
}

public typealias Corners = (top: CGFloat, right: CGFloat, bottom:  CGFloat, left: CGFloat)

public func borders(from corners: Corners) -> BorderPoints {
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

