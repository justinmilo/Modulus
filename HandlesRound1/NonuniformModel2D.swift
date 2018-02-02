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

extension NonuniformModel2D {
  
  var edgesAndPoints : (edges: EdgeCollection, points: PointCollection)
  {
    get {
      
      
      let pointsLeftToRight = orderedPointsLeftToRight
      
      let pointsUpToDown = orderedPointsUpToDown
      
      let linesUp = pointsLeftToRight.map{ Line(start: $0.first!, end: $0.last!) }
      let linesAcross = pointsUpToDown.map{ Line(start: $0.first!, end: $0.last!) }
      
      return (edges: EdgeCollection(verticals:linesUp, horizontals:linesAcross), points: PointCollection(
        all: pointsLeftToRight.flatMap{ $0 },
        top: pointsUpToDown.last!,
        right: pointsLeftToRight[0],
        bottom: pointsUpToDown[0],
        left: pointsLeftToRight.last!
      ))
    }
    
    
    
  }
  
  var xOrigins : [CGFloat] { return self.colSizes.positions.map { $0 + self.origin.x } }
  var yOrigins : [CGFloat] { return self.rowSizes.positions.map { $0 + self.origin.y } }
  
  var orderedPointsLeftToRight : [[CGPoint]]
  {
    return xOrigins.map { x in
      yOrigins.map { y in
        return CGPoint(x,y)
      }
    }
  }
  
  var orderedPointsUpToDown : [[CGPoint]]
  {
    return  yOrigins.map { y in
      xOrigins.map { x in
        return CGPoint(x,y)
      }
    }
  }
  
  
  
}

extension NonuniformModel2D  {
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
