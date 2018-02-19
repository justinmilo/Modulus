//
//  NonuniformModel2D.swift
//  HandlesRound1
//
//  Created by Justin Smith on 1/31/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import CoreGraphics


struct NonuniformModel2D {
  var origin: CGPoint
  var rowSizes: Grid
  var colSizes: Grid
}

func nonuniformToPoints(numodel: NonuniformModel2D) -> PointCollection{
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

func pointsCombining<A,B,C>(e1s:[A], e2s:[B], combining:(A, B)->C) -> [[C]]
{
  return e1s.map { e1 in
    e2s.map { e2 in
      return combining(e1,e2)
    }
  }
}

func edges(numodel: NonuniformModel2D) -> EdgeCollection{
  
  let linesUp = numodel.orderedPointsLeftToRight.map{ Line(start: $0.first!, end: $0.last!) }
  let linesAcross = numodel.orderedPointsUpToDown.map{ Line(start: $0.first!, end: $0.last!) }
  
  return EdgeCollection(verticals:linesUp, horizontals:linesAcross)
}

extension NonuniformModel2D {
  
  var edgesAndPoints : (edges: EdgeCollection, points: PointCollection)
  {
    get {
      return ( self |> edges, self |> nonuniformToPoints)
    }
  }
  
  var xOrigins : [CGFloat] { return self.colSizes.positions.map { $0 + self.origin.x } }
  var yOrigins : [CGFloat] { return self.rowSizes.positions.map { $0 + self.origin.y } }
  
  var orderedPointsLeftToRight : [[CGPoint]] {
    return pointsCombining(e1s: xOrigins, e2s: yOrigins, combining: { CGPoint(x: $0, y: $1) })
  }
  var orderedPointsUpToDown : [[CGPoint]] {
    return pointsCombining(e1s: yOrigins, e2s: xOrigins, combining: { CGPoint(x: $1, y: $0) })
  }
  
  
}

extension NonuniformModel2D  {
  // Uniform initializer
  init(
    origin: CGPoint,
    dx: CGFloat,
    dy: CGFloat,
    col: Int,
    rows: Int)
  {
    self.init(origin: origin, rowSizes: Grid((0...rows).map{ CGFloat($0) * dx }) , colSizes: Grid((0...col).map{ CGFloat($0) * dy }))
  }
}
