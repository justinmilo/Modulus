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
  
  static var mock : ScaffGraph = CGSize3(width: 300, depth: 100, elev: 400) |> createGrid >>> ScaffGraph.init
  
}

struct EditingViews {
  struct ViewMap { let label: String; let viewMap: [GraphEditingView] }
  var plan : ViewMap = ViewMap(label: "Plan View", viewMap: planMap)
  var rotatedPlan : ViewMap = ViewMap(label: "Rotated Plan View", viewMap: planMapRotated)
  var front : ViewMap = ViewMap(label: "Front View", viewMap: frontMap)
  var side : ViewMap = ViewMap( label: "Side View", viewMap: sideMap)
}



struct Item<Content> : Equatable {
  static func == (lhs: Item<Content>, rhs: Item<Content>) -> Bool {
    return lhs.id == rhs.id
  }
  
  let content: Content
  let id: String
  let name: String
}

extension Item : Codable where Content : Codable { }
extension Item where Content == ScaffGraph {
  static var mock : Item<Content> = Item(content:ScaffGraph.mock, id: "Mock", name: "First Graph")
}

typealias ScaffItem = Item<ScaffGraph>

enum Result<Value, Error> {
  case success(Value)
  case error(Error)
}

struct Filer {
  var load = loadItems
  var save = saveItems
}

func loadItems(completion: (Result<ScaffItem, Swift.Error>) -> Void) {
  
}

func saveItems(item: ScaffItem) {
  let encoder = JSONEncoder()
  encoder.outputFormatting = .prettyPrinted
  let data = try! encoder.encode(item)
  print(String(data: data, encoding: .utf8)!)
}

extension Filer {
  static var mock : Filer = Filer( load: { completion in
    completion(.success(.mock))
  }, save: {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data = try! encoder.encode($0)
    print(String(data: data, encoding: .utf8)!)
  })
}

struct Environment {
  var file = Filer()
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

extension EditingViews {
  static var mock = EditingViews()
}

extension Environment {
  static var mock = Environment(
    file: .mock,
    graph: .mock,
    screen: CGRect(0,0,300, 600),
    viewMaps: .mock,
    scale: 1.0)
}


var Current = Environment()


let scaleChangeNotification : Notification<CGFloat> = Notification(name: "Scale Changed")
