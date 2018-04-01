//
//  EffectfulCompose.swift
//  HandlesRound1
//
//  Created by Justin Smith on 3/13/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation


precedencegroup EffectfulComposition {
  associativity: left
  higherThan: SingleTypeComposition
  
}

infix operator >=>: EffectfulComposition


func >=> <A, B, C> (_ f: @escaping (A) -> ([B]),
                    _ g: @escaping (B) -> ([C])) -> (A) -> ([C])
{
  return { a in
    let b = f(a)
    let c = b.flatMap(g)
    return c
  }
}

func >=> <A, B, C>(
  _ f: @escaping (A) -> (B, [String]),
  _ g: @escaping (B) -> (C, [String])
  ) -> (A) -> (C, [String]) {
  
  return { a in
    let (b, logs) = f(a)
    let (c, moreLogs) = g(b)
    return (c, logs + moreLogs)
  }
}

func >=> <A, B, C>(
  _ f: @escaping (A) -> B?,
  _ g: @escaping (B) -> C?
  ) -> ((A) -> C?) {
  
  return { a in
    let b = f(a)
    switch b
    {
    case .some(let v): return g(v)
    case .none: return nil
    }
  }
}


//func >=> <A, B, C> (_ f: @escaping (A) -> Predicate<B>,
//                    _ g: @escaping (B) -> Predicate<C>) -> (A) -> Predicate<C>
//{
//  return { a in
//    let b = f(a)
//    let
//    return c
//  }
//}
