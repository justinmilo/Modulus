//
//  Curry.swift
//  HandlesRound1
//
//  Created by Justin Smith on 3/11/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//



public func curry<A, B, C>(_ f : @escaping (A, B) -> C) -> (A) -> (B) -> C {
  return { (a : A) -> (B) -> C in
    { (b : B) -> C in
      
      f(a, b)
    }
  }
}

public func curry<A, B, C, D>(_ f : @escaping (A, B, C) -> D) -> (A) -> (B, C) -> D {
  return { (a : A) -> (B, C) -> D in
    { (b : B, c: C) -> D in
      
      f(a, b, c)
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
func detuple<A,B,C,D>(_ t: @escaping ((A,B,C))->D)->(A,B,C)->D
{
  return { a,b,c in
    return t((a,b,c))
  }
}


func tuple<A,B,C>(_ t: @escaping (A,B)->C)->((A,B))->C
{
  return { tup in
    return t(tup.0,tup.1)
  }
}

func flip<A,B,C>(_ t: @escaping (A) -> (B) -> C) -> (B)->(A)->(C)
{
  return { b in return { a in return t(a)(b) }}
}
