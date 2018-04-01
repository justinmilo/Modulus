//
//  ScaffGraph.swift
//  HandlesRound1
//
//  Created by Justin Smith on 3/2/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import CoreGraphics


class ScaffGraph{
  init(grid: GraphPositions, edges:[Edge])
  {
    self.grid = grid
    self.edges = edges
  }
  var grid : GraphPositions
  var edges : [Edge]
  
  func addEdge(_ cedge : CEdge) {
    let new = (grid, cedge) |> add
    grid = new.0
    edges.append(new.1)
  }
}


func screwJacks(to max:(Int,Int) ) -> [Edge]
{
  // import part z:0, p2: z:1
  return (0 ..< max.0).flatMap { x in
    (0 ..< max.1).map{ y in
      return Edge(content: .jack, p1: (x,y,0), p2: (x,y,1))
    }
  }
}

func everyLedger(xCount:Int, yCount: Int, zCount: Int) -> [Edge]
{
  let x = zip( (0 ..< xCount), (1 ..< xCount) ).flatMap
  {
    tup in
    
    (0 ..< yCount).flatMap
      { y in
        // Ledgers start at 1
        (1 ..< zCount).map
          { z in
            return Edge(content: .ledger, p1: (tup.0,y,z), p2: (tup.1,y,z))
        }
    }
  }
  
  let y = (0 ..< xCount).flatMap
  {
    x in
    
    zip( (0 ..< yCount), (1 ..< yCount) ).flatMap
      { yVals in
        // Ledgers start at 1
        (1 ..< zCount).map
          { z in
            return Edge(content: .ledger, p1: (x,yVals.0,z), p2: (x,yVals.1,z))
        }
    }
  }
  
  return Array(x + y)
}

func everyStandardGroup(xCount:Int, yCount: Int, zCount: Int) -> [Edge]
{
  guard zCount > 1 else { return [] }
  
  let x = (0 ..< xCount ).flatMap
  {
    x in
    (0 ..< yCount).map
      { y in
        // Standards start at 1 (same base collar)
            return Edge(content: .standardGroup, p1: (x,y,1), p2: (x,y,zCount-1))
    }
  }
  
  return Array(x)
}



func everyBC(to xCount:Int, yCount:Int ) -> [Edge]
{
  // import part (x,y,1), p2: (x,y,1))
  
  return (0 ..< xCount).flatMap { x in
    (0 ..< yCount).map{ y in
      return Edge(content: .bc, p1: (x,y,1), p2: (x,y,1))
    }
  }
}






extension ScaffGraph {
  func addScaff() {
    let g =  grid
    let sj = (g.pX.count, g.pY.count) |> screwJacks
    let l = (g.pX.count, g.pY.count, g.pZ.count) |> everyLedger
    let bc = (g.pX.count, g.pY.count) |> everyBC
    let standards = (g.pX.count, g.pY.count, g.pZ.count) |> everyStandardGroup
    
    
    
    edges += sj + l + bc + standards
    
  }
}
