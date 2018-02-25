//
//  GrasshopperFunctions.swift
//  GrasshopperRound2
//
//  Created by Justin Smith on 1/7/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation

//: A SpriteKit based Playground


import CoreGraphics
import UIKit


enum Orthogonal {
  case horizontal
  case vertical
}

protocol Geometry {
  var position : CGPoint { get set }
}

struct Label : Geometry {
  enum Rotation { case h, v }
  var text : String
  var position : CGPoint = CGPoint.zero
  var rotation : Rotation = .h
}
extension Label {
  init(text: String) { self.text = text }
}

struct Oval : Geometry {
  var ellipseOf: CGSize
  var lineWidth = 1.0
  var fillColor : UIColor = .blue
  var position : CGPoint = CGPoint.zero
  init(ellipseOf: CGSize) { self.ellipseOf = ellipseOf }
}

struct Line : Geometry {
  var start: CGPoint
  var end: CGPoint
  var position : CGPoint {
    set {
      let x = newValue.x - self.position.x
      let y = newValue.y - self.position.y
      
      start.x = start.x + x
      start.y = start.y + y
      end.x = end.x + x
      end.y = end.y + y
      
    }
    get {
      return CGPoint(x: (start.x + end.x)/2, y: (start.y + end.y)/2)
    }
  }
  init(start: Geometry, end:Geometry) { self.start = start.position; self.end = end.position}
}

struct StrokedLine : Geometry {
  var line : Line
  var position: CGPoint { get { return line.position } set { line.position = newValue }}
}



struct TextureLine : Geometry {
  var label : String
  var line : Line
  var position: CGPoint { get { return line.position } set { line.position = newValue }}
}
extension TextureLine{
  init( start: Geometry, end: Geometry)
  {
    self.label = ""
    self.line = Line(start: start, end: end)
  }
  init( label: String, start: Geometry, end: Geometry)
  {
    self.label = label
    self.line = Line(start: start, end: end)
  }
}

struct LabeledPoint : Geometry {
  var position : CGPoint
  var label : String
}



extension Line {
  var unitLine : Line { return Line(start: CGPoint(x:0,y:0), end: CGPoint(x:self.end.x - self.start.x,y: self.end.y - self.start.y))
  }
}



// Extensions
extension CGPoint : Geometry{
  var position: CGPoint {
    get { return self }
    set { self = newValue}
    
  }
}


// Grid
struct EdgeCollection{
  
  var all : [Line] {  get { return verticals + horizontals} }
  let verticals : [Line]
  let horizontals : [Line]
}

struct PointCollection : BorderPoints{
  let all : [CGPoint]
  var boundaries : [CGPoint] { get { return top + right + bottom + left} }
  // sections
  let top : [CGPoint]
  let right : [CGPoint]
  let bottom : [CGPoint]
  let left : [CGPoint]
}





struct LongestList<A,B>
{
  var list1 : Array<A>
  var list2 : Array<B>
  
  init(_ l1: Array<A>, _ l2: Array<B>)
  {
    list1 = l1; list2 = l2
  }
  
  func map<T>(_ transform: ((A, B)) throws -> T) rethrows -> [T]
  {
    let longestIs1 = list1.count > list2.count
    
    if longestIs1 {
      let newList = list2 + Array(repeatElement(list2.last!, count: list1.count - list2.count))
      let zipped = zip(list1, newList)
      return zipped.map{ try! transform($0) }
    }
    else {
      let newList = list1 + Array(repeatElement(list1.last!, count: list2.count - list1.count))
      let zipped = zip(newList, list2)
      return zipped.map{ try! transform($0) }
    }
    
  }
}

struct EveryList<A,B>
{
  var list1 : Array<A>
  var list2 : Array<B>
  
  init(_ l1: Array<A>, _ l2: Array<B>)
  {
    list1 = l1; list2 = l2
  }
  
  func map<T>(_ transform: ((A, B)) throws -> T) rethrows -> [T]
  {
    var a : [T] = []
    for l in list1 {
      
      let c = try! LongestList( [l], list2).map(transform)
      a.append(contentsOf: c)
    }
    return a
  }
}

extension Array
{
  mutating func moveFirstToLast() -> ()
  {
    let first = dropFirst()
    self = self + first
  }
}

// Helper
let unitX = CGVector(dx: 1, dy: 0)
let unitY = CGVector(dx: 0, dy: 1)

