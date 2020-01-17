//
//  ScallopComposite.swift
//  Modular
//
//  Created by Justin Smith Nussli on 1/15/20.
//  Copyright © 2020 Justin Smith. All rights reserved.
//

import Foundation
import GrapheNaked
import Singalong

typealias ConsumerEdgesSc = (ScallopGraph) -> [C2Edge<ScallopParts>]
let plan2DSc : ConsumerEdgesSc = { ($0.grid, $0.edges) } >>> cedges >>> plan  >>> reduceDup
let plan2DRSc : ConsumerEdgesSc = { ($0.grid, $0.edges) } >>> cedges >>> plan >>> reduceDup
let front2DSc : ConsumerEdgesSc = { ($0.grid, $0.edges) } >>> cedges >>> front  >>> reduceDup
let side2DSc : ConsumerEdgesSc = { ($0.grid, $0.edges) } >>> cedges >>> side  >>> reduceDup

typealias ScallopEdge2D = C2Edge<ScallopParts>
typealias ScallopEdges2D = [C2Edge<ScallopParts>]

import Geo
@testable import BlackCricket
let planLabelScallop : (ScallopEdge2D)->Label = { (edge) -> Label in
  let direction : Label.Rotation = edge.content == ScallopParts.glassWall ? .h : .v
  let vector = direction == .h ? Geo.unitY * 10 : Geo.unitX * -10
  return Label(text: edge.content.rawValue, position: (edge.p1 + edge.p2).center + vector, rotation: direction)
}
func lines(item: ScallopEdge2D) -> Line {
   return Line(p1: item.p1, p2: item.p2)
 }

let sc_planLabels : (ScallopEdges2D)->[Label] = { $0.map(planLabelScallop).secondPassLayout() }
let sc_joints :  (ScallopEdges2D)->[CGPoint] = { $0.reduce([]) { (res, edge) -> [CGPoint] in
  var res = res
  if !res.contains(edge.p1) {
    res.append(edge.p1)
  }
  if !res.contains(edge.p2) {
    res.append(edge.p2)
  }
  return res
  }
}

let scallopLinesLabelsPlan : (ScallopEdges2D) -> Composite =
  sc_planLabels
    >>> Composite.init
    <> (sc_joints
      >>> jointNodes)
    >>> Composite.init
    <> { $0.map(lines) }
    >>> Composite.init
