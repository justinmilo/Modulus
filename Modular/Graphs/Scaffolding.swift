//
//  Scaffolding.swift
//  Graph
//
//  Created by Justin Smith  on 11/18/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import Foundation
import GrapheNaked


public enum ScaffType : String {
  case ledger = "Ledger"
  case diag = "Diag"
  case bc = "BC"
  case standardGroup = "StandardGroup"
  case jack = "Jack"
}

extension ScaffType : Codable { }

public typealias ScaffEdge = Edge<ScaffType>



func screwJacks(to max:(Int,Int) ) -> [ScaffEdge]
{
  // import part z:0, p2: z:1
  return (0 ..< max.0).flatMap { x in
    (0 ..< max.1).map{ y in
      return Edge(content: .jack, p1: (x,y,0), p2: (x,y,1))
    }
  }
}

func everyLedger(xCount:Int, yCount: Int, zCount: Int) -> [ScaffEdge]
{
  let x = zip( (0 ..< xCount), (1 ..< xCount) ).flatMap
  {
    tup in
    
    (0 ..< yCount).flatMap
      { y in
        // Ledgers start at 1
        (1 ..< zCount).map
          { z in
            return Edge<ScaffType>(content: .ledger, p1: (tup.0,y,z), p2: (tup.1,y,z))
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
            return Edge<ScaffType>(content: .ledger, p1: (x,yVals.0,z), p2: (x,yVals.1,z))
        }
    }
  }
  
  return Array(x + y)
}

func everyStandardGroup(xCount:Int, yCount: Int, zCount: Int) -> [ScaffEdge]
{
  guard zCount > 1 else { return [] }
  
  let x = (0 ..< xCount ).flatMap
  {
    x in
    (0 ..< yCount).map
      { y in
        // Standards start at 1 (same base collar)
            return Edge<ScaffType>(content: .standardGroup, p1: (x,y,1), p2: (x,y,zCount-1))
    }
  }
  
  return Array(x)
}



func everyBC(to xCount:Int, yCount:Int ) -> [ScaffEdge]
{
  // import part (x,y,1), p2: (x,y,1))
  
  return (0 ..< xCount).flatMap { x in
    (0 ..< yCount).map{ y in
      return Edge(content: .bc, p1: (x,y,1), p2: (x,y,1))
    }
  }
}




import Singalong


func addScaff(grid:GraphPositions)->[ScaffEdge] {
    let g =  grid
    let sj = (g.pX.count, g.pY.count) |> screwJacks
    let l = (g.pX.count, g.pY.count, g.pZ.count) |> everyLedger
    let bc = (g.pX.count, g.pY.count) |> everyBC
    let standards = (g.pX.count, g.pY.count, g.pZ.count) |> everyStandardGroup
    
    
    
    let edges = sj + l + bc + standards
    return edges
  }


public typealias ScaffC2Edge = C2Edge<ScaffType>

func fLedger(e:ScaffC2Edge)-> Bool { return e.content == .ledger }
public func fStandard(e:ScaffC2Edge)-> Bool { return e.content == .standardGroup }


func filterOrthoLedgers(edge : ScaffC2Edge) -> Bool{
  return !(edge.content == .ledger && edge.p1 == edge.p2)
}


func reduceZeros(_ array: [ScaffC2Edge] ) -> [ScaffC2Edge] {
  return array.filter(filterOrthoLedgers)
}



extension Edge {
  var zComparison : (Int, Int) { (self.p1.zI, self.p2.zI) }
}
func zComparison<T>(edge: Edge<T>) -> (Int, Int) { (edge.p1.zI, edge.p2.zI) }
let zComparison : (ScaffEdge) -> (Int, Int) = { ($0.p1.zI, $0.p2.zI) }
let xComparison : (ScaffEdge) -> (Int, Int) = { ($0.p1.xI, $0.p2.xI) }
let yComparison : (ScaffEdge) -> (Int, Int) = { ($0.p1.yI, $0.p2.yI) }

let edgeIsSpanning = zComparison >>> isSpanning.call

let b = zComparison >>> bothLessThan(3).call

func maxClip(max: PointIndex, edges:[ScaffEdge]) -> [ScaffEdge]
{
  
  let bound_oneLessThan = zComparison >>> either(max.zI, <)
  let bound_oneGreaterThan = zComparison >>> either(max.zI, >)
  let bound_bothLessOrEqual = zComparison >>> both(max.zI, <=)
  
  let edgeStradlesFP = edges.filter( bound_oneGreaterThan)
  let edgeStradles = edgeStradlesFP.filter ( bound_oneLessThan)
  let edgeStradlesFixed = edgeStradles.map {
    return Edge(content: $0.content,
                p1: clip(p1: max, p2: $0.p1),
                p2: clip(p1: max, p2: $0.p2))
  }
  
  let edgesBelow = edges.filter(bound_bothLessOrEqual)
  return edgesBelow + edgeStradlesFixed
}


let anyComaprison : ((PointIndex) -> Int, ScaffEdge) -> (Int, Int) = {
  return ( $0($1.p1), $0($1.p2) )
}
let anyComparisonCurried = curry(anyComaprison)

func clipOne(max: PointIndex, t: @escaping (PointIndex) -> Int, edges:[ScaffEdge]) -> [ScaffEdge]
{
  
  let bound_oneLessThan = anyComparisonCurried(t) >>> either(t(max), <)
  let bound_oneGreaterThan = anyComparisonCurried(t) >>> either(t(max), >)
  let bound_bothLessOrEqual = anyComparisonCurried(t) >>> both(t(max), <=)
  
  let edgeStradlesFP = edges.filter( bound_oneGreaterThan)
  let edgeStradles = edgeStradlesFP.filter ( bound_oneLessThan)
  let edgeStradlesFixed = edgeStradles.map {
    return Edge(content: $0.content,
                p1: clip(p1: max, p2: $0.p1),
                p2: clip(p1: max, p2: $0.p2))
  }
  
  let edgesBelow = edges.filter(bound_bothLessOrEqual)
  return edgesBelow + edgeStradlesFixed
}
