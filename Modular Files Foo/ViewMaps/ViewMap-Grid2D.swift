//
//  ViewMap-Grid2D.swift
//  Deploy
//
//  Created by Justin Smith on 12/18/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import CoreGraphics
import Graphe
import Singalong
import BlackCricket




let frontEdges : (ScaffGraph) -> [C2Edge<ScaffType>] = { ($0.grid, $0.edges) |> frontSection().parse }
let sideEdges : (ScaffGraph) -> [C2Edge<ScaffType>] = { ($0.grid, $0.edges) |> sideSection().parse }
let planEdges : (ScaffGraph) -> [C2Edge<ScaffType>] = { ($0.grid, $0.edges) |> planSection().parse }
let removedStandards : ([C2Edge<ScaffType>]) -> [C2Edge<ScaffType>] = { $0.filter(fStandard >>> opposite) }
let frontPointsWOutStandards = frontEdges >>> removedStandards >>> edgesToPoints
let sidePointsWOutStandards = sideEdges >>> removedStandards >>> edgesToPoints
let planPoint = planEdges >>> edgesToPoints

func positionsIn(edges: [C2Edge<ScaffType>]) -> GraphPositions2DSorted {
  return GraphPositions2DSorted(
    pX: edges.flatMap{ [$0.p1.x] + [$0.p2.x] } |> removeDup,
    pY: edges.flatMap{ [$0.p1.y] + [$0.p2.y] } |> removeDup
  )
}
let frontPositionsOhneStandards = frontEdges >>> removedStandards >>> positionsIn
let sidePositionsOhneStandards = sideEdges >>> removedStandards >>> positionsIn
let planPositions = planEdges >>> log >>> positionsIn
let rotatedPlanPositions = planEdges >>> rotateGroup >>> positionsIn
