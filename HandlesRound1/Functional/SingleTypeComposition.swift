//
//  SingleTypeComposition.swift
//  HandlesRound1
//
//  Created by Justin Smith on 3/11/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//


precedencegroup SingleTypeComposition {
  associativity: left
  higherThan: ForwardApplication
}

infix operator <>: SingleTypeComposition

func <> <A>(f: @escaping (A) -> A,
            g: @escaping (A) -> A) -> (A) -> A {
  return f >>> g
}


