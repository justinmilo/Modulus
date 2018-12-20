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
  get(\.planEdgesNoZeros)
    >>> planEdgeToGeometry
    >>> map(toGeometry)


let rotatedPlanGrid : ViewComposite =
  get(\ScaffGraph.planEdgesNoZeros)
    >>> rotateGroup
    >>> planEdgeToGeometry
    >>> map(toGeometry)



let frontComposite : ViewComposite =
  get(\.frontEdgesNoZeros)
    >>> modelToTexturesElev

let sideComposite : ViewComposite =
  get(\.sideEdgesNoZeros)
    >>> modelToTexturesElev

// Dimension Composites

let planDimensions : ViewComposite =
  get(\.grid)
    >>> graphToNonuniformPlan
    >>> nonuniformToPoints
    >>> pointCollectionToDimLabel
    >>> map(toGeometry)

let rotatedPlanDim : ViewComposite =
  get(\.grid)
    >>> graphToNonuniformPlan
    >>> rotateUniform
    >>> nonuniformToPoints
    >>> pointCollectionToDimLabel
    >>> map(toGeometry)


let frontDim : ViewComposite =
  get(\.grid)
    >>> front
    >>> boundedBy
    >>> dimension(13.3, formatter: floatMetricFormatter)

let frontDimImp : ViewComposite =
  get(\.grid)
    >>> front
    >>> boundedBy
    >>> dimension(13.3, formatter: floatImperialFormatter)

let sideDim : ViewComposite =
  get(\.grid)
    >>> side
    >>> boundedBy
    >>> dimension(13.3, formatter: floatMetricFormatter)

let frontOuterDimensions =
  get(\ScaffGraph.grid)
    >>> front
    >>> graphToCorners
    >>> borders
    >>> dimension(30, formatter: floatMetricFormatter)

let frontOuterDimImp =
  get(\ScaffGraph.grid)
    >>> front
    >>> graphToCorners
    >>> borders
    >>> dimension(30, formatter: floatImperialFormatter)

func dimGraphBy(
  slice: @escaping (GraphPositions) -> (PositionsOrdered2D),
  formatter: @escaping DimFormat) -> ViewComposite {
  return get(\.grid)
    >>> slice
    >>> boundedBy
    >>> dimension(13.3, formatter: formatter)
}

let innerDim : (@escaping (CGFloat) -> String) -> (PositionsOrdered2D)->[Label] = {
  boundedBy
  >>> dimension(13.3, formatter: $0)
}

let outerDim =
    graphToCorners
    >>> borders
    >>> dimension(30, formatter: floatMetricFormatter)

let graphFrontGrid =
  get(\ScaffGraph.grid)
    >>> front

let graphSideGrid =
  get(\ScaffGraph.grid)
    >>> side
