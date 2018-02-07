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



class CElevation {
  func createELevation( _skCordinateModel: NonuniformModel2D) -> [[Geometry]]
  {
    let horizontals = _skCordinateModel.orderedPointsUpToDown.map
    { $0.segments(connectedBy:
      { (a, b) -> TextureLine in
        return TextureLine(label: "ledger elev", start: a, end: b)
    })
    }
    let verticals = _skCordinateModel.edgesAndPoints.edges.verticals.map
    {
      line  -> [TextureLine] in
      
      let distance = line.start.y - line.end.y
      let stds = maximumRepeated(availableInventory: [50, 100], targetMaximum: distance)
      let g = Grid(stds)
      
      return zip(g.positions, g.positions.dropFirst()).map
        {
          arg -> TextureLine in
          
          return TextureLine(label: "std elev",
                             start: CGPoint( line.start.x, line.start.y - arg.0) ,
                             end: CGPoint( line.end.x, line.start.y - arg.1))
      }
      
    }
    let base = _skCordinateModel.edgesAndPoints.points.top.map {
      return [
        TextureLine(label: "base",
                    start: $0 ,
                    end: $0),
        
        
        TextureLine(label: "sj",
                    start: $0 ,
                    end: $0)
      ]
    }
    
    
    return horizontals + verticals + base
  }
}

struct CEverything {
  
  func geometries (model: NonuniformModel2D, scale: CGFloat, bounds: CGRect) -> [[Geometry]]
  {
    //_skCordinateModel = model
    // IMPORTANT: Scale the orgin by opposite of scale! for some reason
    // rest of scaling in addChildR
    let origin = CGPoint(model.origin.x / scale, bounds.size.height / scale - model.origin.y / scale)
    let _skCordinateModel = NonuniformModel2D(origin: origin, rowSizes: Grid(model.rowSizes.map{ -$0}), colSizes: model.colSizes)
    // transform Cordinate Space
    
    
    // offset distance
    let d : CGFloat = 40.0
    
    // First Geometry Set...
    // Grid
    let grid = _skCordinateModel.edgesAndPoints
    
    let points = grid.points.all.map {
      return LabeledPoint(position: $0, label: "Std")
    }
    
    let horizontals : [[TextureLine]] = _skCordinateModel.orderedPointsLeftToRight.map{ $0.texturedLines }
    let verticals : [[TextureLine]] = _skCordinateModel.orderedPointsUpToDown.map{ $0.texturedLines }
    
    let rectangles : [Geometry] = (horizontals + verticals).flatMap { $0 }
    
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
    
    
    
    
    let elevations = CElevation().createELevation(_skCordinateModel: _skCordinateModel)
    
    return [rectangles, mids, points] + elevations +
    gridItems + boundingItems + selectedItems
    
  }
}




// Used to be view controller

class C2Edge2DView {
  
  
  //  func modelToPlanGeometry ( edges: [C2Edge]) -> [Geometry]
  //  {
  //    fatalError("Some other type showed up")
  //
  //    return edges.map { edge in
  //
  //      switch edge.content
  //      {
  //      case "Standards": break
  //      case "Jack" : break
  //      case "Ledger" : break
  //      case "BC" : break
  //
  //      default :
  //        fatalError("Some other type showed up")
  //      }
  //
  //    }
  //  }
  
  func modelToLinework ( edges: [C2Edge]) -> [Geometry]
  {
    let lines : [Geometry] = edges.map { edge in
      return Line(start: edge.p1, end: edge.p2)
    }
    
    let labels = edges.map { edge -> Label in
      
      let direction : Label.Rotation = edge.content == "Ledger" || edge.content == "Diag" ? .h : .v
      let vector = direction == .h ? unitY * 10 : unitX * 10
      return Label(text: edge.content, position: (edge.p1 + edge.p2).center + vector, rotation: direction)
      
    }
    
    let labelsSecondPass : [Geometry] = labels.reduce([])
    {
      (res, geo) -> [Label] in
      
      if res.contains(where: {
        
        let r = CGRect.around($0.position, size: CGSize(40,40))
        return r.contains(geo.position)
        
      })
      {
        var new = geo
        new.position = new.position + CGVector(dx: 15, dy: 15)
        return res + [new]
      }
      
      return res + [geo]
    }
    
    let thirdPass : [Geometry] = (lines + labelsSecondPass).map{
      var new = $0
      new.position = $0.position + CGVector(dx: 80, dy: 200)
      return new
    }
    
    
    
    return thirdPass
  }
  
  
  var scale : CGFloat = 1.0
  
  
  
  
  // ...SceneKit Handlering
  
  
  
  // Viewcontroller Functions
  
}
