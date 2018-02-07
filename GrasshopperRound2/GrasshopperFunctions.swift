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
  let strokeWidth : CGFloat
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
    print(label)
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


// Extensions
extension CGPoint : Geometry{
  var position: CGPoint {
    get { return self }
    set { self = newValue}
    
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


// Grid
struct EdgeCollection{
  
  var all : [Line] {  get { return verticals + horizontals} }
  let verticals : [Line]
  let horizontals : [Line]
}

struct PointCollection{
  let all : [CGPoint]
  var boundaries : [CGPoint] { get { return top + right + bottom + left} }
  // sections
  let top : [CGPoint]
  let right : [CGPoint]
  let bottom : [CGPoint]
  let left : [CGPoint]
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
let unitY = CGVector(dx: 0, dy: -1)

let redCirc = { pointToCircle2($0, #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1))}
let blueCirc = { pointToCircle2($0, #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.5504655855, alpha: 1))}

// Canvas
func helperJoin(_ l: Label, _ s: CGFloat) -> Label {
  var l = l
  l.text = String(describing: s)
  return l
}

func swapRotation(_ label: Label) -> Label {
  var label = label
  label.rotation = (label.rotation == .h) ? .v : .h
  return label
}








func getHandlePoints(points: PointCollection, offset d: CGFloat)->[[Oval]]
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




// SPRITE KIT>>>



// _spriteKit

/// CALayer
import CoreGraphics

protocol Renderer {
  func r_move(to point: CGPoint)
  func r_addLine(to point: CGPoint)
}
protocol Drawable {
  func render(in context: Renderer)
}
struct Diagram : Drawable {
  var drawables: [Drawable]
  func render(in context: Renderer) {
    for d in drawables
    {
      d.render(in: context)
    }
  }
}
extension Drawable {
  var cgPath : CGPath {
    let cg = CGMutablePath()
    self.render(in: cg)
    return cg
  }
}


extension Oval : Drawable {
  func render(in context: Renderer)
  {
    context.r_move(to: self.position)
    context.r_addLine(to: moveByVector( initialNode: self.position, vector: unitY * (ellipseOf.height/2) ))
    context.r_move(to: self.position)
    context.r_addLine(to: moveByVector( initialNode: self.position, vector: unitY * (-ellipseOf.height/2) ))
    context.r_move(to: self.position)
    context.r_addLine(to: moveByVector( initialNode: self.position, vector: unitX * (-ellipseOf.width/2) ))
    context.r_move(to: self.position)
    context.r_addLine(to: moveByVector( initialNode: self.position, vector: unitX * (ellipseOf.width/2) ))
  }
}
extension Line : Drawable {
  func render(in context: Renderer)
  {
    context.r_move(to: start)
    context.r_addLine(to: end)
  }
}

extension CGMutablePath : Renderer {
  func r_move(to point: CGPoint)
  {
    self.move(to: point)
  }
  func r_addLine(to point: CGPoint)
  {
    self.addLine(to: point)
  }
}
