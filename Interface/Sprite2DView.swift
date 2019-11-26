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
public protocol CacheRepresentable {
  func node(pool: inout [SKSpriteNode]) -> SKNode?
}




// Used to be view controller
/// Geometry View
public class Sprite2DView : SKView {
  
  var mainNode : SKNode
  var cache : [SKSpriteNode] = []
  var scale : CGFloat = 1.0 {
    didSet {
      self.mainNode.xScale = scale
      self.mainNode.yScale = scale
    }
  }
  
  override init(frame: CGRect) {
    mainNode = SKNode()
    super.init(frame: frame)
    
    // Specialtiy SpriteKitScene
    let aScene = SKScene(size: frame.size)
    aScene.addChild(mainNode)
    self.presentScene(aScene)
    self.scene?.scaleMode = .resizeFill
    self.ignoresSiblingOrder = true
  }
  
  
  
  required init?(coder aDecoder: NSCoder) { fatalError() }
  
  func redraw(_ g:Composite) {
    self.mainNode.removeAllChildren()
    
    for geo in g.geometry {
      self.addChildR(geo)
    }
    for label in g.labels {
      self.addChildR(label)
    }
  }
  
  // SceneKit Handlering...
  // put on the canvas!!
  func addChildR<T>(_ erased: T) {
    switch erased {
    
    case let someRep as SKRepresentable:
      mainNode.addChild(someRep.asNode)
    
    case let line as CacheRepresentable:
      if let n = line.node(pool: &self.cache) {
        mainNode.addChild(n)
      }
    default:
      fatalError()
    }
  }
  
}

extension Sprite2DView {
  func addTempRect( rect: CGRect, color: UIColor) {
    let globalLabel = SKShapeNode(rect: rect )
    globalLabel.fillColor = color
    self.scene?.addChild(globalLabel)
    globalLabel.alpha = 0.0
    let fadeInOut = SKAction.sequence([
      .fadeAlpha(to: 0.3, duration: 0.2),
      .fadeAlpha(to: 0.0,duration: 0.4)])
    globalLabel.run(fadeInOut, completion: {

    })
  }
  
}

