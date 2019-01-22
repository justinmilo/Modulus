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
public class Sprite2DView : SKView {
  
  var mainNode : SKNode
  var operatingNodes : [OKNode] = []
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
    self.ignoresSiblingOrder = true
  }
  
  public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    let touch = touches.first!
    for myNode in operatingNodes {
      if myNode.contains(touch.location(in: self.mainNode)) {
        print("touched")
      }
    }
  }
  
  
  required init?(coder aDecoder: NSCoder) { fatalError() }
  
  func redraw(_ g:Composite) {
    self.mainNode.removeAllChildren()
    self.operatingNodes.removeAll()
    
    for geo in g.geometry {
      self.addChildR(geo)
    }
    for label in g.labels {
      self.addChildR(label)
    }
    for ops in g.operators {
      self.addChildR(ops)
      self.operatingNodes.append(ops.asNode)
    }
  }
  
  // SceneKit Handlering...
  // put on the canvas!!
  func addChildR<T>(_ erased: T) {
    switch erased {
    
    case let someRep as SKRepresentable:
      mainNode.addChild(someRep.asNode)
    case let someRep as OKRepresentable:
      mainNode.addChild(someRep.asNode)
    
    case let line as Scaff2D:
      if let n = createScaff2DNode(item: line, cache: &self.cache) {
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

