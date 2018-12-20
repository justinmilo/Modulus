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

/*
 
 
 NonuniformModel2D
 */

typealias ViewComposite = (ScaffGraph) -> [Geometry]

let planLinework : ViewComposite =
  get(\ScaffGraph.grid)
    >>> graphToNonuniformPlan
    >>> basic

let planComposite : ViewComposite =
  get(\ScaffGraph.planEdgesNoZeros)
    >>> planEdgeToGeometry
    >>> map(toGeometry)

let planDimensions : ViewComposite =
  get(\.grid)
    >>> graphToNonuniformPlan
    >>> nonuniformToPoints
    >>> pointCollectionToDimLabel
    >>> map(toGeometry)


let rotatedPlanGrid : ViewComposite =
  get(\ScaffGraph.planEdgesNoZeros)
    >>> rotateGroup
    >>> planEdgeToGeometry
    >>> map(toGeometry)

let rotatedPlanDim : ViewComposite =
  get(\.grid)
    >>> graphToNonuniformPlan
    >>> rotateUniform
    >>> nonuniformToPoints
    >>> pointCollectionToDimLabel
    >>> map(toGeometry)

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

//let frontDimImp : ViewComposite =
//  get(\.grid)
//    >>> graphToNonuniformFront
//    >>> dimensionsImperial

let frontDimImp : ViewComposite =
  get(\ScaffGraph.grid)
    >>> graphToFrontGraph2D
    >>> borders
    >>> dimension(13.3, formatter: floatImperialFormatter)

let sideDim : ViewComposite =
  get(\.grid)
    >>> graphToNonuniformSide
    >>> dimensionsMetric

let frontOuterDimensions =
  get(\ScaffGraph.grid)
    >>> graphToFrontGraph2D
    >>> graphToCorners
    >>> borders
    >>> dimension(30, formatter: floatMetricFormatter)

let frontOuterDimImp =
  get(\ScaffGraph.grid)
    >>> graphToFrontGraph2D
    >>> graphToCorners
    >>> borders
    >>> dimension(30, formatter: floatImperialFormatter)
