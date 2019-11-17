//
//  Scaff2D->SKNode.swift
//  Deploy
//
//  Created by Justin Smith on 11/22/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation

import SpriteKit
import Make2D
import Graphe
import BlackCricket
import Singalong
import Geo

let twometer : CGFloat = 2.00/1.6476

//TODO - FixMe If there are no images to load the whole program crashes
private func firstHalf( item: Scaff2D, cache : inout [SKSpriteNode]) -> SKSpriteNode? {
  let name = nameHash(item)
  let copy = copyFromCache(name: name, cache: cache)
  guard copy == nil else { return (copy!) }
  
  let imageGenny :()->UIImage? = {
    let length = CGSegment(p1:item.start, p2:item.end).length
    let path = (length, item.part, item.view) |> imageName
    let bundle = Bundle(for: ViewController.self)
    //TODO - FixMe If there are no images to load the whole program crashes
    guard let apath = path, let aImage = UIImage(named: apath, in: bundle, compatibleWith: nil) else {
      return nil
    }
    return aImage
  }
  guard let image = imageGenny() else { return nil }
  
  let (ledgerNode, newCache) = addToCache(name: name, imageGen: image , cache: cache)
  ledgerNode.setScale(twometer)
  cache = newCache
  return ledgerNode
}


func convertNOROTGeneral ( item: Scaff2D, cache : inout [SKSpriteNode]) -> SKSpriteNode? {
  guard let ledgerNode : SKSpriteNode = firstHalf(item: item, cache: &cache) else { return nil }
  ledgerNode.position = (item.start + item.end).center
  return ledgerNode
}




func convertDynamicLedger ( item: Scaff2D, imageGenny: (CGFloat)->UIImage,  cache : inout [SKSpriteNode]) -> SKSpriteNode {
  precondition(item.part == .ledger)
  
  let name = nameHash(item)
  let copy = copyFromCache(name: name, cache: cache)
  guard copy == nil else { return (copy!) }
  
  
  let length = CGSegment(p1:item.start, p2:item.end).length
  let image = imageGenny(length*10)
  
  
  let (ledgerNode, newCache) = addToCache(name: name, imageGen: image, cache: cache)
  cache = newCache
  
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
  
  let (ledgerNode, newCache) = addToCache(name: name, imageGen: imageGenny() , cache: cache)
  cache = newCache
  
  return ledgerNode
}


func createScaff2DNode (item: Scaff2D, cache: inout [SKSpriteNode]) -> SKNode?
{
  switch (item.part,  item.view) {
  // Plan View
  case (.jack,  .plan): return nil
  case (.basecollar, .plan): return nil
  case (.ledger, .plan),
       (.standard,  .plan),
       (.diag, .plan):
    
    //TODO - FixMe If there are no images to load the whole program crashes
    // Because the program loads a standard in convertDynamicLedger
    let node : SKNode
    if let ledgerNode = firstHalf(item: item, cache: &cache) {
      node = ledgerNode
    }
    else {
      let dyn = convertDynamicLedger(item: item, imageGenny: ledgerPlanImage, cache: &cache)
      dyn.setScale( twometer/3)
      node = dyn
    }
    node.position = (item.start + item.end).center
    node.zRotation = CGFloat(item.start.x == item.end.x ? CGFloat.halfPi : 0)
    return node
    
  // Ledger - Cross & Longitudinal
  case (.ledger, .longitudinal),
       (.ledger, .cross):
    if let node = convertNOROTGeneral(item: item, cache:&cache) {
      let adjujstmentV = CGVector(0, -1.44) * (2.00/1.6476)
      node.position = node.position + adjujstmentV
      return node
    }
    else {
      let node = convertDynamicLedger(item: item, imageGenny: ledgerLongitudinalImage, cache: &cache)
      node.setScale( twometer/3)
      node.position = (item.start + item.end).center + unitY * -2 + unitX * 1
      return node
    }
  
  // Diag - Longitudinal
  case (.diag, .longitudinal):
    let node = convertDynamic(item: item, cache:&cache)
    
    node.setScale( twometer/3)
    //node.xScale = item.upToTheRight == true ? node.xScale :  -node.xScale
    node.position = (item.start + item.end).center + unitY * -2 + unitX * 1
    
    return node
  
  // Diag - Cross
  case (.diag, .cross):
    let cgPath = CGMutablePath()
    cgPath.move(to: item.start)
    cgPath.addLine(to: item.end)
    let node = SKShapeNode(path: cgPath)
    return node
    
  case (.standard,  .longitudinal),
       (.standard,  .cross):
    
    let node = convertNOROTGeneral(item: item, cache:&cache)!
    let adjujstmentV = CGVector(0, 8.64) * (2.00/1.6476)
    node.position = node.position + adjujstmentV
    return node
    
  // Jack - Cross & Longitudinal
  case (.jack,  .longitudinal),
       (.jack,  .cross):
    let node = convertNOROTGeneral(item: item, cache:&cache)!
    let     adjujstmentV = CGVector(0, 0) * (2.00/1.6476)
    node.position = node.position + adjujstmentV
    return node
    
  // Collars - Cross & Longitudinal
  case (.basecollar, .longitudinal),
       (.basecollar, .cross):
    let node = convertNOROTGeneral(item: item, cache:&cache)!
    let     adjujstmentV = CGVector(0, 4.74) * (2.00/1.6476)
    node.position = node.position + adjujstmentV
    return node
    
  }
}
