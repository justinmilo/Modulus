//
//  ScaffGraphCore.swift
//  HandlesRound1
//
//  Created by Justin Smith on 3/2/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import CoreGraphics
import Singalong


//  - 50 -
//  |
//  50
//  |

func generateSegments(for bounding: CGSize3) -> GraphSegments {
  return GraphSegments(
    sX: ([50, 100, 150, 200], bounding.width) |> maximumRepeated,
    sY: ([50, 100, 150, 200], bounding.depth) |> maximumRepeated,
    // sZ is the ledger bays not the standards
    sZ: ([50, 100, 150, 200], bounding.elev) |> maximumRepeatedWithR |> { [$0.1] + $0.0 }
  )
}

func createScaffolding(with bounding: CGSize3) -> (GraphPositions, [Edge])
{
  let graphSegments = bounding |> generateSegments
  let s = ScaffGraph( grid : graphSegments |> segToPos, edges : [] )
  s.addScaff()
  return (s.grid, s.edges)
}

func createGrid(with bounding: CGSize3) -> (GraphPositions, [Edge])
{
  let screwJack : [CGFloat] = [30]
  let graphSegments = GraphSegments(
    sX: ([50, 100, 150, 200], bounding.width) |> maximumRepeated,
    sY: ([50, 100, 150, 200], bounding.depth) |> maximumRepeated,
    // sZ is the ledger bays not the standards
    sZ: ([50, 100, 150, 200], bounding.elev) |> maximumRepeated |> { screwJack + $0  }
  )
  let s = ScaffGraph( grid : graphSegments |> segToPos, edges : [] )
  s.addScaff()
  return (s.grid, s.edges)
}

func createGrid(with bounding: CGSize3, existing edges: [Edge]) -> (GraphPositions, [Edge])
{
  let screwJack : [CGFloat] = [30]
  let graphSegments = GraphSegments(
    sX: ([50, 100, 150, 200], bounding.width) |> maximumRepeated,
    sY: ([50, 100, 150, 200], bounding.depth) |> maximumRepeated,
    // sZ is the ledger bays not the standards
    sZ: ([50, 100, 150, 200], bounding.elev) |> maximumRepeated |> { screwJack + $0  }
  )
  let s = ScaffGraph( grid : graphSegments |> segToPos, edges : [] )
  s.addScaff()
  return (s.grid, s.edges)
}



extension ScaffGraph
{
  var planEdges : [C2Edge] {
    let planedges = (self.edges, self.grid |> cedgeMaker) |> mapEdges |> plan |> reduceDup
    return planedges
  }
  var planEdgesNoZeros : [C2Edge] {
    let new = self.planEdges.filter { $0.content == .ledger || $0.content == .standardGroup }
    return new
  }
  var frontEdges : [C2Edge] {
    let consumer3D = try! self.edges.map( self.grid |> cedgeMaker)
    return  consumer3D |> front |> reduceDup
  }
  var frontEdgesNoZeros : [C2Edge] {
    return self.frontEdges |> reduceZeros
  }
  var sideEdges : [C2Edge] {
    let consumer3D = try! self.edges.map( self.grid |> cedgeMaker)
    return  consumer3D |> side |> reduceDup
  }
  var sideEdgesNoZeros : [C2Edge] {
    return self.sideEdges |> reduceZeros
  }
}
extension ScaffGraph {
  
  var bounds: CGSize3 {
    return self.grid |> posToSize
  }
  
  var boundsOfGrid: (CGSize3, CGFloat) {
    return (self.grid |> dropBottomZBay |> posToSize, (self.grid.pZ |> posToSeg |> { ($0.first)!} ))
  }
  
}


func fLedger(e:C2Edge)-> Bool { return e.content == .ledger }
func fStandard(e:C2Edge)-> Bool { return e.content == .standardGroup }


func filterOrthoLedgers(edge : C2Edge) -> Bool
{
  return !(edge.content == .ledger && edge.p1 == edge.p2)
}


func cedges(graph: GraphPositions, edges: [Edge]) -> ([CEdge])
{
  return edges.map( curry(cedge)(graph) )
}





func maximumStandards(in height:CGFloat) -> [CGFloat]
{
  return maximumRepeated(availableInventory:[50,100], targetMaximum: height)
  
}



