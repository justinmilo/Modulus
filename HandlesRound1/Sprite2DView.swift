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




// Used to be view controller

class Sprite2DView : SKView {
  
    

  
  var geometries : [[[Geometry]]] = []
  var index: Int = 0
  var scale : CGFloat = 1.0
  
  override init(frame: CGRect)
  {

    super.init(frame: frame)
    
    // Specialtiy SpriteKitScene
    let aScene = SKScene(size: frame.size)
    self.presentScene(aScene)
    
    self.ignoresSiblingOrder = true
  }
  
  
  
  @objc func tapped()
  {
    index = (index + 1) < geometries.count ? index + 1 : 0
    redraw(index)
  }
  
  func redraw(_ i:Int) {
    guard i < geometries.count else { return }
    
    self.scene!.removeAllChildren()
    
    for list in geometries[i]
    {
      for item in list {
        self.addChildR(item)
      }
    }
    print(self.scene!.children)
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
    if let p = node as? LabeledPoint
    {
      let node : SKSpriteNode
      // list of assets
      let dict : [String : UIImage] = [ "Std" : #imageLiteral(resourceName: "Std Plan.png") ]
      
      // match asset to length of line
      let options = dict.filter
      {
        (tup) -> Bool in
        if tup.key == p.label
        {
          return true
        }
        return false
      }
      
      let second = options[p.label]!
      
      if cache.map({ $0.name }).contains(p.label) {
        let nodeIndex = cache.index(where: { (candidate) -> Bool in
          candidate.name == p.label
        })!
        let nodeToClone = cache[nodeIndex]
        node = nodeToClone.copy() as! SKSpriteNode
      }
      else {
        node = SKSpriteNode(texture: SKTexture(image: second))
        cache.append(node)
      }
      
      let twometer : CGFloat = 2.00/1.6476
      //let scale = self.scale + twometer
      node.setScale( twometer)
      node.position = p.position  * scale
      scene!.addChild(node)
      node.name = p.label
      return node
      
      
    }
    if let line = node as? TextureLine, line.label != ""
    {
      let node : SKSpriteNode
      // list of assets
      let ledgers : [CGFloat : (String, UIImage)] = [
        200 : ("2.0m Ledger", UIImage(named: "2m")!),
        100 : ("1.0m Ledger", UIImage(named: "1m")!),
        150 : ("1.5m Ledger", UIImage(named: "1.5m")!)
      ]
      let stds : [CGFloat : (String, UIImage)] = [
        100 : ("1.0m stds", UIImage(named: "2.0m Std")!),
        50 : ("0.5m stds", UIImage(named: "0.5m Std")!),
        ]
      
      let pts : [String : UIImage] = [
        "base" : UIImage(named: "Base Collar")!,
        "sj" : UIImage(named: "Screw Jack")!
      ]
      
      
      let options : [CGFloat : (String, UIImage)]
      
      var adjujstmentV = CGVector.zero
      if ( line.label == "ledger elev" )
      {
        
        adjujstmentV = CGVector(0, -1.44)
        // match asset to length of line
        options = ledgers.filter
          {
            (tup) -> Bool in
            if tup.key == CGSegment(p1: line.line.start, p2: line.line.end).length
            {
              return true
            }
            return false
        }
      }
      else if ( line.label ==  "std elev")
      {
        adjujstmentV = CGVector(0, 8.64)
        
        
        options = stds.filter
          {
            (tup) -> Bool in
            if tup.key == CGSegment(p1: line.line.start, p2: line.line.end).length
            {
              return true
            }
            return false
        }
      }
      else
      {
        let foo = pts[line.label]
        options = [ 0.0 : (line.label, foo!)]
      }
      
      
      let second = (options.first)
      let name = second?.value.0 ?? "NA"
      let image = second?.value.1 ?? #imageLiteral(resourceName: "Screw Jack.png")
      
      let optNode = cache.first {
        $0.name == name
      }
      if let real = optNode {
        node = real.copy() as! SKSpriteNode
      }
      else {
        node = SKSpriteNode(texture: SKTexture(image:image))
        cache.append(node)
      }
      
      node.setScale( 2.00/1.6476)
      node.position = (line.line.start+line.line.end).center  * scale
      node.position = node.position + ( adjujstmentV *  2.00/1.6476)
      //node.zRotation = CGFloat(line.line.start.x == line.line.end.x ? CGFloat.halfPi : 0)
      scene!.addChild(node)
      node.name = name
      return node
    }
    if let line = node as? TextureLine, line.label == ""
    {
      
      
      
      let node : SKSpriteNode
      // list of assets
      let dict : [CGFloat : (String, UIImage)] = [
        200 : ("2.0m", #imageLiteral(resourceName: "2.0m plan")),
        100 : ("1.0m", #imageLiteral(resourceName: "1m plan.png")),
        150 : ("1.5m", #imageLiteral(resourceName: "1.5m Plan.png"))
      ]
      
      // match asset to length of line
      let options = dict.filter
      {
        (tup) -> Bool in
        if tup.key == CGSegment(p1: line.line.start, p2: line.line.end).length
        {
          return true
        }
        return false
      }
      
      let second = (options.first)
      let name = second?.value.0 ?? "NA"
      let image = second?.value.1 ?? #imageLiteral(resourceName: "Screw Jack.png")
      
      
      
      if cache.map({ $0.name }).contains(name) {
        let nodeIndex = cache.index(where: { (candidate) -> Bool in
          candidate.name == name
        })!
        let nodeToClone = cache[nodeIndex]
        node = nodeToClone.copy() as! SKSpriteNode
      }
      else {
        node = SKSpriteNode(texture: SKTexture(image:image))
        cache.append(node)
      }
      
      let twometer : CGFloat = 2.00/1.6476
      //let scale = self.scale + twometer
      node.setScale( twometer)
      node.position = (line.line.start+line.line.end).center  * scale
      node.zRotation = CGFloat(line.line.start.x == line.line.end.x ? CGFloat.halfPi : 0)
      scene!.addChild(node)
      node.name = name
      return node
    }
    fatalError()
  }
  
  var cache : [SKSpriteNode] = []
  
  // ...SceneKit Handlering
  
  
  
  // Viewcontroller Functions

  
}
