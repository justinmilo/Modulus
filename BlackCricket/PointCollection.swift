//
//  PointCollection.swift
//  BlackCricket
//
//  Created by Justin Smith on 12/1/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation

public struct PointCollection {
  let all : [CGPoint]
  var boundaries : [CGPoint] { get { return top + right + bottom + left} }
  // sections
  let top : [CGPoint]
  let right : [CGPoint]
  let bottom : [CGPoint]
  let left : [CGPoint]
}

import Geo
public func nonuniformToPoints(numodel: NonuniformModel2D) -> PointCollection{
  let ltr = numodel.orderedPointsLeftToRight
  let utd = numodel.orderedPointsUpToDown
  
  return PointCollection(
    all: ltr.flatMap{ $0 },
    top: utd.last!,
    right: ltr[0],
    bottom: utd[0],
    left: ltr.last!
  )
}
