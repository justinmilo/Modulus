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


let everyPositionButon : (PositionsOrdered2D) -> Composite = boundedBy >>> explode >>> Composite.init(operators:)

import Graphe
struct RandoStruct {
  var foo: String
}
func responderF(_ pt: CGPoint) -> ScaffGraph {
  return ScaffGraph()
}

func explode(border: BorderPoints) -> [OvalResponder] {
  let mids = segments >>> midpoints
  
  let topPoints : [CGPoint] = mids(border.top) |> map(50 |> yMove)
  let rightPoints =  combo( border.right |> mids, [unitX * 50], with: moveByVector)
  let bottomPoints = combo( border.bottom |> mids, [unitY * -50], with: moveByVector)
  let leftPoints = combo( border.left |> mids, [unitX * -50], with: moveByVector)
  
  let newPoints = topPoints + rightPoints + bottomPoints + leftPoints
  let ovals = combo(
    [CGSize(width: 50, height: 50)],
    newPoints,
    [responderF],
    with: OvalResponder.init
  )
  return ovals
}
