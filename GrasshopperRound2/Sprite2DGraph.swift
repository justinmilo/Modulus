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

struct NonuniformModel2D {
  var origin: CGPoint
  var rowSizes: Grid
  var colSizes: Grid
}

extension NonuniformModel2D {
  var edgesAndPoints : (edges: EdgeCollection, points: PointCollection)
  {
    get {
      
      let xPoints = self.colSizes.positions.map { $0 + self.origin.x }
      let yPoints = self.rowSizes.positions.map { $0 + self.origin.y }
      
      let pointsLeftToRight = xPoints.map { x in
        yPoints.map { y in
          return CGPoint(x,y)
        }
      }
      
      let pointsUpToDown = yPoints.map { y in
        xPoints.map { x in
          return CGPoint(x,y)
        }
      }
        
        let linesUp = pointsLeftToRight.map{ Line(start: $0.first!, end: $0.last!) }
        let linesAcross = pointsUpToDown.map{ Line(start: $0.first!, end: $0.last!) }
        
        return (edges: EdgeCollection(verticals:linesUp, horizontals:linesAcross), points: PointCollection(
          all: pointsLeftToRight.flatMap{ $0 },
          top: pointsUpToDown.last!,
          right: pointsLeftToRight[0],
          bottom: pointsUpToDown[0],
          left: pointsLeftToRight.last!
        ))
      }
      
      
    
  }
}






// Used to be view controller

class Sprite2DGraph : SKView {
  
  var geometries : [[[Geometry]]] = []
  var index: Int = 0
  
  var scale : CGFloat = 1.0
  private var _skCordinateModel : NonuniformModel2D!
  var model : NonuniformModel2D! {
    
    didSet {
      
      //_skCordinateModel = model
      // IMPORTANT: Scale the orgin by opposite of scale! for some reason
      // rest of scaling in addChildR 
      let origin = CGPoint(model.origin.x / scale, self.bounds.size.height / scale - model.origin.y / scale)
      _skCordinateModel = NonuniformModel2D(origin: origin, rowSizes: Grid(model.rowSizes.map{ -$0}), colSizes: model.colSizes)
      // transform Cordinate Space
      
      
      // offset distance
      let d : CGFloat = 40.0
      
      // First Geometry Set...
      // Grid
      let grid = _skCordinateModel.edgesAndPoints
      let rectangles = (grid.edges.horizontals + grid.edges.verticals).map{ StrokedLine.init( line: $0, strokeWidth: 3.0) }
      
      // Handle Points
      let gridHandlePoints = getHandlePoints(points: grid.points, offset: d)
      let handleLines = zip(grid.points.boundaries, gridHandlePoints.flatMap{$0}).map(Line.init)
      
      // Mid Points
      let mids = dimPoints(points: gridHandlePoints, offset: 40)
      
      // put in on screen when gameScene loads into View
      let gridItems : [[Geometry]] = [rectangles, handleLines, gridHandlePoints.flatMap { $0 }, mids]
      
      
      
      // Corner Ovals
      let top = grid.points.top, bottom = grid.points.bottom
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
      let boundingItems : [[Geometry]] = [
        rectangles, corOv, overallDimes]
      
      var selectedItems : [[Geometry]]
      if grid.points.top.count > 1, grid.points.bottom.count > 1
      {
        // top left to right
        let first = grid.points.top[0...1]
        // bottom right to left
        let second = grid.points.bottom[0...1].reversed()
        // and back to the top
        let final = grid.points.top[0]
        let firstBay =  Array(first + second ) + [final]
        let circles = centers(between: firstBay).map(redCirc)
        selectedItems = [rectangles, circles]
      }
      else {
        selectedItems = []
      }
      
      
      
      
      
      
      self.geometries = [[rectangles, mids],  gridItems, boundingItems, selectedItems]
      redraw(index)
    }
  }
  
  func testingGrid(origin:CGPoint) -> [[Geometry]]
  {
    var gPoints =
      [CGPoint(0,0),
       CGPoint(100,100),
       CGPoint(200,200)]
    gPoints = gPoints.map{ $0 + origin.asVector() }
    let gCircles = gPoints.map(redCirc)
    let labels : [Label] = gPoints.map(pointToLabel).map{ var a = $0;
      a.text = String(describing: $0.position); return a }
    return [gCircles, labels]
  }
  
  init(model : Model2D)
  {
    
    self.model = NonuniformModel2D(origin: model.origin, rowSizes: Grid((0...model.rows).map{ CGFloat($0) * model.dx }) , colSizes: Grid((0...model.col).map{ CGFloat($0) * model.dy }))
    
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
    redraw(index)
  }
  
  func redraw(_ i:Int) {
    self.scene!.removeAllChildren()
    
    for list in geometries[i]
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
  @discardableResult func addChildR<T>(_ node: T) -> SKNode
  {
    if let oval = node as? Oval
    {
      let node = SKShapeNode(ellipseOf: oval.ellipseOf)
      node.position = oval.position  * scale
      node.fillColor = oval.fillColor
      node.lineWidth = 0.0
      scene!.addChild(node)
      return node
    }
    if let label = node as? Label
    {
      let node = SKLabelNode(text: label.text)
      node.fontName = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium).fontName
      node.fontSize = 14// * scale
      node.position = label.position * scale
      node.zRotation = label.rotation == .h ? 0.0 : 0.5 * CGFloat.pi
      node.verticalAlignmentMode = .center
      scene!.addChild(node)
      return node
    }
    if let line = node as? Line
    {
      let path = CGMutablePath()
      path.move(to: line.start  * scale)
      path.addLine(to: line.end  * scale)
      let node = SKShapeNode(path: path)
      scene!.addChild(node)
      
      return node
    }
    if let line = node as? StrokedLine
    {
      let path = CGMutablePath()
      path.move(to: line.line.start  * scale)
      path.addLine(to: line.line.end  * scale)
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
