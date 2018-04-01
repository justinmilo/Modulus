//
//  FunctionalGrabBag.swift
//  HandlesRound1
//
//  Created by Justin Smith on 3/11/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation





// (A -> B, C ) (B, C) -> D

infix operator >>-> : ForwardOneParamaterComposition



infix operator <->: EffectfulComposition
infix operator <=>: EffectfulComposition


//func >=> <A, B, C> (_ f: @escaping (A) -> (B, [String]),
//                    _ g: @escaping (B) -> (C, [String])) -> (A) -> (C, [String])
//{
//  return { a in
//    let (b, logs) = f(a)
//    let (c, moreLogs) = g(b)
//    return (c, logs + moreLogs)
//  }
//}

func <=> <A, B, R> (_ f: @escaping (A) -> ([R]),
                    _ g: @escaping (B) -> ([R])) -> (A,B) -> ([R])
{
  return { (a,b) in
    return f(a) + g(b)
  }
}

func <-> <A, B> (_ f: @escaping (A) -> ([B]),
                 _ g: @escaping (A) -> ([B])) -> (A) -> ([B])
{
  return { a in
    return f(a) + g(a)
  }
}





precedencegroup ForwardOneParamaterComposition {
  associativity: left
  higherThan: ForwardComposition
}
func >>-><A, B, C, D>(lhs: ((A)->B, C), rhs: @escaping (B, C) -> D) -> (A)->D {
  return { a in rhs(lhs.0(a), lhs.1)}
}





func map<A, B>(_ t: @escaping (A) -> B, _ items: [A]) -> [B] {
  return items.map(t)
}
func map<A, B>(_ t: @escaping (A) -> B) -> ([A]) -> [B] {
  return {items in items.map(t) }
}


