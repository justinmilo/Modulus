//
//  ViewFunctions.swift
//  HandlesRound1
//
//  Created by Justin Smith on 2/10/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import CoreGraphics

func log<A>(m: A) -> A
{
  print(m)
  return m
}



let remove3rdDim : (CGSize3) -> CGSize = {
  return CGSize(width: $0.width, height:  $0.elev)
}
let remove3rdDimSide : (CGSize3) -> CGSize = {
  return CGSize(width: $0.depth, height:  $0.elev)
}
let remove3rdDimPlan : (CGSize3) -> CGSize = {
  return CGSize(width: $0.width, height:  $0.depth)
}


func bindSize( master: CGRect, scaffSize: CGSize, positions: (VerticalPosition, HorizontalPosition)) -> (CGRect)
{
  // Find Orirgin
  return master.withInsetRect( ofSize: scaffSize, hugging:  (positions.0.oposite, positions.1.oposite))
}

let findOrigin : (CGPoint, CGFloat) -> (CGPoint) = {
  aligned, adapterHeight in
  return aligned + unitY * adapterHeight // offsetFromScrewJack
}



//

let sizeFromPlanScaff : (ScaffGraph) -> CGSize = { $0.bounds } >>> remove3rdDimPlan
let sizeFromRotatedPlanScaff : (ScaffGraph) -> CGSize = { $0.bounds } >>> remove3rdDimPlan >>> flip
let sizeFromGridScaff : (ScaffGraph) -> CGSize = { $0.boundsOfGrid.0 } >>> remove3rdDim
let sizeFromFullScaff : (ScaffGraph) -> CGSize = { $0.bounds } >>> remove3rdDim
let sizeFromFullScaffSide : (ScaffGraph) -> CGSize = { $0.bounds } >>> remove3rdDimSide





// 2D Dim Plan grid stuff ...
func planGrids(gp: GraphPositions) -> (CGPoint) -> NonuniformModel2D
{
  return { point in NonuniformModel2D(origin: point, rowSizes: Grid(gp.pY |> posToSeg), colSizes: Grid(gp.pX |> posToSeg)) }
}
let plguncur = uncurry(planGrids)
let planUncurryed = plguncur >>> basic
let curryasd = curry(detuple(planUncurryed))



let planGridsToDimensions : (ScaffGraph) -> (CGPoint) -> [Geometry] = { $0.grid } >>> curryasd
// ... End 2d dim plan gridd stuf


func originSwap(origin: CGRect, height: CGFloat) -> CGPoint
{
  return CGPoint(origin.x, height - origin.y - origin.height)
}

let originFromGridScaff : (ScaffGraph, CGRect, CGFloat) -> CGPoint =
{ (scaff, newRect, boundsHeight) in
  // Find Orirgin
  var origin = (newRect, boundsHeight) |> originSwap
 return ((origin, scaff.boundsOfGrid.1) |>  findOrigin)
}
let originFromFullScaff : (ScaffGraph, CGRect, CGFloat) -> CGPoint =
{ (graph, newRect, boundsHeight) in
  // Find Orirgin
  
  return (newRect, boundsHeight) |> originSwap

}


let rotateGroup : ([C2Edge]) -> [C2Edge] = { $0.map(rotate) }
func rotate( edge: C2Edge) -> C2Edge {
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

