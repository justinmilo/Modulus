//
//  ViewComposite.swift
//  HandlesRound1
//
//  Created by Justin Smith on 2/24/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//
import CoreGraphics
import Singalong
import Graphe
import BlackCricket

typealias ViewComposite = (ScaffGraph) -> [Geometry]

let front1 : ViewComposite = { $0.frontEdgesNoZeros } >>> modelToTexturesElev
let frontDim : ViewComposite = { $0.grid } >>> graphToNonuniformFront >>> dimensons

let frontEdges : (ScaffGraph) -> [C2Edge] = { ($0.grid, $0.edges) |> frontSection().parse }
let sideEdges : (ScaffGraph) -> [C2Edge] = { ($0.grid, $0.edges) |> sideSection().parse }
let planEdges : (ScaffGraph) -> [C2Edge] = { ($0.grid, $0.edges) |> planSection().parse }
let removedStandards : ([C2Edge]) -> [C2Edge] = { $0.filter(fStandard >>> opposite) }
let frontPointsWOutStandards = frontEdges >>> removedStandards >>> edgesToPoints
let sidePointsWOutStandards = sideEdges >>> removedStandards >>> edgesToPoints
let planPoint = planEdges >>> edgesToPoints

func positionsIn(edges: [C2Edge]) -> GraphPositions2DSorted {
  return GraphPositions2DSorted(
    pX: edges.flatMap{ [$0.p1.x] + [$0.p2.x] } |> removeDup,
    pY: edges.flatMap{ [$0.p1.y] + [$0.p2.y] } |> removeDup
)
}
let frontPositionsOhneStandards = frontEdges >>> removedStandards >>> positionsIn
let sidePositionsOhneStandards = sideEdges >>> removedStandards >>> positionsIn
let planPositions = planEdges >>> log >>> positionsIn
let rotatedPlanPositions = planEdges >>> rotateGroup >>> positionsIn

let test = edgesToPoints >>> removeDup >>> leftToRightDict >>> pointDictToArray >>> leftToRightToBorders 

let outerDimensions =
  edgesToPoints
    >>> removeDup
    >>> leftToRightDict
    >>> pointDictToArray
    >>> leftToRightToBorders
    >>> { return ($0.left |> dimLeft(30.0)) + ($0.right |> dimRight(30.0)) }
    >>> { $0.map{ $0 as Geometry} }
let frontOuterDimPlus : ViewComposite =
  frontEdges >>> removedStandards >>> outerDimensions
let side1 : ViewComposite = { $0.sideEdgesNoZeros} >>> modelToTexturesElev
let sideDim : ViewComposite = { $0.grid } >>> graphToNonuniformSide >>> dimensons
let sideDoubleDim : ViewComposite = sideEdges >>> removedStandards >>> outerDimensions
let frontGraph : (ScaffGraph) -> GraphPositionsOrdered2D =  { $0.grid } >>> graphToFrontGraph2D
let overallDimensions = graphToCorners >>> borders >>> dimension(40)

let frontFinal = front1 <> frontDim <> frontOuterDimPlus
let frontOverall = frontGraph >>> overallDimensions
