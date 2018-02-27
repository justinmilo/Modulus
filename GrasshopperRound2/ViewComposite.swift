//
//  ViewComposite.swift
//  HandlesRound1
//
//  Created by Justin Smith on 2/24/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//
import CoreGraphics

typealias ViewComposite = (ScaffGraph) -> (CGPoint) -> [Geometry]

let front1 : ViewComposite = { $0.frontEdgesNoZeros } >>> curry(modelToTexturesElev)
let frontDim : ViewComposite = { $0.grid } >>> graphToNonuniformFront >>> dimensons
let frontEdges : (ScaffGraph) -> [C2Edge] = { ($0.grid, $0.edges) |> frontSection().parse }
let removedStandards : ([C2Edge]) -> [C2Edge] = { $0.filter(fStandard >>> opposite) }
let frontPointsWOutStandards = frontEdges >>> removedStandards >>> edgesToPoints
let outerDimensions =
  edgesToPoints
    >>> removeDup
    >>> leftToRightDict
    >>> pointDictToArray
    >>> leftToRightToBorders
    >>> { return ($0.left |> dimLeft(30.0)) + ($0.right |> dimRight(30.0)) }
let movedGeometry : ([Geometry]) -> (CGPoint) -> [Geometry] = { g in return {p in return g.map { ($0, p.asVector()) |> move } } }
let frontOuterDimPlus : ViewComposite =
  frontEdges >>> removedStandards >>> outerDimensions >>> movedGeometry

let sideEdges : (ScaffGraph) -> [C2Edge] = { ($0.grid, $0.edges) |> sideSection().parse }
let side1 : ViewComposite = { $0.sideEdgesNoZeros} >>> curry(modelToTexturesElev)
let sideDim : ViewComposite = { $0.grid } >>> graphToNonuniformSide >>> dimensons
let sideDoubleDim : ViewComposite = sideEdges >>> removedStandards >>> outerDimensions >>> movedGeometry
let frontGraph : (ScaffGraph) -> GraphPositionsOrdered2D =  { $0.grid } >>> graphToFrontGraph2D
let overallDimensions = graphToCorners >>> borders >>> dimension(40)

let frontFinal = front1 <> frontDim <> frontOuterDimPlus
let frontOverall = frontGraph >>> overallDimensions >>> movedGeometry
