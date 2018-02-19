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


public func curry<A, B, C>(_ f : @escaping (A, B) -> C) -> (A) -> (B) -> C {
  
  return { (a : A) -> (B) -> C in
    { (b : B) -> C in
      
      f(a, b)
    }
  }
  
}

public func uncurry<A, B, C>(_ f : @escaping (A) -> (B) -> C) -> (A, B) -> C {
  
  return { (a : A, b: B) -> C in
    return f(a)(b)
  }
  
}

func detuple<A,B,C>(_ t: @escaping ((A,B))->C)->(A,B)->C
{
  return { a,b in
    return t((a,b))
  }
}
