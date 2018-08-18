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

let createScaffolding = CGSize3.init >>> createGrid >>> ScaffGraph.init

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
  typealias ID = String
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

struct ItemList<T> {
  init<S:Sequence> (_ s: S) where S.Element == Item<T> {
    self.store = zip(0...,s).reduce([:]) { (res, next) in
      let (seqIndex, item) = next
      print(res.keys, item.id)
      guard !res.keys.contains(item.id) else { fatalError("ItemList initialized with a repeating ID")}

      var mutRes = res
      mutRes[item.id] = IndexGroup(item: item, index: seqIndex)
      return mutRes
    }
  }
  
  typealias ID = Item<T>.ID
  struct IndexGroup {
    let item: Item<T>,index: Int
  }
  
  private var store: [ID:IndexGroup] = [:]
  var contents: [Item<T>] {
    get {
      return store.sorted { (tup1, tup2) -> Bool in
        tup1.value.index < tup2.value.index
        }.map{ val in
          return val.value.item
      }
    }
  }

  
  func getItem(id: ID ) -> Item<T>? {
    return store[id]?.item
  }
  
  mutating func addOrReplace(item: Item<T>) {
    
    if let previous = store[item.id] {
      store[item.id] = IndexGroup(item: item, index: previous.index)
    }
    else {
      let lastGreatestIndex = store.reduce(0) { (result, next) -> Int in
        return result < next.value.index
          ? next.value.index
          : result
      }
      
      store[item.id] = IndexGroup(item: item, index: lastGreatestIndex + 1)
    }
  }

}
extension ItemList.IndexGroup : Codable where T : Codable { }
extension ItemList : Codable where T : Codable { }



typealias ScaffItem = Item<ScaffGraph>

extension Array where Element == ScaffItem {
  static var mock : Array<ScaffItem> = [.mock, .mock, .mock]
}
extension ItemList where T == ScaffGraph {
  static var mock : ItemList<ScaffGraph> = {
    var list = ItemList([
      Item(content: (100,100,450) |> createScaffolding, id: "Mock0", name: "First Graph"),
      Item(content: (1000,1000,100) |> createScaffolding, id: "Mock1", name: "Second Graph"),
      Item(content: (500,1000,1000) |> createScaffolding, id: "Mock2", name: "Third Graph")])
    list.addOrReplace(item: Item(content: (500,300,1000) |> createScaffolding, id: "Mock3", name: "Force Graph"))

    return list
  }()
}

enum Result<Value, Error> {
  case success(Value)
  case error(Error)
}

struct FileIO {
  var load = loadItems
  var save = saveItems
  
  
}

enum LoadError : Error {
  case noData
  case noJson
}

func loadItems()  -> Result<ItemList<ScaffGraph>, LoadError> {
  guard let data = FileManager.default.contents(atPath: "items.json") else {
    return .error( LoadError.noData )
  }
  do {
    let decoder = JSONDecoder()
    let jsonData = try decoder.decode(ItemList<ScaffGraph>.self, from: data)
    return .success(jsonData)
  } catch  {
    return .error( .noJson )
  }
}



func saveItems(item: ItemList<ScaffGraph>) {
  let encoder = JSONEncoder()
  encoder.outputFormatting = .prettyPrinted
  let data = try! encoder.encode(item)
  print(String(data: data, encoding: .utf8)!)
  try! data.write(to: Current.persistenceURL)
}

extension FileIO {
  static var mock : FileIO = FileIO( load: {
    return .success(.mock)
  }, save: {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data = try! encoder.encode($0)
    print(String(data: data, encoding: .utf8)!)
  })
}

func getPersistenceURL() -> URL {
  let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
  let fileURL = documentDirectory.appendingPathComponent("Items.json")
  return fileURL
}



struct Environment {
  var persistenceURL : URL = getPersistenceURL()
  var file = FileIO()
  var model : ItemList<ScaffGraph> = ItemList([]) {
    didSet{
      file.save(model)
    }
  }
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
    persistenceURL:  URL(string: "TestUrl")!,
    file: .mock,
    model: .mock,
    screen: CGRect(0,0,300, 600),
    viewMaps: .mock,
    scale: 1.0)
}


var Current = Environment()


let scaleChangeNotification : Notification<CGFloat> = Notification(name: "Scale Changed")
