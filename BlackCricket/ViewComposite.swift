//
//  ViewComposite.swift
//  HandlesRound1
//
//  Created by Justin Smith on 2/24/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//
import CoreGraphics
import Singalong
import GrapheNaked

/*
 
 
 NonuniformModel2D
 */

public struct Composite {
  public var geometry : [Geometry]
  public var labels : [Label]
  public init(geometry: [Geometry], labels: [Label]) {
    self.geometry = geometry
    self.labels = labels
  }
}

public extension Composite {
  
  init(geometry: [Geometry]) {
    self.geometry = geometry
    self.labels = []

  }
  init(labels: [Label]) {
    self.geometry = []
    self.labels = labels
  }
}

import Singalong
extension Composite : Semigroup {
  public static func <>(lhs: Composite, rhs: Composite) -> Composite {
    return Composite(
      geometry: lhs.geometry + rhs.geometry,
      labels: lhs.labels + rhs.labels
    )
  }
}

