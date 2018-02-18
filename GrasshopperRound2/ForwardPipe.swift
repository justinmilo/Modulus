//
//  ForwardPipe.swift
//  HandlesRound1
//
//  Created by Justin Smith on 1/21/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation

import Foundation


precedencegroup EffectfulComposition {
  associativity: left
  higherThan: ForwardApplication
}

infix operator >=>: EffectfulComposition
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

func >=> <A, B, C> (_ f: @escaping (A) -> ([B]),
                    _ g: @escaping (B) -> ([C])) -> (A) -> ([C])
{
  return { a in
    let b = f(a)
    let c = b.flatMap(g)
    return c
  }
}

precedencegroup SingleTypeComposition {
  associativity: left
  higherThan: ForwardApplication
}

infix operator <>: SingleTypeComposition

func <> <A>(f: @escaping (A) -> A,
            g: @escaping (A) -> A) -> (A) -> A {
  return f >>> g
}



precedencegroup ForwardApplication {
  associativity: left
}

infix operator |> : ForwardApplication // Forward pipe operator
infix operator |>> : ForwardApplication // Pipe into second argument
infix operator |>>> : ForwardApplication // Pipe into third argument
infix operator |< : ForwardApplication // Pipe into last argument
// MARK: First argument
public func |> <A,Z>(lhs: A, rhs: (A) -> Z) -> Z {
  return rhs(lhs)
}

public func |> <A,B,Z>(lhs: A, rhs: ((A, B) -> Z, B)) -> Z {
  return rhs.0(lhs, rhs.1)
}

public func |> <A,B,C,Z>(lhs: A, rhs: (((A, B, C) -> Z), B, C)) -> Z {
  return rhs.0(lhs, rhs.1, rhs.2)
}

public func |> <A,B,C,D,Z>(lhs: A, rhs: (((A, B, C, D) -> Z), B, C, D)) -> Z {
  return rhs.0(lhs, rhs.1, rhs.2, rhs.3)
}

public func |> <A,B,C,D,E,Z>(lhs: A, rhs: (((A, B, C, D, E) -> Z), B, C, D, E)) -> Z {
  return rhs.0(lhs, rhs.1, rhs.2, rhs.3, rhs.4)
}

public func |> <A,B,C,D,E,F,Z>(lhs: A, rhs: (((A, B, C, D, E, F) -> Z), B, C, D, E, F)) -> Z {
  return rhs.0(lhs, rhs.1, rhs.2, rhs.3, rhs.4, rhs.5)
}

// MARK: Second argument
public func |>> <A,B,Z>(lhs: B, rhs: ((A, B) -> Z, A)) -> Z {
  return rhs.0(rhs.1, lhs)
}

public func |>> <A,B,C,Z>(lhs: B, rhs: (((A, B, C) -> Z), A, C)) -> Z {
  return rhs.0(rhs.1, lhs, rhs.2)
}

public func |>> <A,B,C,D,Z>(lhs: B, rhs: (((A, B, C, D) -> Z), A, C, D)) -> Z {
  return rhs.0(rhs.1, lhs, rhs.2, rhs.3)
}

public func |>> <A,B,C,D,E,Z>(lhs: B, rhs: (((A, B, C, D, E) -> Z), A, C, D, E)) -> Z {
  return rhs.0(rhs.1, lhs, rhs.2, rhs.3, rhs.4)
}

public func |>> <A,B,C,D,E,F,Z>(lhs: B, rhs: (((A, B, C, D, E, F) -> Z), A, C, D, E, F)) -> Z {
  return rhs.0(rhs.1, lhs, rhs.2, rhs.3, rhs.4, rhs.5)
}

// MARK: Third argument
public func |>>> <A,B,C,Z>(lhs: C, rhs: (((A, B, C) -> Z), A, B)) -> Z {
  return rhs.0(rhs.1, rhs.2, lhs)
}

public func |>>> <A,B,C,D,Z>(lhs: C, rhs: (((A, B, C, D) -> Z), A, B, D)) -> Z {
  return rhs.0(rhs.1, rhs.2, lhs, rhs.3)
}

public func |>>> <A,B,C,D,E,Z>(lhs: C, rhs: (((A, B, C, D, E) -> Z), A, B, D, E)) -> Z {
  return rhs.0(rhs.1, rhs.2, lhs, rhs.3, rhs.4)
}

public func |>>> <A,B,C,D,E,F,Z>(lhs: C, rhs: (((A, B, C, D, E, F) -> Z), A, B, D, E, F)) -> Z {
  return rhs.0(rhs.1, rhs.2, lhs, rhs.3, rhs.4, rhs.5)
}

// MARK: Last Argument
public func |< <A,Z>(lhs: A, rhs: (A) -> Z) -> Z {
  return rhs(lhs)
}

public func |< <A,B,Z>(lhs: B, rhs: ((A, B) -> Z, A)) -> Z {
  return rhs.0(rhs.1, lhs)
}

public func |< <A,B,C,Z>(lhs: C, rhs: (((A, B, C) -> Z), A, B)) -> Z {
  return rhs.0(rhs.1, rhs.2, lhs)
}

public func |< <A,B,C,D,Z>(lhs: D, rhs: (((A, B, C, D) -> Z), A, B, C)) -> Z {
  return rhs.0(rhs.1, rhs.2, rhs.3, lhs)
}

public func |< <A,B,C,D,E,Z>(lhs: E, rhs: (((A, B, C, D, E) -> Z), A, B, C, D)) -> Z {
  return rhs.0(rhs.1, rhs.2, rhs.3, rhs.4, lhs)
}

public func |< <A,B,C,D,E,F,Z>(lhs: F, rhs: (((A, B, C, D, E, F) -> Z), A, B, C, D, E)) -> Z {
  return rhs.0(rhs.1, rhs.2, rhs.3, rhs.4, rhs.5, lhs)
}
