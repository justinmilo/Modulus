//
//  ModularAdapters.swift
//  Meccano
//
//  Created by Justin Smith on 7/29/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation
import BlackCricket
import GrapheNaked
import Geo

func modelToLinework ( edges: [C2Edge<ScaffType>] ) -> Composite
{
  let lines : [Geometry] = edges.map { edge in
    return Line(start: edge.p1, end: edge.p2)
  }
  
  let labels = edges.map { edge -> Label in
    let direction : Label.Rotation = edge.content == .ledger || edge.content == .diag ? .h : .v
    let vector = direction == .h ? unitY * 10 : unitX * 10
    return Label(text: edge.content.rawValue, position: (edge.p1 + edge.p2).center + vector, rotation: direction)
  }
  
  let labelsSecondPass : [Label] = labels.secondPassLayout()
  
  /// Move to orign
  
  
  return Composite(
    geometry : lines,
   labels : labelsSecondPass
  )
}
