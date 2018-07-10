//
//  Environment.swift
//  HandlesRound1
//
//  Created by Justin Smith on 5/27/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation
import Singalong
import Graphe

extension ScaffGraph
{
  convenience init()
  {
    let initial = CGSize3(width: 300, depth: 100, elev: 400) |> createGrid
    self.init(grid: initial.0, edges: initial.1)
  }
}

struct EditingViews {
  struct ViewMap { let label: String; let viewMap: [GraphEditingView] }
  var plan : ViewMap = ViewMap(label: "Plan View", viewMap: planMap)
  var rotatedPlan : ViewMap = ViewMap(label: "Rotated Plan View", viewMap: planMapRotated)
  var front : ViewMap = ViewMap(label: "Front View", viewMap: frontMap)
  var side : ViewMap = ViewMap( label: "Side View", viewMap: sideMap)
}

struct Environment {
  var graph = ScaffGraph()
  var screen = UIScreen.main.bounds
  var viewMaps = EditingViews()
  var scale : CGFloat = 1.0
  {
    didSet {
      postNotification(note: scaleChangeNotification, value: scale)
    }
  }
}

var Current = Environment()


let scaleChangeNotification : Notification<CGFloat> = Notification(name: "Scale Changed")
