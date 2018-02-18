//
//  TexturedView+SKSpriteNode.swift
//  HandlesRound1
//
//  Created by Justin Smith on 2/18/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import CoreGraphics
import SpriteKit

func createCachedSpriteKitNode(line:TextureLine, cache: [SKSpriteNode]) -> (SKSpriteNode, [SKSpriteNode])
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
  
  var tmpCache = cache
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
    tmpCache.append(node)
  }
  
  node.setScale( 2.00/1.6476)
  node.position = node.position + ( adjujstmentV *  2.00/1.6476)
  node.name = name
  return (node, tmpCache)
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
func grabFromCacheOrCreate(name:String, imageName: String, cache: [SKSpriteNode]) -> (SKSpriteNode, [SKSpriteNode])
{
  let node: SKSpriteNode
  var tmpCache = cache
  let optNode = cache.first( where: { $0.name == name })
  if let real = optNode {
    node = real.copy() as! SKSpriteNode
  }
  else {
    let image = UIImage(named: imageName)
    node = SKSpriteNode(texture: SKTexture(image:image!))
    tmpCache.append(node)
    node.name = name
  }
  return (node, tmpCache)
}




