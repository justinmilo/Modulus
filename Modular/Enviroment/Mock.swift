//
//  Mock.swift
//  Modular
//
//  Created by Justin Smith on 11/22/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation
import GrapheNaked
import Singalong

extension ScaffGraph {
  convenience init() {
    let initial = CGSize3(width: 300, depth: 100, elev: 400) |> createNusGrid
    self.init(id:"Mock", grid: initial.0, edges: initial.1)
  }
  
  convenience init(grid:GraphPositions, edges:[ScaffEdge]) {
     self.init(id:"Mock", grid: grid, edges: edges)
  }
  
  static var mock : ScaffGraph = CGSize3(width: 300, depth: 100, elev: 400) |> createNusGrid >>> curry(ScaffGraph.init)("Mock")
}

extension Item where Content == ScaffGraph {
  static var mock : Item<Content> = Item(content:ScaffGraph.mock, id: "Mock", name: "First Graph")
}

let defaultSizes = ScaffoldingGridSizes.mock.map{$0.centimeters}
let standardStack = curriedScaffoldingFrom(defaultSizes)



extension ItemList where T == ScaffGraph {
  static var mock : ItemList<ScaffGraph> = {
    var list = ItemList([
      Item(content: (100,100,450) |> CGSize3.init |> curriedScaffoldingFrom(defaultSizes), id: "Mock0", name: "None Graph"),
      Item(content: (1000,1000,100) |> CGSize3.init |> curriedScaffoldingFrom(defaultSizes), id: "Mock1", name: "Four by Eight"),
      Item(content: (500,1000,1000) |> CGSize3.init |> curriedScaffoldingFrom(defaultSizes), id: "Mock2", name: "Third Graph")])
    list.addOrReplace(item: Item(content: (500,300,1000) |> CGSize3.init |> curriedScaffoldingFrom(defaultSizes), id: "Mock3", name: "Force Graph"))
    
    addIDToScaffGraph(itemList: &list)
    //print("Mock ", list.getItem(id: "Mock0")?.sizePreferences)

    
    return list
  }()
}

extension StandardEditingViews {
  static var mock = StandardEditingViews()
}

extension Environment {
  static var mock = Environment(
    file: .mock,
    thumbnails: ThumbnailIO(),
    screen: CGRect(0,0,300, 600),
    viewMaps: .mock)
}
