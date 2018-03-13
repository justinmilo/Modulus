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
  higherThan: ForwardApplication
  
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
