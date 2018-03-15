//
//  SemiRing.swift
//  HandlesRound1
//
//  Created by Justin Smith on 3/5/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation

protocol Semiring {
  // **AXIOMS**
  //
  // Associativity:
  //    a + (b + c) == (a + b) + c
  //    a * (b * c) == (a * b) * c
  //
  // Identity:
  //   a + zero == zero + a == a
  //   a * one == one * a == a
  //
  // Commutativity of +:
  //   a + b == b + a
  //
  // Distributivity:
  //   a * (b + c) == a * b + a * c
  //   (a + b) * c == a * c + b * c
  //
  // Annihilation by zero:
  //   a * zero == zero * a == zero
  //
  static func + (lhs: Self, rhs: Self) -> Self
  static func * (lhs: Self, rhs: Self) -> Self
  static var zero: Self { get }
  static var one: Self { get }
}

extension Bool: Semiring {
  static func + (lhs: Bool, rhs: Bool) -> Bool {
    return lhs || rhs
  }
  
  static func * (lhs: Bool, rhs: Bool) -> Bool {
    return lhs && rhs
  }
  
  static let zero = false
  static let one = true
}

struct FunctionS<A, S: Semiring> {
  let call: (A) -> S
}

extension FunctionS: Semiring {
  static func + (lhs: FunctionS, rhs: FunctionS) -> FunctionS {
    return FunctionS { lhs.call($0) + rhs.call($0) }
  }
  
  static func * (lhs: FunctionS, rhs: FunctionS) -> FunctionS {
    return FunctionS { lhs.call($0) * rhs.call($0) }
  }
  
  static var zero: FunctionS {
    return FunctionS { _ in S.zero }
  }
  
  static var one: FunctionS {
    return FunctionS { _ in S.one }
  }
  
  
  

}



extension Sequence {
  func filtered(by p: Predicate<Element>) -> [Element] {
    return self.filter(p.call)
  }
}

func || <A> (lhs: Predicate<A>, rhs: Predicate<A>) -> Predicate<A> {
  return lhs + rhs
}

func && <A> (lhs: Predicate<A>, rhs: Predicate<A>) -> Predicate<A> {
  return lhs * rhs
}

prefix func ! <A> (p: Predicate<A>) -> Predicate<A> {
  return .init { !p.call($0) }
}

typealias Predicate<A> = FunctionS<A, Bool>

func contramap<A,B>(
  _ t: @escaping (A) -> B
  )  -> (Predicate<B>)
  -> Predicate<A>
{
  return {
    items in
    return  Predicate {
      a in
      return items.call(t(a))
    }
  }
}

