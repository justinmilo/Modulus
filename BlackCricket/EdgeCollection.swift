//
//  EdgeCollection.swift
//  BlackCricket
//
//  Created by Justin Smith on 12/1/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation

// Grid
struct EdgeCollection{
  
  var all : [Line] {  get { return verticals + horizontals} }
  let verticals : [Line]
  let horizontals : [Line]
}

import Geo
func edges(numodel: NonuniformModel2D) -> EdgeCollection{
  
  let linesUp = numodel.orderedPointsLeftToRight.map{ Line(start: $0.first!, end: $0.last!) }
  let linesAcross = numodel.orderedPointsUpToDown.map{ Line(start: $0.first!, end: $0.last!) }
  
  return EdgeCollection(verticals:linesUp, horizontals:linesAcross)
}
