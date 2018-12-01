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
import Singalong
import Geo

enum Orthogonal {
  case horizontal
  case vertical
}

public protocol Geometry {
  var position : CGPoint { get set }
}

public struct Label : Geometry {
  public enum Rotation { case h, v }
  public var text : String
  public var position : CGPoint = CGPoint.zero
  public var rotation : Rotation = .h
  
  public init(text: String, position: CGPoint, rotation: Rotation) {
    (self.text, self.position, self.rotation) = (text, position, rotation)
  }
}
extension Label {
  public init(text: String) { self.text = text }
}

struct ColoredLabel : Geometry {
  var text : String
  var position : CGPoint = CGPoint.zero
  var color : UIColor
}
extension ColoredLabel { var asLabel : Label { return Label(text: text, position: position, rotation: .h)}}

struct Oval : Geometry {
  var ellipseOf: CGSize
  var lineWidth = 1.0
  var fillColor : UIColor = .blue
  var position : CGPoint = CGPoint.zero
  init(ellipseOf: CGSize) { self.ellipseOf = ellipseOf }
}

public struct Line : Geometry {
  var start: CGPoint
  var end: CGPoint
  public var position : CGPoint {
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
  public init(start: Geometry, end:Geometry) { self.start = start.position; self.end = end.position}
}
extension Line {
  init( p1:(CGFloat,CGFloat),
        p2:(CGFloat,CGFloat)) {
    start = p1 |> CGPoint.init(x:y:);
  end = p2 |> CGPoint.init(x:y:)}
  
  init( p1:CGPoint,
        p2:CGPoint) {
    start = p1
    end = p2
  }
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
  public var position: CGPoint {
    get { return self }
    set { self = newValue}
    
  }
}

extension CGRect : Geometry {
  public var position : CGPoint {
    get {
      return origin
    }
    set {
      self.origin = newValue
    }
  }
}



// Grid
struct EdgeCollection{
  
  var all : [Line] {  get { return verticals + horizontals} }
  let verticals : [Line]
  let horizontals : [Line]
}

public struct PointCollection : BorderPoints{
  let all : [CGPoint]
  var boundaries : [CGPoint] { get { return top + right + bottom + left} }
  // sections
  let top : [CGPoint]
  let right : [CGPoint]
  let bottom : [CGPoint]
  let left : [CGPoint]
}

import Geo
public func nonuniformToPoints(numodel: NonuniformModel2D) -> PointCollection{
  let ltr = numodel.orderedPointsLeftToRight
  let utd = numodel.orderedPointsUpToDown
  
  return PointCollection(
    all: ltr.flatMap{ $0 },
    top: utd.last!,
    right: ltr[0],
    bottom: utd[0],
    left: ltr.last!
  )
}



func edges(numodel: NonuniformModel2D) -> EdgeCollection{
  
  let linesUp = numodel.orderedPointsLeftToRight.map{ Line(start: $0.first!, end: $0.last!) }
  let linesAcross = numodel.orderedPointsUpToDown.map{ Line(start: $0.first!, end: $0.last!) }
  
  return EdgeCollection(verticals:linesUp, horizontals:linesAcross)
}

extension NonuniformModel2D {
  
