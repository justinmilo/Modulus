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

func first<A, B, C>(_ f: @escaping (A) -> C) -> ((A, B)) -> (C, B) {
  return { pair in
    return (f(pair.0), pair.1)
  }
}

func first<A, B, C, T>(_ f: @escaping (A) -> T) -> ((A, B, C)) -> (T, B, C) {
  return { pair in
    return (f(pair.0), pair.1, pair.2)
  }
}


func second<A, B, C>(_ f: @escaping (B) -> C) -> ((A, B)) -> (A, C) {
  return { pair in
    return (pair.0, f(pair.1))
  }
}


func second<A, B, C, T>(_ f: @escaping (B) -> T) -> ((A, B, C)) -> (A, T, C) {
  return { pair in
    return (pair.0, f(pair.1), pair.2)
  }
}

func third<A, B, C, T>(_ f: @escaping (C) -> T) -> ((A, B, C)) -> (A, B, T) {
  return { pair in
    return (pair.0, pair.1, f(pair.2))
  }
}

