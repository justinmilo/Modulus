//
//  Dimensions.swift
//  BlackCricket
//
//  Created by Justin Smith on 12/2/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation
import Singalong
import Geo


public typealias DimFormat = (CGFloat) -> String


/// CGPoint, CGVector -> Label
func dimPoints( points: (CGPoint, CGPoint), direction: CGVector, formatter: DimFormat )-> Label {
  let d = points |> distanceBetween |> formatter
  let c = points |> center
  let o = (c, direction) |> move
  let l = o.position |> pointToLabel
  let l2 = (l, d) |> setLabel
  return l2
}

/// Offset, CGVector -> Label
public func dimension(_ d: CGFloat, formatter: @escaping DimFormat) -> (BorderPoints) -> [Label] {
  // convert handle points to dim points
  // convert handle points to dim points
  
  return { points in
    let mids : [Label] =
      points.top |> dimTop(d, formatter: formatter) +
        points.right |> dimRight(d, formatter: formatter) +
        points.bottom |> dimBottom(d, formatter: formatter) +
        points.left |> dimLeft(d, formatter: formatter)
    return mids
  }
}

public func dimTop(_ d: CGFloat, formatter: @escaping DimFormat) -> ([CGPoint]) -> [Label] {
  let dimStyle = { ($0, (unitY * d), formatter) |> dimPoints }
  return { return pairs(between: $0).map(dimStyle) }
}
public func dimRight(_ d: CGFloat, formatter: @escaping DimFormat) -> ([CGPoint]) -> [Label]
{
  let dimStyle = { ($0, (unitX * d), formatter) |> dimPoints } >>> swapRotation
  return { return pairs(between: $0).map(dimStyle) }
}

public func dimBottom(_ d: CGFloat, formatter: @escaping DimFormat) -> ([CGPoint]) -> [Label]
{
  let dimStyle = { ($0, (unitY * -d), formatter) |> dimPoints }
  return { return pairs(between: $0).map(dimStyle) }
}
public func dimLeft(_ d: CGFloat, formatter: @escaping DimFormat) -> ([CGPoint]) -> [Label]
{
  let dimStyle = { ($0, (unitX * -d), formatter) |> dimPoints } >>> swapRotation
  return { return pairs(between: $0).map(dimStyle) }
}
public func dimMLeft(_ d: CGFloat, formatter: @escaping DimFormat) -> ([CGPoint]) -> [Label]
{
  let dimStyle = { ($0, (unitX * -d), formatter) |> dimPoints } >>> swapRotation
  return { return pairs(between: $0).map(dimStyle) }
}





