//
//  ViewMaps.swift
//  HandlesRound1
//
//  Created by Justin Smith on 6/11/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation
import GrapheNaked
import Singalong
import BlackCricket

/*
public struct GraphEditingView {
  /// takes a bounding box size, and any existing structure ([Edge]) to interprit a new ScaffGraph,a fully 3D structure
  let build: ([CGFloat], CGSize3, [ScaffEdge]) -> (GraphPositions, [ScaffEdge])
  
  /// origin: in this editing view slice, the offset from the 0,0 corner of the bounding box
  let origin : (ScaffGraph) -> CGPoint
  /// Related to the size of the bounding box
  let size : (ScaffGraph) -> CGSize
  
  /// Translates this view's 2D rep to 3D boounding box based on the graph and view semantics
  let size3 : (ScaffGraph) -> (CGSize) -> CGSize3
  
  /// From Graph to Geometry at (0,0)
  /// Geometry bounds is not necisarily the same as the size, which is a bounding box
  let composite : (ScaffGraph) -> Composite
  
  /// related to the entire composite
  let grid2D : (ScaffGraph) -> GraphPositions2DSorted
  
  /// if point index in 2D give new 3D edges
  let selectedCell : (PointIndex2D, GraphPositions, [ScaffEdge]) -> ([ScaffEdge])
  
}*/
import Interface
public typealias GraphEditingView = GenericEditingView<ScaffGraph>

func graphViewGenerator(
  build: @escaping ([CGFloat], CGSize3, [ScaffEdge]) -> (GraphPositions, [ScaffEdge]),
  origin : @escaping (ScaffGraph) -> CGPoint,
  size : @escaping (ScaffGraph) -> CGSize,
  size3 : @escaping (ScaffGraph) -> (CGSize) -> CGSize3,
  composite : [(ScaffGraph) -> Composite],
  grid2D : @escaping (ScaffGraph) -> GraphPositions2DSorted,
  selectedCell :  @escaping (PointIndex2D, GraphPositions, [ScaffEdge]) -> ([ScaffEdge])
  )-> [GraphEditingView]
{
  return composite.map {
    GraphEditingView( build: build,
                      origin: origin,
                      size: size,
                      size3: size3,
                      composite: $0,
                      grid2D: grid2D,
                      selectedCell: selectedCell)
  }
}

func opposite(b: Bool) -> Bool { return !b }
let originZero : (Any) -> CGPoint = { _ in return CGPoint(0,0)}

let originFirstLedger: (ScaffGraph) -> CGPoint = { graph in return CGPoint(0, graph.boundsOfGrid.1)}

public let planMap = graphViewGenerator(
  build: overall,
  origin: originZero,
  size: sizeFromPlanScaff,
  size3: sizePlan,
  composite: [
              planComposite
                <> planGrid
                >>> (innerDim(meterFormat)
                  <> outerDim(meterFormat)),
              planComposite
                <> planGrid
                >>> innerDim(archFormat),
              planComposite
                <> planGrid
                >>> (innerDim(archFormat)
                  <> outerDim(archFormat)),
              planLinework],
  grid2D: planPositions,
  selectedCell: bazTop
)

let planMapRotated = graphViewGenerator(
  build: overall,
  origin: originZero,
  size: sizeFromRotatedPlanScaff,
  size3: sizePlanRotated,
  composite:
    [
     rotatedPlanComposite <> rotatedPlanGrid >>> (innerDim(meterFormat) <> outerDim(meterFormat)),
     rotatedPlanComposite <> rotatedPlanGrid >>> innerDim(archFormat),
     rotatedPlanComposite <> rotatedPlanGrid >>> (innerDim(archFormat) <> outerDim(archFormat)),
     rotatedPlanLinework]
  ,
  grid2D: rotatedPlanPositions,
  selectedCell: bazTop
)

let frontMap = graphViewGenerator(
  build: overall,
  origin: originZero,
  size: sizeFromFullScaff,
  size3: sizeFront,
  composite: [frontComposite,
              
              frontComposite <> frontGrid >>> innerDim(meterFormat),
              frontComposite <> frontGrid >>> (innerDim(meterFormat) <> outerDim(meterFormat)),
              
              frontComposite <> frontGrid >>> innerDim(archFormat),
              frontComposite <> frontGrid >>> (innerDim(archFormat) <> outerDim(archFormat)),
              
              get(\.frontEdgesNoZeros) >>> modelToLinework],
  grid2D: frontPositionsOhneStandards,
  selectedCell: bazFront
)

let sideMap = graphViewGenerator(
  build: overall,
  origin: originZero,
  size: sizeFromFullScaffSide,
  size3: sizeSide,
  composite: [sideComposite,
              sideComposite <> sideGrid >>> innerDim(meterFormat),
              sideComposite <> sideGrid >>> (innerDim(meterFormat) <> outerDim(meterFormat)),
              sideComposite <> sideGrid >>> innerDim(archFormat),
              sideComposite <> sideGrid >>> (innerDim(archFormat) <> outerDim(archFormat)),
              
              ],
  grid2D: sidePositionsOhneStandards,
  selectedCell: bazSide
)


//func currentY(graph: ScaffGraph) -> [CGFloat] {
//  return Current.model.getItem(id: graph.id)!.sizePreferences.map{CGFloat($0.length.converted(to: .centimeters).value)}
//
//}
