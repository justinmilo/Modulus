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
    print(g)
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
    
    
    if let oval = node as? Oval
    {
      createOval(oval) |> scene!.addChild
    }
    else if let label = node as? Label
    {
      let n = createLableNode(label)
      //n |> scalePosition(scale)
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
      let path = CGMutablePath()
      path.move(to: line.line.start  * scale)
      path.addLine(to: line.line.end  * scale)
      let node = SKShapeNode(path: path)
      node.lineWidth = line.strokeWidth
      node.strokeColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
      scene!.addChild(node)
    }
    else if let p = node as? LabeledPoint
    {
      let node : SKSpriteNode
      // list of assets
      let dict : [String : UIImage] = [
        "Std" : #imageLiteral(resourceName: "Std Plan.png") ]
      
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
      
      let optNode = cache.first( where: { $0.name == p.label })
      if let real = optNode {
        node = real.copy() as! SKSpriteNode
      }
      else {
        node = SKSpriteNode(texture: SKTexture(image:second))
        cache.append(node)
      }
      
      let twometer : CGFloat = 2.00/1.6476
      //let scale = self.scale + twometer
      node.setScale( twometer)
      node.position = p.position  * scale
      scene!.addChild(node)
      node.name = p.label
      
    }
    else if let line = node as? TextureLine, line.label != ""
    {
      let node : SKSpriteNode
      // list of assets
      let ledgers : [CGFloat : (String, UIImage)] = [
        50 : ("0.5m Ledger", UIImage(named: "0.5m")!),
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
      else if ( line.label ==  "base")
      {
        let foo = pts[line.label]
        adjujstmentV = CGVector(0, 4.74)
        options = [ 0.0 : (line.label, foo!)]
      }
      else if ( line.label ==  "sj")
      {
        let foo = pts[line.label]
        adjujstmentV = CGVector(0, 12.48)
        options = [ 0.0 : (line.label, foo!)]
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
      if ( line.label ==  "sj")
      {
        node.position = line.line.start * scale
      }
      node.position = node.position + ( adjujstmentV *  2.00/1.6476)
      scene!.addChild(node)
      node.name = name
    }
    
    else if let line = node as? Scaff2D
    {
      
      let newNode = convert(item: line)
      if let n = newNode { scene!.addChild(n) }
      
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
  
  
  let image : ( CGFloat, Scaff2D.ScaffType, Scaff2D.DrawingType) -> String? = {
    switch ($0, $1, $2)
    {
    case (50, .ledger, .plan): return "0.5m Plan"
    case (100, .ledger, .plan): return "1m plan"
    case (150, .ledger, .plan): return "1.5m Plan"
    case (200, .ledger, .plan): return "2.0m plan"
    case (0, .standard, .plan): return "Std Plan"
    default:  return nil
    }
  }
  
  
  
  //NOT PURE
  func grabFromCacheOrCreate(name: String, imageName: String) -> SKSpriteNode
  {
    let node: SKSpriteNode
    let optNode = cache.first( where: { $0.name == name })
    if let real = optNode {
      node = real.copy() as! SKSpriteNode
    }
    else {
      let image = UIImage(named: imageName)
      node = SKSpriteNode(texture: SKTexture(image:image!))
      cache.append(node)
      node.name = name
    }
    return node
  }
  
  
  
  
  func convertGeneral ( item: Scaff2D) -> SKSpriteNode {
    let length = CGSegment(p1:item.start, p2:item.end).length
    let name = (length, item.part, item.view) |> nameHash
    let path = (length, item.part, item.view) |> image
    let ledgerNode = (name, path!) |> grabFromCacheOrCreate
    
    let twometer : CGFloat = 2.00/1.6476
    ledgerNode.setScale( twometer)
    ledgerNode.position = (item.start + item.end).center * scale
    ledgerNode.zRotation = CGFloat(item.start.x == item.end.x ? CGFloat.halfPi : 0)
    return ledgerNode
  }
  
  func convert (item: Scaff2D) -> SKSpriteNode?
  {
    switch item.part {
    case .ledger: return convertGeneral(item: item)
    case .standard: return convertGeneral(item: item)
    case .jack: return nil
    case .basecollar: return nil
    }
  }
  
}

let descriptionScaff : (Scaff2D.ScaffType) -> String =
{ type in
  switch type {
  case .ledger: return "Ledger"
  case .jack: return "Jack"
  case .standard: return "Standard"
  case .basecollar: return "Basecollar"
  }
}
let descriptionDrawing : (Scaff2D.DrawingType) -> String =
{
  view in
  switch  view {
  case .cross: return "Cross"
  case .longitudinal: return "Longitudinal"
  case .plan: return "Plan"
  }
}

let nameHash : ( CGFloat, Scaff2D.ScaffType, Scaff2D.DrawingType)  -> String = { (float, type,view) in return "\(float),-" + ((type |> descriptionScaff) +  (view |> descriptionDrawing)) }

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
  node.verticalAlignmentMode = .center
  return node
}

func createLineShapeNode(_ line: Line) -> SKShapeNode {
let path = CGMutablePath()
path.move(to: line.start)
path.addLine(to: line.end)
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

precedencegroup Semigroup { associativity: left }
infix operator <>: Semigroup

func <><A, B: SKNode>(f:@escaping (A)->(B)->Void, g: @escaping (A)->(B)->Void) -> (A)->(B)->Void
{
  return { a in
    return f(a) <> g(a)
  }
}

func <><B: SKNode>(f:@escaping (B)->Void, g: @escaping (B)->Void) -> (B)->Void
{
  return { b in
     f(b); g(b)
  }
}




let scaleAll : (CGFloat) -> (SKNode)-> Void = scaleTransform <> scalePosition
