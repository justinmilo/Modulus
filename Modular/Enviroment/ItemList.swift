//
//  ItemList.swift
//  Modular
//
//  Created by Justin Smith on 11/22/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation

struct ItemList<T:Equatable> : Equatable {
   
  init<S:Sequence> (_ s: S) where S.Element == Item<T> {
    self.store = zip(0...,s).reduce([:]) { (res, next) in
      let (seqIndex, item) = next
      guard !res.keys.contains(item.id) else { fatalError("ItemList initialized with a repeating ID")}
      
      var mutRes = res
      mutRes[item.id] = IndexGroup(item: item, index: seqIndex)
      return mutRes
    }
  }
  
  typealias ID = Item<T>.ID
   struct IndexGroup : Equatable{
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


