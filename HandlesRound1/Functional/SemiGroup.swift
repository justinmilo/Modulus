//
//  SemiGroup.swift
//  HandlesRound1
//
//  Created by Justin Smith on 3/11/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

protocol Semigroup {
  static func <>(lhs: Self, rhs: Self) -> Self
}

protocol Monoid: Semigroup {
  static var e: Self { get }
}

extension Array: Semigroup {
  static func <>(lhs: Array, rhs: Array) -> Array {
    return lhs + rhs
  }
}

extension Array: Monoid {
  static var e: Array { return  [] }
}


func concat <M: Monoid> (_ xs: [M]) -> M {
  return xs.reduce(M.e, <>)
}

extension Bool: Monoid {
  static func <>(lhs: Bool, rhs: Bool) -> Bool {
    return lhs && rhs
  }
  static let e = true
}

extension Int: Monoid {
  static func <>(lhs: Int, rhs: Int) -> Int {
    return lhs + rhs
  }
  static let e = 0
}

extension String: Monoid {
  static func <>(lhs: String, rhs: String) -> String {
    return lhs + rhs
  }
  static let e = ""
}


func <><A,B,C : Semigroup>(f:@escaping (A)->(B)->C, g:@escaping (A)->(B)->C) -> (A)->(B)->C
{
  return {
    a in
    return {
      b in
      return  f(a)(b) <> g(a)(b)
    }
  }
}

func <><A,B : Semigroup>(f:@escaping (A)->B, g:@escaping (A)->B) -> (A)->B
{
  return {
    a in
      return  f(a) <> g(a)
  }
}


func operatorSemigroup<A,B,C : Semigroup>(f:@escaping (A)->(B)->C, g:@escaping (A)->(B)->C) -> (A)->(B)->C
{
  return {
    a in
    return {
      b in
      return  f(a)(b) <> g(a)(b)
    }
  }
}


struct FunctionM<A, M: Monoid> {
  let call: (A) -> M
}
extension FunctionM: Monoid {
  static func <>(lhs: FunctionM, rhs: FunctionM) -> FunctionM {
    return FunctionM { x in
      return lhs.call(x) <> rhs.call(x)
    }
  }
  
  static var e: FunctionM {
    return FunctionM { _ in M.e }
  }
}

import SpriteKit

//extension SKNode : Semigroup
//{
//
//}

func <><A, B: SKNode>(
  f:@escaping (A)->(B)->Void,
  g: @escaping (A)->(B)->Void) -> (A)->(B)->Void
{ return { a in return f(a) <> g(a) } }

func <><B: SKNode>(f:@escaping (B)->Void, g: @escaping (B)->Void) -> (B)->Void
{ return { b in f(b); g(b) } }

