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

func modelToTexturesElev ( edges: [C2Edge], origin: CGPoint) -> [Geometry]
{
  let horizontals = edges.filter{ $0.content == "Ledger"}.map
  {
    ledge in
    return (ledge.p1, ledge.p2) |>
      {
        (a, b) -> TextureLine in
        return TextureLine(label: "ledger elev", start: a, end: b)
    }
  }
  
  let verticals = edges.filter{ $0.content == "Standard"}.map
  {
    line  -> TextureLine in

        return TextureLine(label: "std elev",
                           start: CGPoint( line.p1.x, line.p1.y) ,
                           end: CGPoint( line.p2.x, line.p2.y))
    

  }
  let base = edges.filter{ $0.content == "BC"}.map
  {
    return
      TextureLine(label: "base",
                  start: $0.p1 ,
                  end: $0.p2 )
    
  }
  let jack = edges.filter{ $0.content == "Jack"}.map
  {
    
    TextureLine(label: "sj",
                start: $0.p1 ,
                end: $0.p2 )
  }
  
  let combined = horizontals + verticals + base + jack
  
  let thirdPass : [Geometry] = (combined, origin.asVector()) |> moveGroup
  
  return thirdPass
}


struct Scaff2D {
  enum ScaffType
  {
    case ledger
    case basecollar
    case jack
    case standard
  }
  enum DrawingType
  {
    case plan
    case cross
    case longitudinal
  }
  
  var start: CGPoint
  var end: CGPoint
  let part : ScaffType
  let view : DrawingType
}
extension Scaff2D : Geometry {
  var position: CGPoint {
    get { return (self.start + self.end).center }
    set(newValue){
      let previous = (self.start + self.end).center
      let dif = newValue - previous
      start = start + dif
      end = end + dif
    }
  }
}

extension Scaff2D : CustomStringConvertible {
  var description: String {
    return "\(part) \(view) - \(CGSegment(p1:start, p2:end).length), \(position)"
  }
}

// Used to be view controller

  


let planEdgeToGeometry : ([C2Edge], CGPoint) -> [Geometry] = { edges, origin in
  let geo1 = edges |> modelToPlanGeometry
  let geo2 :  [Geometry] = (geo1, origin.asVector() ) |> moveGroup
  return geo2
}



func modelToPlanGeometry ( edges: [C2Edge]) -> [Scaff2D]
{
  
  return edges.map { edge in
    
    switch edge.content
    {
    case "Standard": return Scaff2D(start: edge.p1, end: edge.p2, part: .standard, view: .plan)
    case "Jack" : return Scaff2D(start: edge.p1, end: edge.p2, part: .jack, view: .plan)
    case "Ledger" : return Scaff2D(start: edge.p1, end: edge.p2, part: .ledger, view: .plan)
    case "BC" : return Scaff2D(start: edge.p1, end: edge.p2, part: .basecollar, view: .plan)
      
    default :
      fatalError("Some other type showed up")
    }
    
  }
  
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


func modelToLinework ( edges: [C2Edge], origin: CGPoint) -> [Geometry]
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
  
  
  /// Move to orign
  
  let thirdPass : [Geometry] = (lines + labelsSecondPass).map{
    var new = $0
    new.position = $0.position + origin.asVector()
    return new
  }
  
  
  
  return thirdPass
}


 
  
  // ...SceneKit Handlering
  
  
  
  // Viewcontroller Functions
  

