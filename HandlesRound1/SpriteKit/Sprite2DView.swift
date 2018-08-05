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
    
    for item in g {
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
  func addChildR<T>(_ node: T) {
    if let representable = node as? SKRepresentable {
      representable.asNode |> mainNode.addChild
    }
    
    else if let line = node as? Scaff2D {
      
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

