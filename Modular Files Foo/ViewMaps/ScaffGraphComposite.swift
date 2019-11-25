//
//  ScaffGraphComposite.swift
//  Modular
//
//  Created by Justin Smith Nussli on 11/24/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import Foundation

typealias ViewComposite = (ScaffGraph) -> Composite

let planLinework : ViewComposite =
  get(\ScaffGraph.grid)
    >>> graphToNonuniformPlan
    >>> basic
    >>> Composite.init(geometry:)

let rotatedPlanLinework : ViewComposite =
  get(\ScaffGraph.grid)
    >>> graphToNonuniformPlan
    >>> rotateUniform
    >>> basic
    >>> Composite.init(geometry:)

let planComposite : ViewComposite =
  get(\.planEdgesNoZeros)
    >>> planEdgeToGeometry
    >>> map(toGeometry)
    >>> Composite.init(geometry:)


let rotatedPlanComposite : ViewComposite =
  get(\ScaffGraph.planEdgesNoZeros)
    >>> rotateGroup
    >>> planEdgeToGeometry
    >>> map(toGeometry)
    >>> Composite.init(geometry:)

let frontComposite : ViewComposite =
  get(\.frontEdgesNoZeros)
    >>> modelToTexturesElev
    >>> Composite.init(geometry:)

let sideComposite : ViewComposite =
  get(\.sideEdgesNoZeros)
    >>> modelToTexturesElev
    >>> Composite.init(geometry:)

// Dimension Composites

let innerDim : (@escaping (CGFloat) -> String) -> (PositionsOrdered2D)->Composite = {
  boundedBy
  >>> dimension(13.3, formatter: $0)
  >>> Composite.init(labels:)
}

let outerDim : (@escaping (CGFloat) -> String) -> (PositionsOrdered2D)->Composite = {
    graphToCorners
    >>> borders
    >>> dimension(30, formatter: $0)
      >>> Composite.init(labels:)
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
