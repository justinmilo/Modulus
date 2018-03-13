//
//  ForwardCompose.swift
//  HandlesRound1
//
//  Created by Justin Smith on 2/3/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation

precedencegroup ForwardComposition {
  associativity: left
  higherThan: EffectfulComposition
}

infix operator >>> : ForwardComposition

func >>> <A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> (A) -> C {
  return { a in
    g(f(a))
  }
}

func >>><A,B,C,D> (
  a: @escaping (A) -> (B) -> C,
  b: @escaping (C) -> D )
  -> (A) -> (B) -> (D)
{
  let plguncur = uncurry(a)
  let planUncurryed = tuple(plguncur) >>> b
  return curry(detuple(planUncurryed))
}


