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
import Singalong
import Geo
import Make2D
import BlackCricket


extension Float {
  func rounded(toPlaces places:Int) -> Float {
    let divisor = pow(10.0, Float(places))
    return (self * divisor).rounded() / divisor
  }
}



// Used to be view controller
/// Geometry View
class Sprite2DView : SKView {
  
  var scale : CGFloat = 1.0
  {
    didSet {
      self.mainNode.xScale = scale
      self.mainNode.yScale = scale
    }
  }
  var mainNode : SKNode
  
  override init(frame: CGRect)
  {
    mainNode = SKNode()
    super.init(frame: frame)
    
    // Specialtiy SpriteKitScene
    let aScene = SKScene(size: frame.size)
    aScene.addChild(mainNode)
    self.presentScene(aScene)
    self.ignoresSiblingOrder = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }
  
  func redraw(_ g:[Geometry]) {
    self.mainNode.removeAllChildren()
    
    for item in g
    {
      self.addChildR(item)
    }
  }
  
  func addTempRect( rect: CGRect, color: UIColor) {
    let globalLabel = SKShapeNode(rect: rect )
    globalLabel.fillColor = color
    self.scene?.addChild(globalLabel)
    globalLabel.alpha = 0.0
    let fadeInOut = SKAction.sequence([
      .fadeAlpha(to: 0.3, duration: 0.2),
      .fadeAlpha(to: 0.0,duration: 0.4)])
    globalLabel.run(fadeInOut, completion: {
      print("End and Fade Out")
    })
  }
  
  // SceneKit Handlering...
  
  //var scene : SKScene
  
  // put on the canvas!!
  func addChildR<T>(_ node: T)
  {
    if let representable = node as? SKRepresentable
    {
      representable.asNode |> mainNode.addChild
    }
    
   
    else if let line = node as? Scaff2D
    {
      
      let newNode = createScaff2DNode(item: line, cache: &self.cache)
      if let n = newNode {
        //n |> scalePosition(scale)
        n |> mainNode.addChild
      }
      
    }
    
    
    
    else { fatalError()}
    
    
    
    
    
  }
  
  var cache : [SKSpriteNode] = []
  
  // ...SceneKit Handlering
  
  
  
  // Viewcontroller Functions
  
 
  
  
  /*
   createNameHash
   if in cache
     deploy Cached
   else
     create Node
     cache node
 */
  
  
  
}

let twometer : CGFloat = 2.00/1.6476

private func firstHalf( item: Scaff2D, cache : inout [SKSpriteNode]) -> SKSpriteNode {
  let name = nameHash(item)
  let copy = copyFromCache(name: name, cache: cache)
  guard copy == nil else { return (copy!) }
  
  let imageGenny :()->UIImage = {
    let length = CGSegment(p1:item.start, p2:item.end).length
    let path = (length, item.part, item.view) |> imageName
    guard let aImage = UIImage(named: path!) else { fatalError("no Image")}
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
    let foo = diagImage(riseMM: box.height * 10, runMM: box.width * 10)
    return foo
  }
  
  let (ledgerNode, newCache) = addToCache(name: name, imageGen: imageGenny , cache: cache)
  cache = newCache
  
  ledgerNode.setScale( twometer/3)
  ledgerNode.xScale = item.upToTheRight == true ? ledgerNode.xScale :  -ledgerNode.xScale
  ledgerNode.position = (item.start + item.end).center + unitY * -36/3 + unitX * 5
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
    let adjujstmentV = CGVector(0, 8.64) * (2.00/1.6476)
    node.position = node.position + adjujstmentV
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

