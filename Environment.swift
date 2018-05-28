//
//  Environment.swift
//  HandlesRound1
//
//  Created by Justin Smith on 5/27/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation
import Singalong

extension ScaffGraph
{
  convenience init()
  {
    let initial = CGSize3(width: 300, depth: 100, elev: 400) |> createGrid
    self.init(grid: initial.0, edges: initial.1)
  }
}

struct Environment {
  var graph = ScaffGraph()
}

var Current = Environment()
