//
//  TexturedView+SKSpriteNode.swift
//  HandlesRound1
//
//  Created by Justin Smith on 2/18/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import CoreGraphics
import SpriteKit


let descriptionScaff : (Scaff2D.ScaffType) -> String =
{ type in
  switch type {
  case .ledger: return "Ledger"
  case .jack: return "Jack"
  case .standard: return "Standard"
  case .basecollar: return "Basecollar"
  case .diag:
    return "Diag"
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
  switch ($0.rounded(places:0), $1, $2)
  {
  case (50, .ledger, .plan): return "0.5m Plan"
  case (100, .ledger, .plan): return "1m plan"
  case (150, .ledger, .plan): return "1.5m Plan"
  case (200, .ledger, .plan): return "2.0m plan"
  case (0, .standard, .plan): return "Std Plan"
  case (50, .ledger, .longitudinal): return "0.5m"
  case (100, .ledger, .longitudinal): return "1m"
  case (150, .ledger, .longitudinal): return "1.5m"
  case (200, .ledger, .longitudinal): return "2m"
  case (100, .standard, .longitudinal): return "2.0m Std"
  case (50, .standard, .longitudinal): return "0.5m Std"
  case (_, .basecollar, .longitudinal): return "Base Collar"
  case (_, .jack, .longitudinal): return "Screw Jack"
  default:
    print( $0, $1, $2 )
    print( "AND NOTHING COMING UP!!")
    return nil
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