  var edgesAndPoints : (edges: EdgeCollection, points: PointCollection)
  {
    get {
      return ( self |> edges, self |> nonuniformToPoints)
    }
  }
  
  
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
func setLabel(_ l: Label, _ s: CGFloat) -> Label {
  var l = l
  l.text = String(format: "%.1f", s)
  return l
}

func setLabel(_ l: Label, _ s: String) -> Label {
  var l = l
  l.text = s
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
  let topM = centers(between: points[0]).map(moveByVectorCurried).map{ $0(unitY * (-off * d)) }.map(pointToLabel) // Fixme repeats below
  let leftM = centers(between: points[1]).map(moveByVectorCurried).map{ $0(unitX * (-d * off)) }.map(pointToLabel).map(swapRotation)
  let bottomM = centers(between: points[2]).map(moveByVectorCurried).map{ $0(unitY * (d*off)) }.map(pointToLabel)
  let rightM = centers(between: points[3]).map(moveByVectorCurried).map{ $0(unitX * (d*off)) }.map(pointToLabel).map(swapRotation)
  
  let topStrings =  widths(between: points[0]).map(centimeters >>> imperialFormatter)
  let leftStrings =  widths(between: points[1]).map(centimeters >>> imperialFormatter)
  let bottomStrings =  widths(between: points[2]).map(centimeters >>> imperialFormatter)
  let rightStrings =  widths(between: points[3]).map(centimeters >>> imperialFormatter)
  
  let mids : [Label] =
    zip(topM, topStrings).map(setLabel) +
      zip(leftM, leftStrings).map(setLabel) +
      zip(bottomM, bottomStrings).map(setLabel) +
      zip(rightM, rightStrings).map(setLabel)
  
  return mids

}

func centimeters(from cent: CGFloat)->Measurement<UnitLength> {
  return Measurement(value: Double(cent), unit: .centimeters)
}



func dimPoints2<T: Geometry>(points: [[T]], offset d: CGFloat) -> [Label]
{
  // convert handle points to dim points
  // convert handle points to dim points
  let topM = centers(between: points[0]).map(moveByVectorCurried).map{ $0(unitY * d) }.map(pointToLabel) // Fixme repeats below
  let rightM = centers(between: points[1]).map(moveByVectorCurried).map{ $0(unitX * d) }.map(pointToLabel).map(swapRotation)
  let bottomM = centers(between: points[2]).map(moveByVectorCurried).map{ $0(unitY * -d) }.map(pointToLabel)
  let leftM = centers(between: points[3]).map(moveByVectorCurried).map{ $0(unitX * -d) }.map(pointToLabel).map(swapRotation)

  
  let mids : [Label] =
    zip(topM, widths(between: points[0])).map(setLabel) +
      zip(rightM, widths(between: points[1])).map(setLabel) +
      zip(bottomM, widths(between: points[2])).map(setLabel) +
      zip(leftM, widths(between:points[3])).map(setLabel)
  
  return mids
  
}

func dimPoints( points: (CGPoint, CGPoint), direction: CGVector, transform: ((Label)-> Label)? )-> Label
{
  let d = points |> distanceBetween
  let c = points |> center
  let o = (c, direction) |> move
  let l = o.position |> pointToLabel
  let l2 = (l, d) |> setLabel
  let r = l2 |> (transform ?? { return $0})
  return r
}

public func dimTop(_ d: CGFloat) -> ([CGPoint]) -> [Label]
{
  let dimStyle = { ($0, (unitY * d), nil ) |> dimPoints }
  return { return pairs(between: $0).map(dimStyle) }
}
public func dimRight(_ d: CGFloat) -> ([CGPoint]) -> [Label]
{
  let dimStyle = { ($0, (unitX * d), swapRotation ) |> dimPoints }
  return { return pairs(between: $0).map(dimStyle) }
}

public func dimBottom(_ d: CGFloat) -> ([CGPoint]) -> [Label]
{
  let dimStyle = { ($0, (unitY * -d), nil ) |> dimPoints }
  return { return pairs(between: $0).map(dimStyle) }
}
public func dimLeft(_ d: CGFloat) -> ([CGPoint]) -> [Label]
{
  let dimStyle = { ($0, (unitX * -d), swapRotation ) |> dimPoints }
  return { return pairs(between: $0).map(dimStyle) }
}
public func dimMLeft(_ d: CGFloat) -> ([CGPoint]) -> [Label]
{
  let dimStyle = { ($0, (unitX * -d), swapRotation ) |> dimPoints }
  return { return pairs(between: $0).map(dimStyle) }
}

public func dimension(_ d: CGFloat) -> (BorderPointsImp) -> [Label]
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





