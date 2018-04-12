//
//  RectIndex.swift
//  HandlesRound1
//
//  Created by Justin Smith on 4/12/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation


struct RectIndex : Equatable {
  // Accessors
  var index: Int
  fileprivate static let count = 4 // FIXME: Should be variable and local
  
  // Accessors
  var opposite : RectIndex { return self |> oppositeStep }
  var clockwise : RectIndex { return self |> clockwiseStep }
  var counterClockwise : RectIndex { return self |> counterClockwiseStep }
  
  // Init
  init (_ intIndex: Int)
  {
    precondition(intIndex < RectIndex.count)
    
    index = intIndex
  }
}

let stepRectIndex : (Int, Int, RectIndex) -> RectIndex =
{
  if $2.index + $1 < $0 {
    return RectIndex($2.index + $1)
  }
  else {
    return RectIndex($2.index - $1)
  }
}
let fourBasedIndexStep = 4 |> curry(stepRectIndex) // FIXME: duplicating above

let oppositeStep = 2 |> curry(fourBasedIndexStep)
let clockwiseStep = 1 |> curry(fourBasedIndexStep)
let counterClockwiseStep = (4 - 1) |> curry(fourBasedIndexStep)


