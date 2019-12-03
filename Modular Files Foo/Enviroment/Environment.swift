//
//  Environment.swift
//  HandlesRound1
//
//  Created by Justin Smith on 5/27/18.
//  Copyright © 2018 Justin Smith. All rights reserved.fs
//

import Foundation
import Singalong
import GrapheNaked



struct StandardEditingViews {
  var plan  = (label: "Plan View", viewMap: planMap)
  var rotatedPlan = (label: "Rotated Plan View", viewMap: planMapRotated)
  var front = (label: "Front View", viewMap: frontMap)
  var side = ( label: "Side View", viewMap: sideMap)
}



struct Environment {
  var file = FileIO()
  var thumbnails = ThumbnailIO()
  //var model : ItemList<ScaffGraph> = ItemList([])
  var screen = UIScreen.main.bounds
  var viewMaps = StandardEditingViews()
}


var Current = Environment()

import Interface
