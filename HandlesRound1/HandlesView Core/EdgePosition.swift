//
//  Edge.swift
//  HandlesRound1
//
//  Created by Justin Smith on 4/15/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import CoreGraphics

enum EdgePosition
{
  case top
  case right
  case bottom
  case left
}

func positionToEdgePosition(position: Position2D) -> EdgePosition?
{
  switch position
  {
  case (.top, .center): return .top
  case (.bottom, .center): return .bottom
  case (.center, .left): return .left
  case (.center, .right): return .right
  default : return .none
  }
}

func unitVector(for position: EdgePosition) -> CGVector
{
  switch position
  {
  case .top, .bottom: return unitY
  case .left, .right: return unitX
  }
}


func positionPath(position: EdgePosition) -> WritableKeyPath<CGVector, CGFloat>
{
  switch position
  {
  case .top, .bottom: return \CGVector.dy
  case .left, .right: return \CGVector.dx
  }
}


func positionPath(position: EdgePosition) -> WritableKeyPath<CGSize, CGFloat>
{
  switch position
  {
  case .top, .bottom: return \CGSize.height
  case .left, .right: return \CGSize.width
  }
}


// FIXME could be replacingEdge(at position: Position2D, with: CGFloat)->(CGRect)->CGRect
// let changingEdge : (EdgePosition, CGFloat) -> (CGRect) -> CGRect =
// func increasingEdge(at pos: EdgePosition, with offset:CGFloat) -> (CGRect) -> CGRect

