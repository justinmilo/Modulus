//
//  Scaffolding.swift
//  Meccano
//
//  Created by Justin Smith on 7/29/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Graphe
import BlackCricket
import Singalong
import Geo

func modelToTexturesElev ( edges: [C2Edge] ) -> [Scaff2D]
{
  let horizontals = edges.filter{ $0.content == .ledger}.map
  {
    ledge in
    return (ledge.p1, ledge.p2) |>
      {
        (a, b) -> Scaff2D in
        return Scaff2D(start: a, end: b, part: .ledger, view: .longitudinal)
    }
  }
  
  let verticals = edges.filter{ $0.content == .standardGroup}.flatMap
  {
    line  -> [Scaff2D] in
    
    let lengths = maximumStandards(in: abs( (line.p1 + line.p2).diagonalExtent ) )
    let pos = lengths |> curry(segToPosOrigin)(line.p1.y)
    let s : [Scaff2D] = zip(pos, pos.dropFirst()).map {
      let s =       Scaff2D(start: CGPoint( line.p1.x, $0.0), end: CGPoint( line.p2.x, $0.1), part: .standard, view: .longitudinal)
      
      
      return s
    }
    return s
  }
  let base = edges.filter{ $0.content == .bc}.map
  {
    
    return Scaff2D(start: $0.p1 ,
                   end: $0.p2, part: .basecollar, view: .longitudinal)
    
  }
  let jack = edges.filter{ $0.content == .jack}.map
  {
    return Scaff2D(start: $0.p1 ,
                   end: $0.p2, part: .jack, view: .longitudinal)
  }
  let diag = edges.filter{ $0.content == .diag}.map { (edge: C2Edge) -> Scaff2D in
    if edge.p1.x == edge.p2.x {
      return Scaff2D(start: edge.p1 ,
                     end: edge.p2, part: .diag, view: .cross)
    }
    return Scaff2D(start: edge.p1 ,
                   end: edge.p2, part: .diag, view: .longitudinal)
  }
  
  return horizontals + verticals + base + jack + diag
  
}


struct Scaff2D {
  enum ScaffType
  {
    case ledger
    case basecollar
    case jack
    case diag
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
extension Scaff2D {
  var upToTheRight : Bool  {
    return start.x < end.x && start.y < end.y
  }
}

extension Scaff2D : CustomStringConvertible {
  var description: String {
    return "\(part) \(view) - \(CGSegment(p1:start, p2:end).length), \(position)"
  }
}

// Used to be view controller




let planEdgeToGeometry : ([C2Edge]) -> [Scaff2D] = { edges in
  return edges.map { edge in
    switch edge.content
    {
    case .standardGroup : return Scaff2D(start: edge.p1, end: edge.p2, part: .standard, view: .plan)
    case .jack : return Scaff2D(start: edge.p1, end: edge.p2, part: .jack, view: .plan)
    case .ledger : return Scaff2D(start: edge.p1, end: edge.p2, part: .ledger, view: .plan)
    case .bc : return Scaff2D(start: edge.p1, end: edge.p2, part: .basecollar, view: .plan)
      
    default :
      fatalError("Some other type showed up")
    }
    
  }
}

let twometer : CGFloat = 2.00/1.6476

import SpriteKit
import Make2D

private func firstHalf( item: Scaff2D, cache : inout [SKSpriteNode]) -> SKSpriteNode {
  let name = nameHash(item)
  let copy = copyFromCache(name: name, cache: cache)
  guard copy == nil else { return (copy!) }
  
  let imageGenny :()->UIImage = {
    let length = CGSegment(p1:item.start, p2:item.end).length
    let path = (length, item.part, item.view) |> imageName
    let bundle = Bundle(for: ViewController.self)
    guard let aImage = UIImage(named: path!, in: bundle, compatibleWith: nil) else { fatalError("no Image")}
    return aImage
  }
  
  let (ledgerNode, newCache) = addToCache(name: name, imageGen: imageGenny , cache: cache)
  cache = newCache
  return ledgerNode
}


func convertNOROTGeneral ( item: Scaff2D, cache : inout [SKSpriteNode]) -> SKSpriteNode {
  let ledgerNode : SKSpriteNode = firstHalf(item: item, cache: &cache)
  
  ledgerNode.setScale( twometer)
  ledgerNode.position = (item.start + item.end).center
  return ledgerNode
}


func convertDynamic ( item: Scaff2D, cache : inout [SKSpriteNode]) -> SKSpriteNode {
  precondition(item.part == .diag)
  
  let name = nameHash(item)
  let copy = copyFromCache(name: name, cache: cache)
  guard copy == nil else { return (copy!) }
  
  let imageGenny :()->UIImage = {
    let box = item.start + item.end
    if item.upToTheRight {
      return diagImage(riseMM: box.height * 10, runMM: box.width * 10)
    } else {
      return otherDiagImage(riseMM: box.height * 10, runMM: box.width * 10)
    }
  }
  
  let (ledgerNode, newCache) = addToCache(name: name, imageGen: imageGenny , cache: cache)
  cache = newCache
  
  return ledgerNode
}


func createScaff2DNode (item: Scaff2D, cache: inout [SKSpriteNode]) -> SKNode?
{
  switch (item.part,  item.view) {
  case (.ledger, .plan),
       (.standard,  .plan),
       (.diag, .plan):
    let ledgerNode: SKSpriteNode
    ledgerNode = firstHalf(item: item, cache: &cache)
    
    ledgerNode.setScale( twometer)
    ledgerNode.position = (item.start + item.end).center
    ledgerNode.zRotation = CGFloat(item.start.x == item.end.x ? CGFloat.halfPi : 0)
    return ledgerNode
  case (.jack,  .plan): return nil
  case (.basecollar, .plan): return nil
    
  case (.ledger, .longitudinal),
       (.ledger, .cross):
    let node = convertNOROTGeneral(item: item, cache:&cache)
    let adjujstmentV = CGVector(0, -1.44) * (2.00/1.6476)
    node.position = node.position + adjujstmentV
    return node
    
  case (.diag, .longitudinal):
    let node = convertDynamic(item: item, cache:&cache)
    
    node.setScale( twometer/3)
    //node.xScale = item.upToTheRight == true ? node.xScale :  -node.xScale
    node.position = (item.start + item.end).center + unitY * -2 + unitX * 1
    
    return node
    
  case (.diag, .cross):
    let cgPath = CGMutablePath()
    cgPath.move(to: item.start)
    cgPath.addLine(to: item.end)
    let node = SKShapeNode(path: cgPath)
    return node
    
  case (.standard,  .longitudinal),
       (.standard,  .cross):
    
    let node = convertNOROTGeneral(item: item, cache:&cache)
    let adjujstmentV = CGVector(0, 8.64) * (2.00/1.6476)
    node.position = node.position + adjujstmentV
    return node
    
  case (.jack,  .longitudinal),
       (.jack,  .cross):
    let node = convertNOROTGeneral(item: item, cache:&cache)
    let     adjujstmentV = CGVector(0, 0) * (2.00/1.6476)
    node.position = node.position + adjujstmentV
    return node
    
  case (.basecollar, .longitudinal),
       (.basecollar, .cross):
    let node = convertNOROTGeneral(item: item, cache:&cache)
    let     adjujstmentV = CGVector(0, 4.74) * (2.00/1.6476)
    node.position = node.position + adjujstmentV
    return node
    
  }
}

