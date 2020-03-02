//
//  ScallopGraphMap.swift
//  Modular
//
//  Created by Justin Smith  on 1/15/20.
//  Copyright © 2020 Justin Smith. All rights reserved.
//

import Foundation
import GrapheNaked
import Singalong



struct SC {
  static let size3Plan : (CGSize3) -> (CGSize) -> CGSize3 = {frozen in { CGSize3(width: $0.width, depth: $0.height, elev: frozen.elev) }}
  static let add3rdDimToRotatedPlan : (CGSize3) -> (CGSize) -> CGSize3 = {frozen in { CGSize3(width: $0.height, depth: $0.width, elev: frozen.elev) }}
  static let add3rdDimToFront : (CGSize3) -> (CGSize) -> CGSize3 = {frozen in { CGSize3(width: $0.width, depth: frozen.depth, elev: $0.height) }}
  static let size3Side : (CGSize3) -> (CGSize) -> CGSize3 = {frozen in { CGSize3(width: frozen.width, depth: $0.width, elev: $0.height) }}
  
  static let sizePlan : (ScallopGraph) -> (CGSize) -> CGSize3 = get(\.bounds) >>> size3Plan
  static let sizePlanRotated : (ScallopGraph) -> (CGSize) -> CGSize3 = get(\.bounds) >>> add3rdDimToRotatedPlan
  static let sizeFront : (ScallopGraph) -> (CGSize) -> CGSize3 = get(\.bounds) >>> add3rdDimToFront
  static let sizeSide : (ScallopGraph) -> (CGSize) -> CGSize3 = get(\.bounds) >>> size3Side
  
  static let planEdges : (ScallopGraph) -> [C2Edge<ScallopParts>] = { ($0.grid, $0.edges) |> planSection().parse }
  static let frontEdges : (ScallopGraph) -> [C2Edge<ScallopParts>] = { ($0.grid, $0.edges) |> frontSection().parse }
  static let sideEdges : (ScallopGraph) -> [C2Edge<ScallopParts>] = { ($0.grid, $0.edges) |> sideSection().parse }
  
  static let planPositions = SC.planEdges >>> log >>> positionsInEdges
  static let rotatedPlanPositions = SC.planEdges >>> rotateGroup >>> log >>> positionsInEdges
  static let frontPositions = SC.frontEdges >>> log >>> positionsInEdges
  static let sidePositions = SC.sideEdges >>> log >>> positionsInEdges
  static let overall : ([CGFloat], CGSize3, [Edge<ScallopParts>]) -> (GraphPositions, [Edge<ScallopParts>]) = { _, size, _ in
    createScallopGroup(from:size)
  }
}

import Interface
public let scallopPlanMap = GenericEditingView<ScallopGraph>(
  build: SC.overall,
  origin: originZero,
  size: { $0.bounds }
    >>> remove3rdDimPlan,
  size3: SC.sizePlan,
  composite: plan2DSc
    >>> scallopLinesLabelsPlan
    <> get(\.grid)
    >>> plan
    >>> (innerDim(archFormat)
      <> outerDim(archFormat)),
  grid2D: SC.planPositions,
  selectedCell: { _, _, edges in return edges}
)
public let scallopPlanMapRotated = GenericEditingView<ScallopGraph>(
  build: SC.overall,
  origin: originZero,
  size: { $0.bounds }
    >>> remove3rdDimPlan
    >>> flip,
  size3: SC.sizePlanRotated,
  composite: plan2DSc
    >>> rotateGroup
    >>> scallopLinesLabelsPlan
    <> get(\.grid)
    >>> plan
    >>> (innerDim(archFormat)
      <> outerDim(archFormat)),
  grid2D: SC.rotatedPlanPositions,
  selectedCell: { _, _, edges in return edges}
)

public let scallopFrontMap = GenericEditingView<ScallopGraph>(
  build: SC.overall,
  origin: originZero,
  size: { $0.bounds }
    >>> remove3rdDimFront,
  size3: { $0.bounds }
    >>> add3rdDimToFront,
  composite: front2DSc
    >>>  scallopLinesLabelsPlan
    <> get(\.grid)
    >>> front
    >>> (innerDim(meterFormat)
      <> outerDim(meterFormat)),
  grid2D: SC.frontPositions,
  selectedCell: { _, _, edges in return edges}
)

public let scallopSideMap = GenericEditingView<ScallopGraph>(
  build: SC.overall,
  origin: originZero,
  size: { $0.bounds } >>> remove3rdDimSide // >>> addTentHeight
  ,
  size3: { $0.bounds } >>> size3Side // >>> minusTentHeight
  ,
  composite: side2DSc
    >>> scallopLinesLabelsPlan
    <> get(\.grid)
    >>> side
    >>> (innerDim(meterFormat)
      <> outerDim(meterFormat)),
  grid2D: SC.sidePositions,
  selectedCell: { _, _, edges in return edges}
)




import Geo
