//
//  StrongestList.swift
//  BlackCricket
//
//  Created by Justin Smith on 12/1/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation


struct LongestList<A,B>
{
  var list1 : Array<A>
  var list2 : Array<B>
  
  init(_ l1: Array<A>, _ l2: Array<B>)
  {
    list1 = l1; list2 = l2
  }
  
  func map<T>(_ transform: ((A, B)) throws -> T) rethrows -> [T]
  {
    let longestIs1 = list1.count > list2.count
    
    if longestIs1 {
      let newList = list2 + Array(repeatElement(list2.last!, count: list1.count - list2.count))
      let zipped = zip(list1, newList)
      return zipped.map{ try! transform($0) }
    }
    else {
      let newList = list1 + Array(repeatElement(list1.last!, count: list2.count - list1.count))
      let zipped = zip(newList, list2)
      return zipped.map{ try! transform($0) }
    }
    
  }
}
