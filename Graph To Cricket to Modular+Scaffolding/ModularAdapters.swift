//
//  ModularAdapters.swift
//  Meccano
//
//  Created by Justin Smith on 7/29/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation
import BlackCricket
import Graphe
import Geo

func modelToLinework ( edges: [C2Edge] ) -> [Geometry]
{
  let lines : [Geometry] = edges.map { edge in
    return Line(start: edge.p1, end: edge.p2)
  }
  
  let labels = edges.map { edge -> Label in
    let direction : Label.Rotation = edge.content == .ledger || edge.content == .diag ? .h : .v
    let vector = direction == .h ? unitY * 10 : unitX * 10
    return Label(text: edge.content.rawValue, position: (edge.p1 + edge.p2).center + vector, rotation: direction)
  }
  
  let labelsSecondPass : [Geometry] = labels.reduce([])
  {
    (res, geo) -> [Label] in
    
    if res.contains(where: {
      
      let r = CGRect.around($0.position, size: CGSize(40,40))
      return r.contains(geo.position)
      
    })
    {
      var new = geo
      new.position = new.position + CGVector(dx: 15, dy: 15)
      return res + [new]
    }
    
    return res + [geo]
  }
  
  
  /// Move to orign
  
  
  
  return (lines + labelsSecondPass)
}
