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


let planLinework : ViewComposite =
  get(\ScaffGraph.grid)
    >>> graphToNonuniformPlan
    >>> basic

let planComposite :  ViewComposite =
  get(\ScaffGraph.planEdgesNoZeros)
    >>> planEdgeToGeometry
    >>> map(toGeometry)

let planDimensions : ViewComposite =
  get(\.grid)
    >>> graphToNonuniformPlan
    >>> nonuniformToDimensions


let rotatedPlanGrid : ViewComposite =
  get(\ScaffGraph.planEdgesNoZeros)
    >>> rotateGroup
    >>> planEdgeToGeometry
    >>> map(toGeometry)

let rotatedPlanDim : ViewComposite =
  get(\.grid)
    >>> graphToNonuniformPlan
    >>> rotateUniform
    >>> nonuniformToDimensions

let frontComposite : ViewComposite =
  get(\.frontEdgesNoZeros)
    >>> modelToTexturesElev

let sideComposite : ViewComposite =
  get(\.sideEdgesNoZeros)
    >>> modelToTexturesElev

let frontDim : ViewComposite =
  get(\.grid)
    >>> graphToNonuniformFront
    >>> dimensionsMetric

let frontDimImp : ViewComposite =
  get(\.grid)
    >>> graphToNonuniformFront
    >>> dimensionsImperial

let sideDim : ViewComposite =
  get(\.grid)
    >>> graphToNonuniformSide
    >>> dimensionsMetric

let outerDimensions =
  graphToCorners
    >>> borders
    >>> dimension(30, formatter: floatMetricFormatter)

let overallDimensionsImp =
  graphToCorners
    >>> borders
    >>> dimension(30, formatter: floatImperialFormatter)

let frontGraph : (ScaffGraph) -> GraphPositionsOrdered2D =
  get(\.grid)
    >>> graphToFrontGraph2D

let frontOuterDimensions =
  frontGraph
    >>> outerDimensions

let frontOuterDimImp =
  frontGraph
    >>> overallDimensionsImp
