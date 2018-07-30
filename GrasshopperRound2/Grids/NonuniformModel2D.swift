//
//  NonuniformModel2D.swift
//  HandlesRound1
//
//  Created by Justin Smith on 1/31/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import CoreGraphics
import Singalong

struct NonuniformModel2D {
  var origin: CGPoint
  var rowSizes: Grid
  var colSizes: Grid
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
