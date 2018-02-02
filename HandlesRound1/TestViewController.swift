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
  let scaleFactor : CGFloat = 1.0
  
  override func loadView() {
    view = UIView()

    
    let twoDView = Sprite2DGraph(model: NonuniformModel2D(origin: rectangle.origin, dx: rectangle.width, dy: rectangle.height, col: 2, rows: 2))
   
    
    let box = HandleViewRound1(frame: UIScreen.main.bounds, state: .edge)
    
    box.handler =    {  master, positions in
      // Scale
      let (grid, rect) = self.foo(master: master)
      let aligned = master.withInsetRect( ofSize: rect.size, hugging: (positions.0.oposite, positions.1.oposite))
      
      // "layout" my subview grid, witha model2d
      twoDView.scale = 1/self.scaleFactor
      twoDView.model = NonuniformModel2D(origin: aligned.origin, rowSizes: grid.y, colSizes: grid.x)
    }
    
    box.completed = {  master, positions in
      let (_, rect) = self.foo(master: master)
      let aligned = master.withInsetRect( ofSize: rect.size, hugging:  (positions.0.oposite, positions.1.oposite))
      box.set(master: aligned )
    }
    for v in [twoDView, box]{ self.view.addSubview(v) }
  }
  
  func foo(master: CGRect) -> (PlanModel, CGRect)
  {
    let scaledMasterSize = master.size * self.scaleFactor
    
    // Find appropriate model
    let x111 = maximizedGrid(availableInventory:[100,150,200], lessThan: scaledMasterSize)
    let grid = PlanModel(
      x: Grid(x111.x),
      y: Grid(x111.y)
    )
    
    // Find appropriate model
    let x222 = CGSize(
      width: Grid(x111.x).sum / self.scaleFactor,
      height: Grid(x111.y).sum / self.scaleFactor
    )
    
    return (grid, CGRect(origin: master.origin, size: x222))
  }
  
}
