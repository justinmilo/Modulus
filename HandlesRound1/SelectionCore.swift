//
//  EditingCore.swift
//  HandlesRound1
//
//  Created by Justin Smith on 4/3/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation

typealias SelectionArgs = (PointIndex2D, GraphPositions, [Edge])


typealias SelectionSignature = (PointIndex2D, GraphPositions, [Edge]) -> [Edge]

// Handle the 2D to 3D conversion
let mapFrontIndicesUpTo : (PointIndex2D, Int) -> [PointIndex] =
{
  (p,max) in
  return  (0..<max).map{ (p.x, $0, p.y)}
}
let mapPlanIndicesUpTo : (PointIndex2D, Int) -> [PointIndex] =
{
  (p,max) in
  return  (0..<max).map{ (p.x, p.y, $0)}
}
let mapSideIndicesUpTo : (PointIndex2D, Int) -> [PointIndex] =
{
  (p,max) in
  return  (0..<max).map{ ($0, p.x, p.y)}
}

////
//let mapBazFront : (PointIndex2D, GraphPositions) ->
//
//let newDiags : SelectionArgs -> [Edge] =


typealias BayIndex2D = PointIndex2D

func diagFromBayFactory(_ t:@escaping (BayIndex2D)-> (PointIndex2D, PointIndex2D),
                        _ u:@escaping (PointIndex2D) -> [PointIndex]
  ) -> (BayIndex2D) -> [Edge]
{
  return {
    bayIndex in
    let (p1x, p2x) = t(bayIndex)
    let items = zip(p1x |> u, p2x |> u).map{
      return Edge(content: .diag, p1: $0.0, p2: $0.1)
    }
    return items
  }
}

let front2DPointToAll3DPoint : (GraphPositions) -> (PointIndex2D) -> ([PointIndex]) = { $0.pY.count } >>> flip(curry(mapFrontIndicesUpTo))
let side2DPointToAll3DPoint : (GraphPositions) -> (PointIndex2D) -> ([PointIndex]) = { $0.pX.count } >>> flip(curry(mapSideIndicesUpTo))
let top2DPointToAll3DPoint : (GraphPositions) -> (PointIndex2D) -> ([PointIndex]) = { $0.pZ.count } >>> flip(curry(mapPlanIndicesUpTo))

func bazAll(populate: (GraphPositions) -> (PointIndex2D) -> ([PointIndex]),
            test1:  FunctionS<Edge, Bool>,
            test2:  FunctionS<Edge, Bool>) ->
            (PointIndex2D,
            GraphPositions,
  [Edge]) -> [Edge] {
    
    return { index, positions, edges in
      // bind for all pY.Count
      let populate = front2DPointToAll3DPoint(positions)
      // get all diags at touch
      let diagsAtTouch = filterDiagsWithBayIndex(edges: edges, bayIndex: index)
      
      let reducedEdges = edges.filter { !diagsAtTouch.contains($0) }
      
      // start the switch around what the previoous diag value was
      if diagsAtTouch.count == 0
      {
        let newEdges = diagFromBayFactory(lowToHigh, populate)(index) //// Take Out
        return reducedEdges + newEdges
      }
      else if let sampleDiag = diagsAtTouch.first, test1.call(sampleDiag)
      {
        let newEdges =  diagFromBayFactory(highToLow, populate)(index)
         return reducedEdges + newEdges//// Take Out
      }
      else if let sampleDiag = diagsAtTouch.first, test2.call(sampleDiag)
      {
        return reducedEdges
      }
      return edges
    }
}

let bazFront = (front2DPointToAll3DPoint, edgeXDiagUp, edgeXDiagDown) |> bazAll
let bazSide = (side2DPointToAll3DPoint, edgeYDiagUp, edgeYDiagDown) |> bazAll
let bazTop = (top2DPointToAll3DPoint, edgePlanDiagUp, edgePlanDiagDown) |> bazAll






