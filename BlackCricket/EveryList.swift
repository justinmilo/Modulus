//
//  EveryList.swift
//  BlackCricket
//
//  Created by Justin Smith on 12/1/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation


struct EveryList<A,B>
{
  var list1 : Array<A>
  var list2 : Array<B>
  
  init(_ l1: Array<A>, _ l2: Array<B>)
  {
    list1 = l1; list2 = l2
  }
  
  func map<T>(_ transform: ((A, B)) throws -> T) rethrows -> [T]
  {
    var a : [T] = []
    for l in list1 {
      
      let c = try! LongestList( [l], list2).map(transform)
      a.append(contentsOf: c)
    }
    return a
  }
}
