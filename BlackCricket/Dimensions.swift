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
let _dimOffset : CGFloat = -20.0

// NonuniformModel2D -> [Label]
public func dimensionsImperial(m: NonuniformModel2D) -> [Label] {
  return dimPointsG(points: (m |> nonuniformToPoints) |> counterClockwise,
                    offset: _dimOffset,
                    formatter: (centimeters >>> imperialFormatter) )
}

// NonuniformModel2D -> [Label]
public func dimensionsMetric(m: NonuniformModel2D) -> [Label] {
  return dimPointsG(points: (m |> nonuniformToPoints) |> counterClockwise, offset: _dimOffset, formatter: { "\($0)" } )
}

// PointCollection -> [Label]
public func pointCollectionToDimLabel(points: PointCollection)-> [Label] {
  return dimPointsG(points: points |> counterClockwise, offset: _dimOffset, formatter: (centimeters >>> imperialFormatter))
}

// PointCollection -> [[CGPoint]]
func counterClockwise(points: PointCollection) -> [[CGPoint]] {
  return [points.top, points.left, points.bottom, points.right]
}


//Fixme functionassumesimp implementation
/// [[Geometry]], Offset, Formatter -> [Label]
/// points : ordered counterclockwise
func dimPointsG<T: Geometry>(points:[[T]], offset d: CGFloat, formatter: DimFormat) -> [Label]{
  // convert handle points to dim points
  // convert handle points to dim points
  let off : CGFloat = 2/3
  let topM = centers(between: points[0]).map(moveByVectorCurried).map{ $0(unitY * (-off * d)) }.map(pointToLabel) // Fixme repeats below
  let leftM = centers(between: points[1]).map(moveByVectorCurried).map{ $0(unitX * (-d * off)) }.map(pointToLabel >>> swapRotation)
  let bottomM = centers(between: points[2]).map(moveByVectorCurried).map{ $0(unitY * (d*off)) }.map(pointToLabel)
  let rightM = centers(between: points[3]).map(moveByVectorCurried).map{ $0(unitX * (d*off)) }.map(pointToLabel >>> swapRotation)
  
  let topStrings =  widths(between: points[0]).map(formatter)
  let leftStrings =  widths(between: points[1]).map(formatter)
  let bottomStrings =  widths(between: points[2]).map(formatter)
  let rightStrings =  widths(between: points[3]).map(formatter)
  
  let mids : [Label] =
    zip(topM, topStrings).map(setLabel) +
      zip(leftM, leftStrings).map(setLabel) +
      zip(bottomM, bottomStrings).map(setLabel) +
      zip(rightM, rightStrings).map(setLabel)
  
  return mids
  
}



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





