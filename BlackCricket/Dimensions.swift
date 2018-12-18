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


typealias DimFormat = (CGFloat) -> String

// NonuniformModel2D -> [Label]
public func dimensionsImperial(m: NonuniformModel2D) -> [Label] {
  return dimPointsG(points: (m |> nonuniformToPoints) |> counterClockwise,
                    offset: -40,
                    formatted: (centimeters >>> imperialFormatter) )
}

// NonuniformModel2D -> [Label]
public func dimensionsMetric(m: NonuniformModel2D) -> [Label] {
  return dimPointsG(points: (m |> nonuniformToPoints) |> counterClockwise, offset: -40, formatted: { "\($0)" } )
}

// PointCollection, offset -> [Label]
public func pointCollectionToDimLabel(points: PointCollection, offset: CGFloat)-> [Label] {
  return dimPointsG(points: points |> counterClockwise, offset: offset, formatted: (centimeters >>> imperialFormatter))
}

func counterClockwise(points: PointCollection) -> [[CGPoint]] {
  return [points.top, points.left, points.bottom, points.right]
}


func centimeters(from cent: CGFloat)->Measurement<UnitLength> {
  return Measurement(value: Double(cent), unit: .centimeters)
}



func pointsToDimLabel(leftToRight: [[CGPoint]], offset: CGFloat)-> [Label] {
  
  let points = leftToRight |> leftToRightToBorders
  
  let ghp = getHandleOvals(points: points, offset: offset)
  let mids = dimPointsG(points: ghp, offset: 40, formatted: (centimeters >>> imperialFormatter))
  return mids
}


//Fixme functionassumesimp implementation
func dimPointsG<T: Geometry>(points:[[T]], offset d: CGFloat, formatted: DimFormat) -> [Label]{
  // convert handle points to dim points
  // convert handle points to dim points
  let off : CGFloat = 2/3
  let topM = centers(between: points[0]).map(moveByVectorCurried).map{ $0(unitY * (-off * d)) }.map(pointToLabel) // Fixme repeats below
  let leftM = centers(between: points[1]).map(moveByVectorCurried).map{ $0(unitX * (-d * off)) }.map(pointToLabel >>> swapRotation)
  let bottomM = centers(between: points[2]).map(moveByVectorCurried).map{ $0(unitY * (d*off)) }.map(pointToLabel)
  let rightM = centers(between: points[3]).map(moveByVectorCurried).map{ $0(unitX * (d*off)) }.map(pointToLabel >>> swapRotation)
  
  let topStrings =  widths(between: points[0]).map(formatted)
  let leftStrings =  widths(between: points[1]).map(formatted)
  let bottomStrings =  widths(between: points[2]).map(formatted)
  let rightStrings =  widths(between: points[3]).map(formatted)
  
  let mids : [Label] =
    zip(topM, topStrings).map(setLabel) +
      zip(leftM, leftStrings).map(setLabel) +
      zip(bottomM, bottomStrings).map(setLabel) +
      zip(rightM, rightStrings).map(setLabel)
  
  return mids
  
}




func dimPoints( points: (CGPoint, CGPoint), direction: CGVector )-> Label {
  let d = points |> distanceBetween
  let c = points |> center
  let o = (c, direction) |> move
  let l = o.position |> pointToLabel
  let l2 = (l, d) |> setLabel
  return l2
}


public func dimension(_ d: CGFloat) -> (BorderPointsImp) -> [Label] {
  // convert handle points to dim points
  // convert handle points to dim points
  
  return { points in
    let mids : [Label] =
      points.top |> dimTop(d) +
        points.right |> dimRight(d) +
        points.bottom |> dimBottom(d) +
        points.left |> dimLeft(d)
    return mids
  }
}

public func dimTop(_ d: CGFloat) -> ([CGPoint]) -> [Label] {
  let dimStyle = { ($0, (unitY * d)) |> dimPoints }
  return { return pairs(between: $0).map(dimStyle) }
}
public func dimRight(_ d: CGFloat) -> ([CGPoint]) -> [Label]
{
  let dimStyle = { ($0, (unitX * d) ) |> dimPoints } >>> swapRotation
  return { return pairs(between: $0).map(dimStyle) }
}

public func dimBottom(_ d: CGFloat) -> ([CGPoint]) -> [Label]
{
  let dimStyle = { ($0, (unitY * -d) ) |> dimPoints }
  return { return pairs(between: $0).map(dimStyle) }
}
public func dimLeft(_ d: CGFloat) -> ([CGPoint]) -> [Label]
{
  let dimStyle = { ($0, (unitX * -d) ) |> dimPoints } >>> swapRotation
  return { return pairs(between: $0).map(dimStyle) }
}
public func dimMLeft(_ d: CGFloat) -> ([CGPoint]) -> [Label]
{
  let dimStyle = { ($0, (unitX * -d) ) |> dimPoints } >>> swapRotation
  return { return pairs(between: $0).map(dimStyle) }
}

