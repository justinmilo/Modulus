//
//  ViewFunctions.swift
//  HandlesRound1
//
//  Created by Justin Smith on 2/10/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import CoreGraphics



struct GraphMapping {
  var f_flattenGraph: (ScaffGraph) -> [C2Edge]
  var f_edgesToTexture: ([C2Edge], CGPoint) -> [Geometry]
  var f_graphToSize: (ScaffGraph) -> CGSize
  var f_sizeToGraph: (CGSize) -> (GraphPositions, [Edge])
}


func originSwap(origin: CGRect, height: CGFloat) -> CGPoint
{
  return CGPoint(origin.x, height - origin.y - origin.height)
}

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
  let aligned = master.withInsetRect( ofSize: scaffSize, hugging:  (positions.0.oposite, positions.1.oposite))
  
  return (aligned)
}

let findOrigin : (CGPoint, CGFloat) -> (CGPoint) = {
  aligned, adapterHeight in
  
  let offsetFromScrewJack = aligned + unitY * adapterHeight
  return offsetFromScrewJack
}

//
let planScaff : (CGSize) -> (GraphPositions, [Edge]) = addElevDim >>> createScaffolding
let fullScaff : (CGSize) -> (GraphPositions, [Edge]) = add3rdDim >>> createScaffolding
let gridScaff : (CGSize) -> (GraphPositions, [Edge]) = add3rdDim >>> createGrid

let sizeFromPlanScaff : (ScaffGraph) -> CGSize = { $0.bounds } >>> remove3rdDimPlan
let sizeFromGridScaff : (ScaffGraph) -> CGSize = { $0.boundsOfGrid.0 } >>> remove3rdDim
let sizeFromFullScaff : (ScaffGraph) -> CGSize = { $0.bounds } >>> remove3rdDim
let sizeFromFullScaffSide : (ScaffGraph) -> CGSize = { $0.bounds } >>> remove3rdDimSide

let originFromGridScaff : (ScaffGraph, CGRect, CGFloat) -> CGPoint =
{ (graph, newRect, boundsHeight) in
  // Find Orirgin
  
  var origin = (newRect, boundsHeight) |> originSwap
  origin = ((origin, graph.boundsOfGrid.1) |>  findOrigin)
  return origin
}
let originFromFullScaff : (ScaffGraph, CGRect, CGFloat) -> CGPoint =
{ (graph, newRect, boundsHeight) in
  // Find Orirgin
  
  var origin = (newRect, boundsHeight) |> originSwap
  return origin
}
