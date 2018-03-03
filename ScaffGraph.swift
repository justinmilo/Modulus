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





extension ScaffGraph {
  
  func screwJacks(to max:(Int,Int) ) -> [Edge]
  {
    // import part z:0, p2: z:1
    return (0 ..< max.0).flatMap { x in
      (0 ..< max.1).map{ y in
        return Edge(content: "Jack", p1: (x,y,0), p2: (x,y,1))
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
              return Edge(content: "Ledger", p1: (tup.0,y,z), p2: (tup.1,y,z))
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
              return Edge(content: "Ledger", p1: (x,yVals.0,z), p2: (x,yVals.1,z))
          }
      }
    }
    
    return Array(x + y)
  }
  
  
  
  
  
  func everyBC(to xCount:Int, yCount:Int ) -> [Edge]
  {
    // import part (x,y,1), p2: (x,y,1))
    
    return (0 ..< xCount).flatMap { x in
      (0 ..< yCount).map{ y in
        return Edge(content: "BC", p1: (x,y,1), p2: (x,y,1))
      }
    }
  }
  
  
  func addScaff() {
    let g =  grid
    let sj = (g.pX.count, g.pY.count) |> screwJacks
    let l = (g.pX.count, g.pY.count, g.pZ.count) |> everyLedger
    let bc = (g.pX.count, g.pY.count) |> everyBC
    
    
    
    edges += sj + l + bc
    
    let seg = g |> posToSeg
    let standards = [seg.sZ.first!] + ( (g.pZ.last! - g.pZ.first!) |> maximumStandards )
    let stdPositions = standards |> segToPos
    
    let standardEdges = {
      (x : CGFloat,y : CGFloat) -> [CEdge] in
      
      let stdPositions = stdPositions.dropFirst()
      return zip(stdPositions, stdPositions.dropFirst()).map {
        return CEdge(content: "Standard", p1: Point3(x: x, y: y, z: $0.0), p2: Point3(x: x, y: y, z: $0.1))
      }
    }
    
    let standardCedges = g.pX.flatMap { x in
      g.pY.flatMap { y in standardEdges(x, y) } }
    
    (self.grid, self.edges) = standardCedges.reduce( (grid, edges) )
    {
      (res, cedge) -> (GraphPositions, [Edge]) in
      
      let new = (res.0, cedge) |> add
      
      return (new.0, res.1 + [new.1])
    }
  }
}
