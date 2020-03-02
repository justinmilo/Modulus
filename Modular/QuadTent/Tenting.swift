//
//  Tenting.swift
//  Graph
//
//  Created by Justin Smith  on 11/18/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import Foundation
import Singalong

#warning("Not Used Yet")
public struct TentStructure {
  
  // gableSegments
  // |  |  |
  //  FRONT
  //    ^
  //  /   \
  // |     |
  // A  B  C   Positions
  // |  |  |
  //   1  2    Segments
  //    x      Width
  var gable : CGFloat  //        Width
  
  
  // bays
  //        SIDE                  FRONT
  // ___________________
  // |__|__|__|__|__|__|            /\
  // |  |  |  |  |  |  |           |  |
  //
  // A  B  C  D  E  F  G         Positions
  //   1  2  3  5  6  7          Segments
  var bays : [CGFloat] //        Segments

  
  // heights      Positions    Segments     Eave
  //     FRONT   _  C          2
  //      /\     _  B
  //     |  |                  1             z
  //     |  |    _  A
  //
  var eave :  CGFloat // Eave
}

@testable import GrapheNaked


public func createTentGridFromEaveHeiht(with bounding: CGSize3) -> (GraphPositions, [Edge<TentParts>]) {
  let opposite = tan(18.0 * CGFloat.pi / 180) * bounding.width/2
  let graphSegments = GraphSegments(
    sX: [bounding.width/2, bounding.width/2],
    sY: ([400], bounding.depth) |> maximumRepeated,
    sZ: [bounding.elev, opposite]
  )
  let pos = graphSegments |> segToPos
  let edges = addTentParts(grid:pos)
  return (pos, edges)
}
public func createTentGridFromRidgeHeight(with bounding: CGSize3, baySize: CGFloat=400) -> (GraphPositions, [Edge<TentParts>]) {
  let opposite = tan(18.0 * CGFloat.pi / 180) * bounding.width/2
  let graphSegments = GraphSegments(
    sX: [bounding.width/2, bounding.width/2],
    sY: ([baySize], bounding.depth) |> maximumRepeated,
    sZ: [bounding.elev-opposite, opposite]
  )
  let pos = graphSegments |> segToPos
  let edges = addTentParts(grid:pos)
  return (pos, edges)
}

public enum TentParts : String, Codable, Hashable {
    case base = "Base"
    case leg = "Leg"
    case rafter = "Rafter"
//    case xbrace = "X-Brace"
    case purlin = "Purlin"
}

func addTentParts(grid:GraphPositions)->[Edge<TentParts>] {
  precondition(grid.pX.count == 3)
  precondition(grid.pZ.count == 3)
  
  let basePlates : [Edge<TentParts>] = (grid.pY.count) |>
  { (max) in
    let left = (0 ..< max).map{ y in
      return Edge<TentParts>(content: .base, p1: (0,y,0), p2: (0,y,0))
    }
    let right = (0 ..< max).map{ y in
      return Edge<TentParts>(content: .base, p1: (2,y,0), p2: (2,y,0))
    }
    return left + right
  }
  
  let legs : [Edge<TentParts>] = (grid.pY.count) |> { (yMax) in
    let leftLegs = (0 ..< yMax).map{ y in
      return Edge<TentParts>(content: TentParts.leg, p1: (0,y,0), p2: (0,y,1))
    }
    let rightLegs = (0 ..< yMax).map{ y in
      return Edge<TentParts>(content: TentParts.leg, p1: (2,y,0), p2: (2,y,1))
    }
    return leftLegs + rightLegs
  }
  
  let rafter : [Edge<TentParts>] = (grid.pY.count) |> { (yMax) in
    let leftRafters = (0 ..< yMax).map{ y in
      return Edge<TentParts>(content: TentParts.rafter, p1: (0,y,1), p2: (1,y,2))
    }
    let rightRafters = (0 ..< yMax).map{ y in
      return Edge<TentParts>(content: TentParts.rafter, p1: (1,y,2), p2: (2,y,1))
    }
    return leftRafters + rightRafters
  }
  
  let purlins : [Edge<TentParts>] = {
    guard grid.pY.count > 1 else { return [] }
    return(0 ..< grid.pY.count-1).flatMap{ y in
      return [Edge<TentParts>(content: .purlin, p1: (0,y,1), p2: (0,y+1,1)),
              Edge<TentParts>(content: .purlin, p1: (1,y,2), p2: (1,y+1,2)),
              Edge<TentParts>(content: .purlin, p1: (2,y,1), p2: (2,y+1,1))]
    }
  }()
  
  
  return basePlates + legs + rafter + purlins
}
