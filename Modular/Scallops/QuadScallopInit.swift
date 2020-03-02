//
//  QuadScallopInit.swift
//  Modular
//
//  Created by Justin Smith  on 1/16/20.
//  Copyright © 2020 Justin Smith. All rights reserved.
//

import Foundation
import GrapheNaked
import Singalong
import Interface

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
