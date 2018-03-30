//
//  App.swift
//  HandlesRound1
//
//  Created by Justin Smith on 3/27/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit





struct GraphEditingView {
  /// takes a bounding box size, and any existing structure ([Edge]) to interprit a new ScaffGraph,a fully 3D structure
  let build: (CGSize, [Edge]) -> (GraphPositions, [Edge])
  
  /// origin: the offset from the 0,0 corner of the bounding box
  let origin : (ScaffGraph) -> CGPoint
  /// Related to the size of the bounding box
  let size : (ScaffGraph) -> CGSize
  
  /// From Graph to Geometry at (0,0)
  /// Geometry bounds is not necisarily the same as the size, which is a bounding box
  let composite : (ScaffGraph) -> [Geometry]
  
  /// related to the entire composite
  let grid2D : (ScaffGraph) -> GraphPositions2DSorted
}
func graphViewGenerator(
  build: @escaping (CGSize, [Edge]) -> (GraphPositions, [Edge]),
  origin : @escaping (ScaffGraph) -> CGPoint,
  size : @escaping (ScaffGraph) -> CGSize,
  composite : [(ScaffGraph) -> [Geometry]],
  grid2D : @escaping (ScaffGraph) -> GraphPositions2DSorted
  )-> [GraphEditingView]
{
  return composite.map {
    GraphEditingView( build: build,
                      origin: origin,
                      size: size,
                      composite: $0,
                      grid2D: grid2D)
  }
}




func opposite(b: Bool) -> Bool { return !b }



func app() -> UIViewController
{
  let initial = CGSize3(width: 300, depth: 0, elev: 400) |> createGrid
  let graph = ScaffGraph(grid: initial.0, edges: initial.1)
  // graph is passed passed by reference here ...
  
  
  //      let uR2 = SpriteScaffViewController(graph: graph, mapping: frontMap2)
  
  
  let frontMap = graphViewGenerator(
    build: sizeFront(graph) |> overall, //>>> createScaffolding,
    origin: {_ in return CGPoint(0,0) },
    size: sizeFromFullScaff,
    composite: [front1,
                front1 <> frontDim <> frontOuterDimPlus <> frontOverall,
                { $0.frontEdgesNoZeros } >>> modelToLinework],
    grid2D: frontPositionsOhneStandards)
  
  //      let frontMap2 = graphViewGenerator(
  //        build: overall, //>>> createScaffolding,
  //        size: sizeSchematicFront,
  //        composite: [front1,
  //                    front1 <> frontDim,
  //                    front1 <> frontDim <> frontOuterDimPlus,
  //                    front1 <> frontDim <> frontOuterDimPlus <> frontOverall,
  //                    { $0.frontEdgesNoZeros } >>> curry(modelToLinework)],
  //        origin: originFromFullScaff,
  //        parseEditBoundaries: frontPositionsOhneStandards)
  
  let uR = SpriteScaffViewController(graph: graph, mapping: frontMap)
  return uR
}
