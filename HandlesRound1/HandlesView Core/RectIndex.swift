//
//  RectIndex.swift
//  HandlesRound1
//
//  Created by Justin Smith on 4/12/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation


struct RectIndex : Equatable {
  var index: Int
  fileprivate static let count = 4
  var oppositeIndex : RectIndex
  {
    get {
      if index + 2 < RectIndex.count {
        return RectIndex(index + 2)
      }
      else {
        return RectIndex(index - 2)
      }
    }
  }
  var clockwise : RectIndex
  {
    get {
      if index + 1 < RectIndex.count {
        return RectIndex(index + 1)
      }
      else {
        return RectIndex(index - 3)
      }
    }
  }
  var counterClockwise : RectIndex
  {
    get {
      if index - 1 >= 0 {
        return RectIndex(index - 1)
      }
      else {
        return RectIndex(index + 3)
      }
    }
  }
  init (_ intIndex: Int)
  {
    precondition(intIndex < RectIndex.count)
    
    index = intIndex
  }
}

let step : (Int, Int, RectIndex) -> RectIndex =
{
  if $2.index + $1 < $0 {
    return RectIndex($2.index + $1)
  }
  else {
    return RectIndex($2.index - $1)
  }
}

let fourBasedIndexStep = 4 |> curry(step)
let oppositeStep = 2 |> curry(fourBasedIndexStep)
let clockwiseStep = 1 |> curry(fourBasedIndexStep)
let counterClockwiseStep = (4 - 1) |> curry(fourBasedIndexStep)


