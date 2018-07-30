//
//  Scaffolding.swift
//  Meccano
//
//  Created by Justin Smith on 7/29/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Graphe
import BlackCricket
import Singalong
import Geo

func modelToTexturesElev ( edges: [C2Edge] ) -> [Geometry]
{
  let horizontals = edges.filter{ $0.content == .ledger}.map
  {
    ledge in
    return (ledge.p1, ledge.p2) |>
      {
        (a, b) -> Scaff2D in
        return Scaff2D(start: a, end: b, part: .ledger, view: .longitudinal)
    }
  }
  
  let verticals = edges.filter{ $0.content == .standardGroup}.flatMap
  {
    line  -> [Scaff2D] in
    
    let lengths = maximumStandards(in: abs( (line.p1 + line.p2).diagonalExtent ) )
    let pos = lengths |> curry(segToPosOrigin)(line.p1.y)
    let s : [Scaff2D] = zip(pos, pos.dropFirst()).map {
      let s =       Scaff2D(start: CGPoint( line.p1.x, $0.0), end: CGPoint( line.p2.x, $0.1), part: .standard, view: .longitudinal)
      
      
      return s
    }
    return s
  }
  let base = edges.filter{ $0.content == .bc}.map
  {
    
    return Scaff2D(start: $0.p1 ,
                   end: $0.p2, part: .basecollar, view: .longitudinal)
    
  }
  let jack = edges.filter{ $0.content == .jack}.map
  {
    return Scaff2D(start: $0.p1 ,
                   end: $0.p2, part: .jack, view: .longitudinal)
  }
  let diag = edges.filter{ $0.content == .diag}.map
  {
    return Scaff2D(start: $0.p1 ,
                   end: $0.p2, part: .diag, view: .longitudinal)
  }
  
  return horizontals + verticals + base + jack + diag
  
}


struct Scaff2D {
  enum ScaffType
  {
    case ledger
    case basecollar
    case jack
    case diag
    case standard
  }
  enum DrawingType
  {
    case plan
    case cross
    case longitudinal
  }
  
  var start: CGPoint
  var end: CGPoint
  let part : ScaffType
  let view : DrawingType
}
extension Scaff2D : Geometry {
  var position: CGPoint {
    get { return (self.start + self.end).center }
    set(newValue){
      let previous = (self.start + self.end).center
      let dif = newValue - previous
      start = start + dif
      end = end + dif
    }
  }
}
extension Scaff2D {
  var upToTheRight : Bool  {
    return start.x < end.x && start.y < end.y
  }
}

extension Scaff2D : CustomStringConvertible {
  var description: String {
    return "\(part) \(view) - \(CGSegment(p1:start, p2:end).length), \(position)"
  }
}

// Used to be view controller




let planEdgeToGeometry : ([C2Edge]) -> [Scaff2D] = { edges in
  return edges.map { edge in
    switch edge.content
    {
    case .standardGroup : return Scaff2D(start: edge.p1, end: edge.p2, part: .standard, view: .plan)
    case .jack : return Scaff2D(start: edge.p1, end: edge.p2, part: .jack, view: .plan)
    case .ledger : return Scaff2D(start: edge.p1, end: edge.p2, part: .ledger, view: .plan)
    case .bc : return Scaff2D(start: edge.p1, end: edge.p2, part: .basecollar, view: .plan)
      
    default :
      fatalError("Some other type showed up")
    }
    
  }
}