let redCirc = { pointToCircle2($0, #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1))}
let blueCirc = { pointToCircle2($0, #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.5504655855, alpha: 1))}

// Canvas
func helperJoin(_ l: Label, _ s: CGFloat) -> Label {
  var l = l
  l.text = String(format: "%.1f", s)
  return l
}

func swapRotation(_ label: Label) -> Label {
  var label = label
  label.rotation = (label.rotation == .h) ? .v : .h
  return label
}



enum BorderCase { case top, left, right, bottom}

func offsetPoints( points: [CGPoint], offset d: CGVector) -> [Geometry]
{
  let a =  LongestList(points, [d] ).map(move)
  return a
}



func getHandlePoints(points: BorderPoints, offset d: CGFloat)->[[Oval]]
{
  // convert outside points to handle points
  let t = LongestList(points.top, [unitY * d]).map(moveByVector).map(redCirc)
  let l = LongestList(points.left, [unitX * d]).map(moveByVector).map(redCirc)
  let b = LongestList(points.bottom, [unitY * -d]).map(moveByVector).map(redCirc)
  let r = LongestList(points.right, [unitX * -d]).map(moveByVector).map(redCirc)
  let gridHandlePoints = [t , l , b , r]
  return gridHandlePoints
}



//Fixme functionassumesimp implementation
func dimPoints<T: Geometry>(points:[[T]], offset d: CGFloat) -> [Label]
{
  // convert handle points to dim points
  // convert handle points to dim points
  let off : CGFloat = 2/3
  let topM = centers(between: points[0]).map(moveByVector).map{ $0(unitY * (-off * d)) }.map(pointToLabel) // Fixme repeats below
  let leftM = centers(between: points[1]).map(moveByVector).map{ $0(unitX * (-d * off)) }.map(pointToLabel).map(swapRotation)
  let bottomM = centers(between: points[2]).map(moveByVector).map{ $0(unitY * (d*off)) }.map(pointToLabel)
  let rightM = centers(between: points[3]).map(moveByVector).map{ $0(unitX * (d*off)) }.map(pointToLabel).map(swapRotation)
  
  let mids : [Label] =
    zip(topM, widths(between: points[0])).map(helperJoin) +
      zip(leftM, widths(between: points[1])).map(helperJoin) +
      zip(bottomM, widths(between: points[2])).map(helperJoin) +
      zip(rightM, widths(between:points[3])).map(helperJoin)
  
  return mids

}




func dimPoints2<T: Geometry>(points: [[T]], offset d: CGFloat) -> [Label]
{
  // convert handle points to dim points
  // convert handle points to dim points
  let topM = centers(between: points[0]).map(moveByVector).map{ $0(unitY * d) }.map(pointToLabel) // Fixme repeats below
  let rightM = centers(between: points[1]).map(moveByVector).map{ $0(unitX * d) }.map(pointToLabel).map(swapRotation)
  let bottomM = centers(between: points[2]).map(moveByVector).map{ $0(unitY * -d) }.map(pointToLabel)
  let leftM = centers(between: points[3]).map(moveByVector).map{ $0(unitX * -d) }.map(pointToLabel).map(swapRotation)

  
  let mids : [Label] =
    zip(topM, widths(between: points[0])).map(helperJoin) +
      zip(rightM, widths(between: points[1])).map(helperJoin) +
      zip(bottomM, widths(between: points[2])).map(helperJoin) +
      zip(leftM, widths(between:points[3])).map(helperJoin)
  
  return mids
  
}

func dimPoints( points: (CGPoint, CGPoint), direction: CGVector, transform: ((Label)-> Label)? )-> Label
{
  let d = points |> distanceBetween
  let c = points |> center
  let o = (c, direction) |> move
  let l = o.position |> pointToLabel
  let l2 = (l, d) |> helperJoin
  let r = l2 |> (transform ?? { return $0})
  return r
}

func dimTop(_ d: CGFloat) -> ([CGPoint]) -> [Label]
{
  let dimStyle = { ($0, (unitY * d), nil ) |> dimPoints }
  return { return pairs(between: $0).map(dimStyle) }
}
func dimRight(_ d: CGFloat) -> ([CGPoint]) -> [Label]
{
  let dimStyle = { ($0, (unitX * d), swapRotation ) |> dimPoints }
  return { return pairs(between: $0).map(dimStyle) }
}

func dimBottom(_ d: CGFloat) -> ([CGPoint]) -> [Label]
{
  let dimStyle = { ($0, (unitY * -d), nil ) |> dimPoints }
  return { return pairs(between: $0).map(dimStyle) }
}
func dimLeft(_ d: CGFloat) -> ([CGPoint]) -> [Label]
{
  let dimStyle = { ($0, (unitX * -d), swapRotation ) |> dimPoints }
  return { return pairs(between: $0).map(dimStyle) }
}

func dimension(_ d: CGFloat) -> (BorderPointsImp) -> [Label]
{
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

func dimPoints3(points: BorderPoints, offset d: CGFloat) -> [Label]
{
  // convert handle points to dim points
  // convert handle points to dim points
  
  
  let mids : [Label] =
  points.top |> dimTop(d) +
  points.right |> dimRight(d) +
  points.bottom |> dimBottom(d) +
  points.left |> dimLeft(d)
  
  
  return mids
  
}





