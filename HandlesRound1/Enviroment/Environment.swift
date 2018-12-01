//
//  Environment.swift
//  HandlesRound1
//
//  Created by Justin Smith on 5/27/18.
//  Copyright © 2018 Justin Smith. All rights reserved.fs
//

import Foundation
import Singalong
import Graphe



struct EditingViews {
  struct LabeledViewMap { let label: String; let viewMap: [GraphEditingView] }
  var plan : LabeledViewMap = LabeledViewMap(label: "Plan View", viewMap: planMap)
  var rotatedPlan : LabeledViewMap = LabeledViewMap(label: "Rotated Plan View", viewMap: planMapRotated)
  var front : LabeledViewMap = LabeledViewMap(label: "Front View", viewMap: frontMap)
  var side : LabeledViewMap = LabeledViewMap( label: "Side View", viewMap: sideMap)
}



struct Environment {
  var file = FileIO()
  var model : ItemList<ScaffGraph> = ItemList([])
  var screen = UIScreen.main.bounds
  var viewMaps = EditingViews()
}


var Current = Environment()

let scaleChangeNotification : Notification<CGFloat> = Notification(name: "Scale Changed")
