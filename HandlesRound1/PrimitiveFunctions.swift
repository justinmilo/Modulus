//
//  PrimitiveFunctions.swift
//  HandlesRound1
//
//  Created by Justin Smith on 2/18/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import CoreGraphics
import UIKit


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

func move(item:Geometry, vector: CGVector)->Geometry
{
  var item = item
  item.position = item.position + vector
  return item
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

func moveByVector<T: Geometry> (initialNode: T, vector: CGVector) -> T
{ return moveByVector2(initialNode, vector).0 }

func moveByVector<T: Geometry> (initialNode: T) -> (CGVector) -> T
{
  return { moveByVector(initialNode: initialNode, vector: $0) }
}

// POINT_LIST
func listPoint (i:Int, c:Geometry)-> Geometry
{
  var number = Label(text: "\(i)")
  number.position = c.position
  return moveByVector2(number, CGVector(dx: 25, dy: 0) ).0
}

// Centers
func centers<T:Geometry>(between array: [T]) -> [CGPoint]
{
  let zipe = zip(array, array.dropFirst())
  return zipe.map(centerBetweenTwoPoints)
}
func centerBetweenTwoPoints<T: Geometry>(_ first: T, _ second: T) -> CGPoint
{
  return divideLine(line: Line(start: first, end: second), segments: 2).first!
}


func widths<T:Geometry>(between positions: [T]) -> [CGFloat]
{
  let zipe = zip(positions, positions.dropFirst())
  return zipe.map
    { points in
      // pythag theorim
      let dif = sqrt( powf(Float(points.0.position.x - points.1.position.x), 2) + powf(Float(points.0.position.y - points.1.position.y), 2))
      
      return CGFloat(dif)
  }
}
func distance<T:Geometry>(between positions: [T]) -> [CGFloat]
{
  let widthsA = widths(between: positions)
  
  return widthsA.reduce([]) { (res, fl) -> [CGFloat] in
    let sum : CGFloat = res.reduce(0.0) { return $0 + $1 }
    return res + [ sum + fl ]
  }
}
