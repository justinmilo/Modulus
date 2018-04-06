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
  
  // if point index in 2D give new 3D edges
  let selectedCell : (PointIndex2D, GraphPositions, [Edge]) -> ([Edge])

}
func graphViewGenerator(
  build: @escaping (CGSize, [Edge]) -> (GraphPositions, [Edge]),
  origin : @escaping (ScaffGraph) -> CGPoint,
  size : @escaping (ScaffGraph) -> CGSize,
  composite : [(ScaffGraph) -> [Geometry]],
  grid2D : @escaping (ScaffGraph) -> GraphPositions2DSorted,
  selectedCell :  @escaping (PointIndex2D, GraphPositions, [Edge]) -> ([Edge])
  )-> [GraphEditingView]
{
  return composite.map {
    GraphEditingView( build: build,
                      origin: origin,
                      size: size,
                      composite: $0,
                      grid2D: grid2D,
                      selectedCell: selectedCell)
  }
}



func opposite(b: Bool) -> Bool { return !b }

let originZero: (ScaffGraph) -> CGPoint = { _ in return CGPoint(0,0)}
let originFirstLedger: (ScaffGraph) -> CGPoint = { graph in return CGPoint(0, graph.boundsOfGrid.1)}

func app() -> UIViewController
{
  let initial = CGSize3(width: 300, depth: 0, elev: 400) |> createGrid
  let graph = ScaffGraph(grid: initial.0, edges: initial.1)
  // graph is passed passed by reference here ...
  
  
  //      let uR2 = SpriteScaffViewController(graph: graph, mapping: frontMap2)
  
  
  let frontMap = graphViewGenerator(
    build: sizeFront(graph) |> overall, //>>> createScaffolding,
    origin: originZero,
    size: sizeFromFullScaff,
    composite: [front1,
                front1 <> frontDim <> frontOuterDimPlus <> frontOverall >>> map(toGeometry),
                { $0.frontEdgesNoZeros } >>> modelToLinework],
    grid2D: frontPositionsOhneStandards,
    selectedCell: bazFront)
  
    let frontMap2 = graphViewGenerator(
      build: sizeFront(graph) |> overall, //>>> createScaffolding,
      origin: originFirstLedger,
      size: sizeSchematicFront,
      composite: [front1,
                  front1 <> frontDim,
                  front1 <> frontDim <> frontOuterDimPlus,
                  front1 <> frontDim <> frontOuterDimPlus <> frontOverall >>> map(toGeometry),
                  { $0.frontEdgesNoZeros } >>> modelToLinework],

      grid2D: frontPositionsOhneStandards,
      selectedCell: bazFront)
  
  
  
  let planMap = graphViewGenerator(
    build: sizePlan(graph) |> overall,
    origin: originZero,
    size: sizeFromPlanScaff,
    composite: [finalDimComp,
                planGridsToDimensions],
    grid2D: planPositions,
    selectedCell: bazTop)
  
  let planMapRotated = graphViewGenerator(
    build: sizePlanRotated(graph) |> overall,
    origin: originZero,
    size: sizeFromRotatedPlanScaff,
    composite: [rotatedFinalDimComp],
    grid2D: rotatedPlanPositions,
    selectedCell: bazTop)
  
  
  
  let sideMap = graphViewGenerator(
    build: sizeSide(graph) |> overall,
    origin: originZero,
    size: sizeFromFullScaffSide,
    composite: [side1,
                side1 <> sideDim,
                side1 <> sideDim <> sideDoubleDim],
    grid2D: sidePositionsOhneStandards,
    selectedCell: bazSide)
  
  func foo(_ vc: UIViewController, _ st: String ) -> UINavigationController
  {
    vc.title = st
    let ulN = UINavigationController(rootViewController: vc)
    ulN.navigationBar.prefersLargeTitles = true
    let nav = ulN.navigationBar
    nav.barStyle = UIBarStyle.blackTranslucent
    nav.tintColor = .white
    nav.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    
    return ulN
  }
  
  let uL = SpriteScaffViewController(graph: graph, mapping: planMap)
  let uR = SpriteScaffViewController(graph: graph, mapping: planMapRotated)
  let ll = SpriteScaffViewController(graph: graph, mapping: frontMap)
  let lr = SpriteScaffViewController(graph: graph, mapping: sideMap)
  
  //return foo(lr, "Side View")
  
  //return foo(ll, "Front View")

  
  return VerticalController(upperLeft: foo(uL, "Plan View"),
                            upperRight: foo(uR, "Rotated Plan View"),
                            lowerLeft: foo(ll, "Front View"),
                            lowerRight: foo(lr, "Side View"))

}


