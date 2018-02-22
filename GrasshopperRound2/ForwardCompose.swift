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

func tuple<A,B,C>(_ t: @escaping (A,B)->C)->((A,B))->C
{
  return { tup in
    return t(tup.0,tup.1)
  }
}



import SpriteKit

func <><A, B: SKNode>(
  f:@escaping (A)->(B)->Void,
  g: @escaping (A)->(B)->Void) -> (A)->(B)->Void
{ return { a in return f(a) <> g(a) } }

func <><B: SKNode>(f:@escaping (B)->Void, g: @escaping (B)->Void) -> (B)->Void
{ return { b in f(b); g(b) } }


