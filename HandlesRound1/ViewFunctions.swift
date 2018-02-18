//
//  ViewFunctions.swift
//  HandlesRound1
//
//  Created by Justin Smith on 2/10/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import CoreGraphics




let addElevDim : (CGSize) -> CGSize3 = {
  return CGSize3(width: $0.width, depth: $0.height, elev : 300)
}
let add3rdDim : (CGSize) -> CGSize3 = {
  return CGSize3(width: $0.width, depth: 400, elev : $0.height)
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
let planScaff : (CGSize) -> (GraphPositions, [Edge]) = addElevDim >>> createScaffolding
let fullScaff : (CGSize) -> (GraphPositions, [Edge]) = add3rdDim >>> createScaffolding
let gridScaff : (CGSize) -> (GraphPositions, [Edge]) = add3rdDim >>> createGrid

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

func log(m: NonuniformModel2D) -> NonuniformModel2D
{
  print(m)
  return m
}

let planUncurryed = plguncur >>> log >>> basic
let curryasd = curry(detuple(planUncurryed))

func detuple<A,B,C>(_ t: @escaping ((A,B))->C)->(A,B)->C
{
  return { a,b in
    return t((a,b))
  }
}

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



let full = (fullScaff, sizeFromFullScaff, originFromFullScaff)
let grid =  (gridScaff, sizeFromGridScaff, originFromGridScaff)
