//
//  Accessors.swift
//  HandlesRound1
//
//  Created by Justin Smith on 4/12/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation


// pointfree getter
func get<Root, Value>(_ kp: KeyPath<Root, Value>) -> (Root) -> Value {
  return { root in
    root[keyPath: kp]
  }
}
// pointfree setter
func prop<Root, Value>(_ kp: WritableKeyPath<Root, Value>)
  -> (@escaping (Value) -> Value)
  -> (Root)
  -> Root {
    
    return { update in
      { root in
        var copy = root
        copy[keyPath: kp] = update(copy[keyPath: kp])
        return copy
      }
    }
}

func first<A,B,C>(_ value: (A,B,C)) -> A
{
  return value.0
}
func second<A,B,C>(_ value: (A,B,C)) -> B
{
  return value.1
}
func third<A,B,C>(_ value: (A,B,C)) -> C
{
  return value.2
}
