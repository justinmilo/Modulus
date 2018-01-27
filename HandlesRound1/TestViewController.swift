//
//  TestViewController.swift
//  HandlesRound1
//
//  Created by Justin Smith on 1/27/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit


class TestViewController : UIViewController {
  
  let rectangle = CGRect(x: 120, y: 140, width: 200, height: 200)
  
  override func loadView() {
    view = UIView()
    
    let twoDView = Sprite2DGraph(model: Model2D(origin: rectangle.origin, dx: rectangle.width, dy: rectangle.height, col: 2, rows: 2))
    
    
    let box = HandleViewRound1(frame:view.bounds, state: .edge)
    box.handler =    {
      master in
      // Scale
      let scaleFactor : CGFloat = 3.0
      let scaledMasterSize = master.size * scaleFactor
      
      // Find appropriate model
      let x111 = maximizedGrid(availableInventory:[200], lessThan: scaledMasterSize)
      let grid = PlanModel(x: Grid(x111.x), y: Grid(x111.y))
      //twoMeterModel(targetSize: scaledMaster.size)
      
      // "layout" my subview grid, witha model2d
      twoDView.scale = 1/scaleFactor
      twoDView.model = NonuniformModel2D(origin: master.origin, rowSizes: grid.y, colSizes: grid.x)
      
    
      
      
    }
    box.completed = {
      master in
      // Scale
      let scaleFactor : CGFloat = 3.0
      let scaledMasterSize = master.size * scaleFactor
      
      // Find appropriate model
      let x222 = CGSize(width:
        Grid(maximizedGrid(availableInventory:[200], lessThan: scaledMasterSize)
          .x).sum / scaleFactor,
                        height:
        Grid(maximizedGrid(availableInventory:[200], lessThan: scaledMasterSize).y).sum / scaleFactor)
      
      box.set(master: CGRect(origin: master.origin, size: x222) )
    }
    
    for v in [twoDView, box]{ self.view.addSubview(v) }
    
  }
  
}
