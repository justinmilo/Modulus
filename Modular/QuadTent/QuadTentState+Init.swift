//
//  TentView.swift
//  TentApp
//
//  Created by Justin Smith  on 11/27/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import UIKit
import SwiftUI
@testable import Interface
import ComposableArchitecture

extension QuadState where Holder == TentGraph {
  public init (graph: TentGraph = TentGraph(), size: CGSize = UIScreen.main.bounds.size, sizePreferences : [CGFloat] = [100.0]) {
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
      mapping: [tentPlanMap],
      sizePreferences: self.sizePreferences,
      scale: self.scale,
      windowBounds: size.asRect(),
      offset: planOrigin)
    rotatedPlanState = InterfaceState(
      graph: myGraph,
      mapping: [tentPlanMapRotated],
      sizePreferences: self.sizePreferences,
      scale: self.scale,
      windowBounds: size.asRect(),
      offset: rotatedOrigin)
    frontState = InterfaceState(
      graph: myGraph,
      mapping: [tentFrontMap],
      sizePreferences: self.sizePreferences,
      scale: self.scale,
      windowBounds: size.asRect(),
      offset: frontOrigin)
    sideState = InterfaceState(
      graph: myGraph,
      mapping: [tentSideMap],
      sizePreferences: self.sizePreferences,
      scale: self.scale,
      windowBounds: size.asRect(),
      offset: sideOrigin)
  }
}
