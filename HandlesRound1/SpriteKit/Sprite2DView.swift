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
  
  override init(frame: CGRect)
  {
    
    
    super.init(frame: frame)
    
    // Specialtiy SpriteKitScene
    let aScene = SKScene(size: frame.size)
    self.presentScene(aScene)
    self.ignoresSiblingOrder = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }
  
  func redraw(_ g:[Geometry]) {
    self.scene!.removeAllChildren()
    
    for item in g
    {
      self.addChildR(item)
    }
  }
  
  // SceneKit Handlering...
  
  //var scene : SKScene
  
  // put on the canvas!!
  func addChildR<T>(_ node: T)
  {
    if let representable = node as? SKRepresentable
    {
      representable.asNode |> scene!.addChild
    }
    
    if let oval = node as? Oval
    {
      createOval(oval) |> scene!.addChild
    }
    else if let label = node as? Label
    {
      let n = createLableNode(label)
      //n.position = CGPoint(300,300)

      n |> scalePosition(scale)
      n |> scene!.addChild
    }
    else if let line = node as? Line
    {
      let node = createLineShapeNode(line)
      node |> scaleAll(scale)
      node |> scene!.addChild
    }
    else if let line = node as? StrokedLine
    {
      let node = createLineShapeNode(line.line)
      
      scene!.addChild(node)
    }
    else if let line = node as? Scaff2D
    {
      
      let newNode = createScaff2DNode(item: line)
      if let n = newNode {
        n |> scalePosition(scale)
        n |> scene!.addChild
      }
      
    }
    
    else if let p = node as? LabeledPoint
    {
      let circleN = createCircleShapeNode(p)
      circleN |> scene!.addChild
      let n = createLableNode(Label(text: p.label))
      n |> scene!.addChild
      
    }
    else if let line = node as? TextureLine
    {
      print(line)
    }
    
    
    else { fatalError()}
    
    
    
    
    
  }
  
  var cache : [SKSpriteNode] = []
  
  // ...SceneKit Handlering
  
  
  
  // Viewcontroller Functions
  
 
  func convertGeneral ( item: Scaff2D) -> SKSpriteNode {
    let length = CGSegment(p1:item.start, p2:item.end).length
    let name = (length, item.part, item.view) |> nameHash
    let path = (length, item.part, item.view) |> image
    let (ledgerNode, newCache) = (name, path!, self.cache) |> grabFromCacheOrCreate
    cache = newCache
    
    let twometer : CGFloat = 2.00/1.6476
    ledgerNode.setScale( twometer)
    ledgerNode.position = (item.start + item.end).center
    ledgerNode.zRotation = CGFloat(item.start.x == item.end.x ? CGFloat.halfPi : 0)
    return ledgerNode
  }
  
  func convertNOROTGeneral ( item: Scaff2D) -> SKSpriteNode {
    let length = CGSegment(p1:item.start, p2:item.end).length
    let name = (length, item.part, item.view) |> nameHash
    let path = (length, item.part, item.view) |> image
    let (ledgerNode, newCache) = (name, path!, self.cache) |> grabFromCacheOrCreate
    cache = newCache
    
    let twometer : CGFloat = 2.00/1.6476
    ledgerNode.setScale( twometer)
    ledgerNode.position = (item.start + item.end).center
    return ledgerNode
  }
  
  func createScaff2DNode (item: Scaff2D) -> SKNode?
  {
    switch (item.part,  item.view) {
    case (.ledger, .plan): return convertGeneral(item: item)
    case (.standard,  .plan): return convertGeneral(item: item)
    case (.jack,  .plan): return nil
    case (.basecollar, .plan): return nil
    case (.diag, .plan): return convertGeneral(item: item)
      
    case (.ledger, .longitudinal),
         (.ledger, .cross):
      let node = convertNOROTGeneral(item: item)
      let adjujstmentV = CGVector(0, -1.44) * (2.00/1.6476)
      node.position = node.position + adjujstmentV
      return node
      
    case (.diag, .longitudinal),
         (.diag, .cross):
      let cgPath = CGMutablePath()
      cgPath.move(to: item.start)
      cgPath.addLine(to: item.end)
      let node = SKShapeNode(path: cgPath)
      return node
      
    case (.standard,  .longitudinal),
         (.standard,  .cross):
      
      let node = convertNOROTGeneral(item: item)
      let adjujstmentV = CGVector(0, 8.64) * (2.00/1.6476)
      node.position = node.position + adjujstmentV
      return node
      
    case (.jack,  .longitudinal),
         (.jack,  .cross):
      let node = convertNOROTGeneral(item: item)
      let     adjujstmentV = CGVector(0, 0) * (2.00/1.6476)
      node.position = node.position + adjujstmentV
      return node
      
    case (.basecollar, .longitudinal),
         (.basecollar, .cross):
      let node = convertNOROTGeneral(item: item)
      let     adjujstmentV = CGVector(0, 4.74) * (2.00/1.6476)
      node.position = node.position + adjujstmentV
      return node
      
    }
  }
  
}



func createOval(_ oval: Oval) -> SKShapeNode
{
  let node = SKShapeNode(ellipseOf: oval.ellipseOf)
  node.fillColor = oval.fillColor
  node.lineWidth = 0.0
  return node
}



func createLableNode(_ label: Label) -> SKLabelNode {
  let node = SKLabelNode(text: label.text)
  node.fontName = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium).fontName
  node.fontSize = 14// * scale
  node.zRotation = label.rotation == .h ? 0.0 : 0.5 * CGFloat.pi
  node.position = label.position
  node.verticalAlignmentMode = .center
  return node
}

func changeFontColor(color: UIColor, _ node: SKLabelNode) {
  node.fontColor = color
}

func createLineShapeNode(_ line: Line) -> SKShapeNode {
let path = CGMutablePath()
path.move(to: line.start)
path.addLine(to: line.end)
let node = SKShapeNode(path: path)
  return node
}

func createCircleShapeNode(_ line: Geometry) -> SKShapeNode {
  let rectSize = CGSize(5,5)
  let path = CGMutablePath()
  path.move(to: line.position)
  path.addEllipse(in: CGRect.around(line.position, size: rectSize))
  let node = SKShapeNode(path: path)
  return node
}


func scaleTransform( _ scale: CGFloat) -> (SKNode)-> Void
{
  return {skNode in
    skNode.setScale(scale)
  }
}

func scalePosition( _ scale: CGFloat) -> (SKNode)-> Void
{
  return {skNode in
    skNode.position = skNode.position * scale
  }
}

func highlightStrokeShapeNode(node:SKShapeNode)-> Void
{
  node.lineWidth = 2.0
  node.strokeColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
}



let scaleAll : (CGFloat) -> (SKNode)-> Void = scaleTransform <> scalePosition
