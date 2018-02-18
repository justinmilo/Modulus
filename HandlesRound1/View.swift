//
//  View.swift
//  HandlesRound1
//
//  Created by Justin Smith on 2/7/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation

precedencegroup Semigroup { associativity: left }
infix operator <>: Semigroup

protocol Semigroup {
  static func <>(lhs: Self, rhs: Self) -> Self
}

protocol Monoid: Semigroup {
  static var e: Self { get }
}

extension Array: Monoid {
  static var e: Array { return  [] }
  static func <>(lhs: Array, rhs: Array) -> Array {
    return lhs + rhs
  }
}



struct View<D, N: Monoid> {
  let view: (D) -> N
  
  init(_ view: @escaping (D) -> N) {
    self.view = view
  }
}


