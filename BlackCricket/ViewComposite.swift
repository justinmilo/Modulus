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

public struct Composite {
  public var geometry : [Geometry]
  public var operators : [OvalResponder]
  public var labels : [Label]
}

public extension Composite {
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

import Singalong
extension Composite : Semigroup {
  public static func <>(lhs: Composite, rhs: Composite) -> Composite {
    return Composite(
      geometry: lhs.geometry + rhs.geometry,
      operators: lhs.operators + rhs.operators,
      labels: lhs.labels + rhs.labels
    )
  }
}

