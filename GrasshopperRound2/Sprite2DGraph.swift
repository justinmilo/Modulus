//
//  GameViewController.swift
//  GrasshopperRound2
//
//  Created by Justin Smith on 1/7/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

struct Model2D {
  var origin: CGPoint
  var dx: CGFloat
  var dy: CGFloat
  var col: Int
  var rows: Int
}


class Sprite2DGraph : SKView {
  
  var geometries : [[[Geometry]]] = []
  var index: Int = 0
  
  var model : Model2D! {
    didSet {
      // offset distance
      let d : CGFloat = 40.0
      
      let width : CGFloat = 240, height : CGFloat = 300
      let rows = 3, col = 4
      let origin = CGPoint( -width/2, -height/2)
      
      // First Geometry Set...
      // Grid
      let gridTup = gridWithOptions(p: model.origin, dx: model.dx, dy: model.dy, ex: col, ey: rows)
      let rectangles = (gridTup.edges.horizontals + gridTup.edges.verticals).map{ StrokedLine.init( line: $0, strokeWidth: 3.0) }
      
      // Handle Points
      let gridHandlePoints = getHandlePoints(points: gridTup.points, offset: d)
      let handleLines = zip(gridTup.points.boundaries, gridHandlePoints.flatMap{$0}).map(Line.init)
      
      // Mid Points
      let mids = dimPoints(points: gridHandlePoints, offset: 40)
      
      // put in on screen when gameScene loads into View
      var gridItems : [[Geometry]] = [rectangles, handleLines, gridHandlePoints.flatMap { $0 }, mids]
      
      
      
      // Corner Ovals
      let top = gridTup.points.top, bottom = gridTup.points.bottom
      let corners : [CGPoint] = [top.first!, top.last!, bottom.last!, bottom.first!]
      let corOv : [Oval] = corners.map(redCirc)
      
      let topC = [top.first!, top.last!],
      rightC = [top.last!, bottom.last!],
      bottomC = [bottom.first!, bottom.last!],
      leftC = [top.first!, bottom.first!]
      
      let on : CGFloat = 1/3
      let oTop = centers(between: topC ).map(moveByVector).map{ $0(unitY * (on * d)) }.map(pointToLabel)
      let oRight = centers(between: rightC).map(moveByVector).map{ $0(unitX * (on * d)) }.map(pointToLabel).map(swapRotation) // Fixme repeats above
      let oBottom = centers(between: bottomC).map(moveByVector).map{ $0(unitY * -(on * d)) }.map(pointToLabel)
      let oLeft = centers(between: leftC).map(moveByVector).map{ $0(unitX * -(on * d)) }.map(pointToLabel).map(swapRotation)
      let overallDimes : [Label] = zip(oTop, distance(between: topC)).map(helperJoin) +
        zip(oRight, distance(between: rightC)).map(helperJoin) +
        zip(oBottom, distance(between: bottomC)).map(helperJoin) +
        zip(oLeft, distance(between: leftC)).map(helperJoin)
      
      
      // put in on screen when gameScene loads into View
      var boundingItems : [[Geometry]] = [
        rectangles, corOv, overallDimes]
      
      let firstBay = Array(gridTup.points.top[0...1] + gridTup.points.bottom[0...1].reversed()) + [gridTup.points.top[0]]
      let circles = centers(between: firstBay).map(redCirc)
      var selectedItems : [[Geometry]] = [rectangles, circles]
      
      
      
      self.geometries = [gridItems, boundingItems, selectedItems]
      self.index = 0
      
      
      
      tapped()
    }
  }
  
  init(model : Model2D)
  {
    
    self.model = model
    
    super.init(frame: UIScreen.main.bounds)
    
    // Specialtiy SpriteKitScene
    let aScene = GameScene(size: UIScreen.main.bounds.size)
    self.presentScene(aScene)
    
    
    self.ignoresSiblingOrder = true
    self.showsFPS = true
    self.showsNodeCount = true
    
    self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Sprite2DGraph.tapped)))
  }
  
  
  
  @objc func tapped()
  {
    index = (index + 1) < geometries.count ? index + 1 : 0
    
    self.scene!.removeAllChildren()
    
    for list in geometries[index]
    {
      for item in list {
        self.addChildR(item)
      }
    }
    
  }
  
  
  
  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }
  
  // SceneKit Handlering...

  //var scene : SKScene
  
  // put on the canvas!!
  func addChildR<T>(_ node: T) -> SKNode
  {
    if let oval = node as? Oval
    {
      let node = SKShapeNode(ellipseOf: oval.ellipseOf)
      node.position = oval.position
      node.fillColor = oval.fillColor
      node.lineWidth = 0.0
      scene!.addChild(node)
      return node
    }
    if let label = node as? Label
    {
      let node = SKLabelNode(text: label.text)
      node.fontName = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.bold).fontName
      node.fontSize = 18
      node.position = label.position
      node.zRotation = label.rotation == .h ? 0.0 : 0.5 * CGFloat.pi
      node.verticalAlignmentMode = .center
      scene!.addChild(node)
      return node
    }
    if let line = node as? Line
    {
      let path = CGMutablePath()
      path.move(to: line.start)
      path.addLine(to: line.end)
      let node = SKShapeNode(path: path)
      scene!.addChild(node)
      
      return node
    }
    if let line = node as? StrokedLine
    {
      let path = CGMutablePath()
      path.move(to: line.line.start)
      path.addLine(to: line.line.end)
      let node = SKShapeNode(path: path)
      node.lineWidth = line.strokeWidth
      node.strokeColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
      scene!.addChild(node)
      return node
    }
    fatalError()
  }
  
  // ...SceneKit Handlering

  
  
  // Viewcontroller Functions

  
}
