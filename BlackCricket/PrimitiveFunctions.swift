//
//  PrimitiveFunctions.swift
//  HandlesRound1
//
//  Created by Justin Smith on 2/18/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import CoreGraphics
import UIKit
import Singalong
import Geo

func divideLine(line: Line, segments: Int)->([CGPoint])
{
  let unitLine = line.unitLine
  
  return (1...segments).map {
    let ratio = CGFloat($0)/CGFloat(segments)
    let x = ratio * unitLine.end.x
    let y = ratio * unitLine.end.y
    return CGPoint(x: line.start.x + x, y: line.start.y + y)
  }
}
func vectorToPoint(_ vector: CGVector)-> CGPoint
{
  return CGPoint(x: vector.dx, y: vector.dy)
}

// POINT TO GEOMETRY
func pointToCircle2(_ point: CGPoint, _ color: UIColor)-> Oval
{
  let size = CGSize(width: 20, height: 20)
  var circle = Oval(ellipseOf: size)
  circle.lineWidth = 0.0
  circle.fillColor = color
  circle.position = point
  return circle
}
func pointToCircle(_ point: CGPoint)-> Oval { return pointToCircle2(point, .green) }

func pointToLabel(_ point: CGPoint)->Label
{
  var l = Label(text: "")
  l.position = point
  return l
}


let pointStringToLabel : (CGPoint, String) -> Label = { Label.init(text: $1, position: $0, rotation: .h) }


public func move(point: CGPoint, vector: CGVector)->CGPoint {
  return point + vector
}

public let vectorMove = flip(curry(move(point:vector:)))

public func yMove(by float: CGFloat)->(CGPoint)->CGPoint {
  return { $0  + unitY * float }
}
public func xMove(by float: CGFloat)->(CGPoint)->CGPoint {
  return { $0 + unitX * float }
}


func move(item:Geometry, vector: CGVector)->Geometry
{
  var items = item
  items.position = item.position + vector
  return items
}

func moveGroup(items:[Geometry], vector: CGVector)-> [Geometry]
{
  let a = items.map{ ($0, vector) |> move}
  return a
}
// MOVE
func moveByVector2<T : Geometry >(_ initialNode: T, _ vector:CGVector) -> (T, CGVector)
{
  var newNode = initialNode
  newNode.position = CGPoint(x: initialNode.position.x + vector.dx , y: initialNode.position.y + vector.dy)
  return (newNode, vector)
}

public func moveByVector<T: Geometry> (initialNode: T, vector: CGVector) -> T {
  return moveByVector2(initialNode, vector).0
}

func moveByVectorCurried<T: Geometry> (initialNode: T) -> (CGVector) -> T {
  return { moveByVector(initialNode: initialNode, vector: $0) }
}

func move<T: Geometry> (by vector: CGVector) -> (T) -> T {
  return { moveByVector(initialNode: $0, vector: vector) }
}
func moveGeneric<T: Geometry> (by vector: CGVector) -> (T) -> T {
  return { moveByVector(initialNode: $0, vector: vector) }
}

func move(by vectorP: CGVector) -> (Geometry) -> Geometry
{
  return { move(item: $0, vector: vectorP) }
}



// POINT_LIST
func listPoint (i:Int, c:Geometry)-> Geometry
{
  var number = Label(text: "\(i)")
  number.position = c.position
  return moveByVector2(number, CGVector(dx: 25, dy: 0) ).0
}

// Centers
func center(between points: (CGPoint, CGPoint)) -> CGPoint
{
  return divideLine(line: Line(start: points.0, end: points.1), segments: 2).first!
}
func pairs(between array: [CGPoint]) -> [(CGPoint, CGPoint)]
{
  return Array( zip(array, array.dropFirst()) )
}
func centers<T:Geometry>(between array: [T]) -> [CGPoint]
{
  let zipe = zip(array, array.dropFirst())
  return zipe.map(centerBetweenTwoPoints)
}
func centerBetweenTwoPoints<T: Geometry>(_ first: T, _ second: T) -> CGPoint
{
  return divideLine(line: Line(start: first, end: second), segments: 2).first!
}
let  distanceBetween : (CGPoint,CGPoint) -> CGFloat =
{
  p1, p2 in
  // pythag theorim
  let dif = sqrt( powf(Float(p1.x - p2.x), 2) + powf(Float(p1.y - p2.y), 2))
  
  return CGFloat(dif)
}

