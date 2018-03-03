//
//  ScaffGraphCore.swift
//  HandlesRound1
//
//  Created by Justin Smith on 3/2/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import CoreGraphics


func createScaffolding(with bounding: CGSize3) -> (GraphPositions, [Edge])
{
  let graphSegments = GraphSegments(
    sX: ([50, 100, 150, 200], bounding.width) |> maximumRepeated,
    sY: ([50, 100, 150, 200], bounding.depth) |> maximumRepeated,
    // sZ is the ledger bays not the standards
    sZ: ([50, 100, 150, 200], bounding.elev) |> maximumRepeatedWithR |> { [$0.1] + $0.0 }
  )
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


extension ScaffGraph
{
  var planEdges : [C2Edge] {
    let planedges = (self.edges, self.grid |> cedgeMaker) |> mapEdges |> plan |> reduceDup
    return planedges
  }
  var planEdgesNoZeros : [C2Edge] {
    let new = self.planEdges.filter { $0.content == "Ledger" || $0.content == "Standard" }
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
  
  var bounds: CGSize3 {
    return self.grid |> posToSize
  }
  
  var boundsOfGrid: (CGSize3, CGFloat) {
    return (self.grid |> dropBottomZBay |> posToSize, (self.grid.pZ |> posToSeg |> { ($0.first)!} ))
  }
  
}


func fLedger(e:C2Edge)-> Bool { return e.content == "Ledger" }
func fStandard(e:C2Edge)-> Bool { return e.content == "Standard" }


func filterLedgers(edge : C2Edge) -> Bool
{
  return !(edge.content == "Ledger" && edge.p1 == edge.p2)
  
}


func cedges(graph: GraphPositions, edges: [Edge]) -> ([CEdge])
{
  return edges.map( curry(cedge)(graph) )
}





func maximumStandards(in height:CGFloat) -> [CGFloat]
{
  return maximumRepeated(availableInventory:[50,100], targetMaximum: height)
  
}



