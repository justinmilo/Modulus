//
//  ScaffGraphCore.swift
//  HandlesRound1
//
//  Created by Justin Smith on 3/2/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import CoreGraphics
import Singalong
import GrapheNaked


//  - 50 -
//  |
//  50
//  |

public let createScaffolding :  ((CGFloat, CGFloat, CGFloat)) -> ScaffGraph = CGSize3.init >>> createNusGrid >>> ScaffGraph.init
public let createScaffoldingFrom = createGrid(with:bounding:) >>> ScaffGraph.init
public let curriedScaffoldingFrom = curry(detuple(createScaffoldingFrom))




public func createGrid(with sizes: [CGFloat], bounding: CGSize3) -> (GraphPositions, [ScaffEdge]) {
  let screwJack : [CGFloat] = [30]
  let graphSegments = GraphSegments(
    sX: (sizes, bounding.width) |> maximumRepeated,
    sY: (sizes, bounding.depth) |> maximumRepeated,
    // sZ is the ledger bays not the standards
    sZ: ([50, 100, 150, 200], bounding.elev) |> maximumRepeated |> { screwJack + $0  }
  )
  let pos = graphSegments |> segToPos
  let edges = addScaff(grid:pos)
  return (pos, edges)
}

public let createNusGrid  = [50, 100, 150, 200] |> curry(createGrid(with:bounding:))

extension ScaffGraph
{
  var planEdges : [C2Edge<ScaffType>] {
    let planedges = (self.edges, self.grid |> cedgeMaker) |> mapEdges |> plan |> reduceDup
    return planedges
  }
  public var planEdgesNoZeros : [C2Edge<ScaffType>] {
    let new = self.planEdges.filter { $0.content == .ledger || $0.content == .standardGroup }
    return new
  }
  var frontEdges : [C2Edge<ScaffType>] {
    let consumer3D = self.edges.map( self.grid |> cedgeMaker)
    return  consumer3D |> front |> reduceDup
  }
  public var frontEdgesNoZeros : [C2Edge<ScaffType>] {
    return self.frontEdges |> reduceZeros
  }
  var sideEdges : [C2Edge<ScaffType>] {
    let consumer3D = self.edges.map( self.grid |> cedgeMaker)
    return  consumer3D |> side |> reduceDup
  }
  public var sideEdgesNoZeros : [C2Edge<ScaffType>] {
    return self.sideEdges |> reduceZeros
  }
}
extension ScaffGraph {
  
  public var bounds: CGSize3 {
    return self.grid |> posToSize
  }
  
  public var boundsOfGrid: (CGSize3, CGFloat) {
    return (self.grid |> dropBottomZBay |> posToSize, (self.grid.pZ |> posToSeg |> { ($0.first)!} ))
  }
  
}






public func maximumStandards(in height:CGFloat) -> [CGFloat]
{
  return maximumRepeated(availableInventory:[50,100], targetMaximum: height)
  
}


//public func posAndEdges(from graph: ScaffGraph)-> (GraphPositions)
//{
//
//}
