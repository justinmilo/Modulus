//
//  ScallopGraph.swift
//  Modular
//
//  Created by Justin Smith Nussli on 1/15/20.
//  Copyright © 2020 Justin Smith. All rights reserved.
//

import Foundation
import GrapheNaked
import Singalong

public enum ScallopParts : String, Codable, Hashable {
    case glassWall = "Glass Frame Wall"
    case solidWall = "Solid Frame Wall"
    case roofPanel = "Roof Panel"
    case floorPanel = "Floor Panel"
}

/// Just a container for some important scallop specific sizes
struct Scallop {
  static let width : CGFloat = 243.84
  static let depth : CGFloat = 609.6
  static let height : CGFloat = 295.6157
}

public func createScallopGroup(from bounding: CGSize3) -> (GraphPositions, [Edge<ScallopParts>]) {
  
  let graphSegments = GraphSegments(
    sX: ([Scallop.width],  bounding.width) |> maximumRepeated,
    sY: ([Scallop.depth], bounding.depth) |> maximumRepeated,
    sZ: ([Scallop.height], bounding.elev) |> maximumRepeated
  )
  let positionsGrid = graphSegments |> segToPos
  let edges = halfSolidHalfClearScallopFrom(grid:positionsGrid)
  return (positionsGrid, edges)
}

func halfSolidHalfClearScallopFrom(grid:GraphPositions) -> [Edge<ScallopParts>] {
  let x = zip( (0 ..< grid.pX.count-1), (1 ..< grid.pX.count) ).flatMap { xPair in
    (0 ..< grid.pY.count).flatMap { y in
        (0 ..< grid.pZ.count).map { z in
          return Edge<ScallopParts>(content: .glassWall, p1: (xPair.0,y,z), p2: (xPair.1,y,z))
        }
    }
  }
  let y = zip( (0 ..< grid.pY.count-1), (1 ..< grid.pY.count) ).flatMap { yPair in
    (0 ..< grid.pX.count).flatMap { x in
        (0 ..< grid.pZ.count).map { z in
          return Edge<ScallopParts>(content: .glassWall, p1: (x,yPair.0,z), p2: (x,yPair.1,z))
        }
    }
  }
  return Array(x + y)
}


import Interface
public class ScallopGraph : GraphHolder {
  public typealias Content = ScallopParts
  public var id : String
  public var edges : [Edge<Content>]
  public var grid : GraphPositions
  
  public init(positions: GraphPositions, edges:[Edge<Content>], id:String="MODEMOCK") {
    self.edges = edges
    self.grid = positions
    self.id = id
  }
}


extension ScallopGraph {
  public convenience init() {
    let (pos, edges) = createScallopGroup(from: CGSize3(width:Scallop.width, depth:Scallop.depth, elev:Scallop.height))
    self.init(positions:pos, edges:edges)
  }
  
}

extension QuadState where Holder == ScallopGraph {
  public init (graph: ScallopGraph = ScallopGraph(), size: CGSize = UIScreen.main.bounds.size, sizePreferences : [CGFloat] = [100.0]) {
    self.sizePreferences = sizePreferences
    
    xOffset = 50
    yOffset = 200
    zOffset = 200
    xOffsetR = 50
    yOffsetR = 200
    
    let planOrigin : CGPoint = CGPoint(xOffset, yOffset)
    let rotatedOrigin : CGPoint = CGPoint(yOffsetR, xOffsetR)
    let frontOrigin  : CGPoint = CGPoint(xOffset, zOffset)
    let sideOrigin  : CGPoint = CGPoint(yOffsetR, zOffset)
    
    pageState = PageState(currentlyTop: true, currentlyLeft: true)
    
    let myGraph = graph
    planState = InterfaceState(
      graph: myGraph,
      mapping: [scallopPlanMap],
      sizePreferences: self.sizePreferences,
      scale: self.scale,
      windowBounds: size.asRect(),
      offset: planOrigin)
    rotatedPlanState = InterfaceState(
      graph: myGraph,
      mapping: [scallopPlanMapRotated],
      sizePreferences: self.sizePreferences,
      scale: self.scale,
      windowBounds: size.asRect(),
      offset: rotatedOrigin)
    frontState = InterfaceState(
      graph: myGraph,
      mapping: [scallopFrontMap],
      sizePreferences: self.sizePreferences,
      scale: self.scale,
      windowBounds: size.asRect(),
      offset: frontOrigin)
    sideState = InterfaceState(
      graph: myGraph,
      mapping: [scallopSideMap],
      sizePreferences: self.sizePreferences,
      scale: self.scale,
      windowBounds: size.asRect(),
      offset: sideOrigin)
  }
}
