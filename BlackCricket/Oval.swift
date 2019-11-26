//
//  Oval.swift
//  BlackCricket
//
//  Created by Justin Smith on 12/1/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation

public struct Oval : Geometry {
  var ellipseOf: CGSize
  var lineWidth = 1.0
  var fillColor : UIColor = .blue
  public var position : CGPoint = CGPoint.zero
  init(ellipseOf: CGSize) { self.ellipseOf = ellipseOf }
}

public extension Oval {
  init(size: CGSize, position: CGPoint) {
    ellipseOf = size
    self.position = position
  }
}

