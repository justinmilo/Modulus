//
//  SliceScaffoldingCore.swift
//  Graph
//
//  Created by Justin Smith  on 11/18/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import Foundation
import Singalong
import GrapheNaked


public let sizeFront : (ScaffGraph) -> (CGSize) -> CGSize3 = {graph in { CGSize3(width: $0.width, depth: graph.bounds.depth, elev: $0.height) } }
public let sizeSide : (ScaffGraph) -> (CGSize) -> CGSize3 = {graph in { CGSize3(width: graph.bounds.width, depth: $0.width , elev: $0.height) } }
// graph is passed passed by reference here ...
public let sizePlan : (ScaffGraph) -> (CGSize) -> CGSize3 = {graph in { CGSize3(width: $0.width, depth: $0.height, elev: graph.bounds.elev) } }
public let sizePlanRotated : (ScaffGraph) ->  (CGSize) -> CGSize3 = {graph in { CGSize3(width: $0.height, depth: $0.width, elev: graph.bounds.elev) } }



public let overall : ([CGFloat], CGSize3, [ScaffEdge]) -> (GraphPositions, [ScaffEdge]) = {
  available, size, edges in
  
  let toPosition = generateSegments >>> segToPos
  let curried = curry(detuple(toPosition))
  let pos = size |> curried(available)
  let max = pos |> maxEdges
  
  let bothless = bothInts(<=)
  let pEz = bothless(max.zI) |> contramap(zComparison)
  let pEx = bothless(max.xI) |> contramap(xComparison)
  let pEy = bothless(max.yI) |> contramap(yComparison)
  let edgeB1 = (pEz && pEy && pEx) |> edges.filtered
  
  
  let s = ScaffGraph( grid : pos, edges : [])
  s.edges = addScaff(grid: pos)
  
  
  
  let combined  =  edgeB1 + s.edges.filter { !edgeB1.contains($0) }
  
  let combinedRemovedStandard : [ScaffEdge] = combined.reduce([]) {
    results,next in
    
    guard isStandardGroup.call(next) else { return results + [next]}
    
    let pred = isStandardGroup && eitherEqual(next)
    // see if match exists in results
    guard let i = results.index(where: pred.call) else {
      return results + [next]
    }
    
    let match = results[i]
    if abs(match.p1.zI - match.p2.zI) > abs(next.p1.zI - next.p2.zI)
    {
      return results
    }
    else {
      
      var mutating = results
      
      mutating.remove(at: i)
      return mutating + [next]
    }
    
    
    
  }
  
  return (pos, combinedRemovedStandard)
}




/// FIXME this was supposed to be a gettable way



var isDiagContent = Predicate<ScaffEdge>{ $0.content == .diag }
var isStandardGroup = Predicate<ScaffEdge>{ $0.content == .standardGroup}



let inBayIndex: (BayIndex2D) -> Predicate<ScaffEdge> =
{
  let (p1x, p2x) = lowToHigh(gIndex: $0)
  return Predicate {
    edge in
    
    let p1_3 = p1x |> (curry(addY)(edge.p1.yI))
    let p2_3 = p2x |> curry(addY)(edge.p2.yI)
    
    let testEdge = EdgeEmpty(p1:p1_3, p2: p2_3)
    return edge.empty == testEdge
  }
}
