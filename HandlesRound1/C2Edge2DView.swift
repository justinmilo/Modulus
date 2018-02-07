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

class C2Edge2DView {
  
  
  //  func modelToPlanGeometry ( edges: [C2Edge]) -> [Geometry]
  //  {
  //    fatalError("Some other type showed up")
  //
  //    return edges.map { edge in
  //
  //      switch edge.content
  //      {
  //      case "Standards": break
  //      case "Jack" : break
  //      case "Ledger" : break
  //      case "BC" : break
  //
  //      default :
  //        fatalError("Some other type showed up")
  //      }
  //
  //    }
  //  }
  
  func modelToLinework ( edges: [C2Edge]) -> [Geometry]
  {
    let lines : [Geometry] = edges.map { edge in
      return Line(start: edge.p1, end: edge.p2)
    }
    
    let labels = edges.map { edge -> Label in
      
      let direction : Label.Rotation = edge.content == "Ledger" || edge.content == "Diag" ? .h : .v
      let vector = direction == .h ? unitY * 10 : unitX * 10
      return Label(text: edge.content, position: (edge.p1 + edge.p2).center + vector, rotation: direction)
      
    }
    
    let labelsSecondPass : [Geometry] = labels.reduce([])
    {
      (res, geo) -> [Label] in
      
      print( res.map{ ($0.text, $0.position) }, geo.position)
      if res.contains(where: {
        
        let r = CGRect.around($0.position, size: CGSize(40,40))
        return r.contains(geo.position)
        
      })
      {
        var new = geo
        new.position = new.position + CGVector(dx: 15, dy: 15)
        return res + [new]
      }
      
      return res + [geo]
    }
    
    let thirdPass : [Geometry] = (lines + labelsSecondPass).map{
      var new = $0
      new.position = $0.position + CGVector(dx: 80, dy: 200)
      return new
    }
    
    
    
    return thirdPass
  }
  
  
  var scale : CGFloat = 1.0
  
  
  
  
  // ...SceneKit Handlering
  
  
  
  // Viewcontroller Functions
  
}
