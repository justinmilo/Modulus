//
//  App.swift
//  HandlesRound1
//
//  Created by Justin Smith on 3/27/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit





struct GraphEditingView {
  let build: (CGSize, [Edge]) -> (GraphPositions, [Edge])
  let size : (ScaffGraph) -> CGSize
  let composite : (ScaffGraph) -> [Geometry]
  let parseEditBoundaries : (ScaffGraph) -> GraphPositions2DSorted
}
func graphViewGenerator(
  build: @escaping (CGSize, [Edge]) -> (GraphPositions, [Edge]),
  size : @escaping (ScaffGraph) -> CGSize,
  composite : [(ScaffGraph) -> [Geometry]],
  parseEditBoundaries : @escaping (ScaffGraph) -> GraphPositions2DSorted
  )-> [GraphEditingView]
{
  return composite.map {
    GraphEditingView( build: build,
                      size: size,
                      composite: $0,
                      parseEditBoundaries: parseEditBoundaries)
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
    size: sizeFromFullScaff,
    composite: [front1,
                front1 <> frontDim <> frontOuterDimPlus <> frontOverall,
                { $0.frontEdgesNoZeros } >>> modelToLinework],
    parseEditBoundaries: frontPositionsOhneStandards)
  
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
