//
//  CompositeButtons.swift
//  Modular
//
//  Created by Justin Smith on 12/25/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation
import BlackCricket
import Singalong
import Geo

func id<T>(_ id : T)-> T { return id }



func segments(from positions: [CGPoint])-> [CGSegment]{
  return zip(positions, positions.dropFirst()).map(CGSegment.init)
}
func midpoints(from segments: [CGSegment])-> [CGPoint]{
  return segments.map(get(\CGSegment.midpoint))
}




import GrapheNaked
struct RandoStruct {
  var foo: String
}
func responderF(_ pt: CGPoint) -> ScaffGraph {
  return ScaffGraph()
}

