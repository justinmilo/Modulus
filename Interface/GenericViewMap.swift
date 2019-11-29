//
//  GenericViewMap.swift
//  Interface
//
//  Created by Justin Smith Nussli on 11/24/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import Foundation
import CoreGraphics
import GrapheNaked
import BlackCricket

public struct GenericEditingView<Holder : GraphHolder> {
  /// takes a bounding box size, and any existing structure ([Edge]) to interprit a new ScaffGraph,a fully 3D structure
  let build: ([CGFloat], CGSize3, [Edge<Holder.Content>]) -> (GraphPositions, [Edge<Holder.Content>])
  
  /// origin: in this editing view slice, the offset from the 0,0 corner of the bounding box
  let origin : (Holder) -> CGPoint
  /// Related to the size of the bounding box
  let size : (Holder) -> CGSize
  
  /// Translates this view's 2D rep to 3D boounding box based on the graph and view semantics
  let size3 : (Holder) -> (CGSize) -> CGSize3
  
  /// From Graph to Geometry at (0,0)
  /// Geometry bounds is not necisarily the same as the size, which is a bounding box
  let composite : (Holder) -> Composite
  
  /// related to the entire composite
  let grid2D : (Holder) -> GraphPositions2DSorted
  
  /// if point index in 2D give new 3D edges
  let selectedCell : (PointIndex2D, GraphPositions, [Edge<Holder.Content>]) -> ([Edge<Holder.Content>])
  
  
  public init(
    build: @escaping ([CGFloat], CGSize3, [Edge<Holder.Content>]) -> (GraphPositions, [Edge<Holder.Content>]),
    origin : @escaping (Holder) -> CGPoint,
    size : @escaping (Holder) -> CGSize,
    size3 : @escaping (Holder) -> (CGSize) -> CGSize3,
    composite : @escaping (Holder) -> Composite,
    grid2D : @escaping (Holder) -> GraphPositions2DSorted,
    selectedCell : @escaping (PointIndex2D, GraphPositions, [Edge<Holder.Content>]) -> ([Edge<Holder.Content>])
  ) {
    
    self.build = build
    self.origin = origin
    self.size  = size
    self.size3 = size3
    self.composite = composite
    self.grid2D = grid2D
    self.selectedCell = selectedCell
  }
}