let  distance : (Geometry,Geometry) -> CGFloat =
{
  p1, p2 in
  // pythag theorim
  let dif = (p1.position, p2.position) |> distanceBetween
  
  return CGFloat(dif)
}

func widths<T:Geometry>(between positions: [T]) -> [CGFloat]
{
   return zip(positions, positions.dropFirst()).map(distance)
}
func distance<T:Geometry>(between positions: [T]) -> [CGFloat]
{
  let widthsA = widths(between: positions)
  
  return widthsA.reduce([]) { (res, fl) -> [CGFloat] in
    let sum : CGFloat = res.reduce(0.0) { return $0 + $1 }
    return res + [ sum + fl ]
  }
}


func gridWithOptions(p: CGPoint, dx: CGFloat, dy: CGFloat, ex: Int, ey: Int) -> (edges: EdgeCollection, points: PointCollection)
{
  let points = (0...ex).map{ x in
    (0...ey).map { y in
      return CGPoint(x: p.x + CGFloat(x) * dx, y: p.y + CGFloat(y) * dy)
    }
  }
  
  let pointsOtherWay = (0...ey).map{ y in
    (0...ex).map { x in
      return CGPoint(x: p.x + CGFloat(x) * dx, y: p.y + CGFloat(y) * dy)
    }
  }
  
  let linesUp = points.map{ Line(start: $0.first!, end: $0.last!) }
  let linesAcross = pointsOtherWay.map{ Line(start: $0.first!, end: $0.last!) }
  
  return (edges: EdgeCollection(verticals:linesUp, horizontals:linesAcross), points: PointCollection(
    all: points.flatMap{ $0 },
    top: pointsOtherWay.last!,
    right: points[0],
    bottom: pointsOtherWay[0],
    left: points.last!
  ))
}


// Grid
func grid(p: CGPoint, dx: CGFloat, dy: CGFloat, ex: Int, ey: Int)
  -> (edges: [Line], points: [CGPoint], topPoints: [CGPoint],
  rightPoints: [CGPoint],
  bottomPoints: [CGPoint],
  leftPoints: [CGPoint])
{
  let options = gridWithOptions(p: p, dx: dx, dy: dy, ex: ex, ey: ey)
  return (edges: options.edges.horizontals + options.edges.verticals ,
          points: options.points.all ,
          topPoints: options.points.top ,
          leftPoints: options.points.left ,
          bottomPoints: options.points.bottom ,
          rightPoints: options.points.right)
  
}

/// Create seom DEBUG Diagnostics ,,,,,,,,,
/// DEBUG
// rect -> corner and center points -> doubled labels
//                                  -> doubled Strings
// rect -> points
let debugRect : (CGRect)->() = {
  newRect in

let pointsToConsider = corners <> { [$0.center] }
let points = newRect |> pointsToConsider

//                                 p -> (p, p)
let doubledPoints : (CGPoint) -> (CGPoint, CGPoint) =
{
  ( $0 |> move(by: unitY * 10),
    $0 |> move(by: unitY * -10))
}
  
//  let p
//
//let doubleStrings : (CGPoint) -> (String, String) =
//{ p in
//  (p |> uiToSprite >>> { "\($0)sk" },
//   p |> { "\($0)ui" }  )
//}
//let doubleLabelMaker : ([CGPoint]) -> [(Label, Label)] = translateToCGPointInSKCoordinates(from: handleView.frame, to: twoDView.frame)
//  >>> doubledPoints
//  >>> { ($0.0 |> pointToLabel, $0.1 |> pointToLabel) } |> map
//let labelTexts = (doubleStrings |> map)
//let changeText = prop(\Label.text)
//let addStringToLabel = { lab, str in lab |> changeText{_ in str} }
//let texts : ([CGPoint]) -> [Label] = { zip($0 |> doubleLabelMaker,
//                                           $0 |> labelTexts).flatMap{
//                                            return [addStringToLabel($0.0.0, $0.1.0) , addStringToLabel($0.0.1, $0.1.1)]
//  }
//}
//let compacted = points |> texts
//let centerPoint = [newRect.bottomLeft, viewOrigin] |> texts

/// ............ Create seom DEBUG Diagnostics
/// DEBUG
}

