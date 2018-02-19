//
//  ForwardCompose.swift
//  HandlesRound1
//
//  Created by Justin Smith on 2/3/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation


infix operator >>> : ForwardComposition

func >>> <A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> (A) -> C {
  return { a in
    g(f(a))
  }
}

precedencegroup ForwardComposition {
  associativity: left
  higherThan: ForwardApplication
}

// (A -> B, C ) (B, C) -> D

infix operator >>-> : ForwardOneParamaterComposition

precedencegroup ForwardOneParamaterComposition {
  associativity: left
  higherThan: ForwardComposition
}
func >>-><A, B, C, D>(lhs: ((A)->B, C), rhs: @escaping (B, C) -> D) -> (A)->D {
  return { a in rhs(lhs.0(a), lhs.1)}
}
