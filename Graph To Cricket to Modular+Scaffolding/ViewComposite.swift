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

let rotatedPlanLinework : ViewComposite =
  get(\ScaffGraph.grid)
    >>> graphToNonuniformPlan
    >>> rotateUniform
    >>> basic

let planComposite : ViewComposite =
  get(\.planEdgesNoZeros)
    >>> planEdgeToGeometry
    >>> map(toGeometry)


let rotatedPlanComposite : ViewComposite =
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

let innerDim : (@escaping (CGFloat) -> String) -> (PositionsOrdered2D)->[Label] = {
  boundedBy
  >>> dimension(13.3, formatter: $0)
}

let outerDim : (@escaping (CGFloat) -> String) -> (PositionsOrdered2D)->[Label] = {
    graphToCorners
    >>> borders
    >>> dimension(30, formatter: $0)
}

let frontGrid =
  get(\ScaffGraph.grid)
    >>> front

let sideGrid =
  get(\ScaffGraph.grid)
    >>> side

let planGrid =
  get(\ScaffGraph.grid)
    >>> plan

let rotatedPlanGrid =
  get(\ScaffGraph.grid)
    >>> rotatedPlan
