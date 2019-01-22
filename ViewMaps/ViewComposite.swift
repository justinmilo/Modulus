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

struct Composite {
  var geometry : [Geometry]
  var operators : [OvalResponder]
  var labels : [Label]
}

extension Composite {
  init(geometry: [Geometry]) {
    self.geometry = geometry
    self.operators = []
    self.labels = []

  }
  init(operators: [OvalResponder]) {
    self.geometry = []
    self.operators = operators
    self.labels = []
  }
  init(labels: [Label]) {
    self.geometry = []
    self.operators = []
    self.labels = labels
  }
}

extension Composite : Semigroup {
  static func <>(lhs: Composite, rhs: Composite) -> Composite {
    return Composite(
      geometry: lhs.geometry + rhs.geometry,
      operators: lhs.operators + rhs.operators,
      labels: lhs.labels + rhs.labels
    )
  }
}

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
