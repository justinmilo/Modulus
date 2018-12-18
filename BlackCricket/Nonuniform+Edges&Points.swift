//
//  Nonuniform+Edges&Points.swift
//  BlackCricket
//
//  Created by Justin Smith on 12/2/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation

import Geo
import Singalong

extension NonuniformModel2D {
  var edgesAndPoints : (edges: EdgeCollection, points: PointCollection)
  {
    get {
      return ( self |> edges, self |> nonuniformToPoints)
    }
  }
}


