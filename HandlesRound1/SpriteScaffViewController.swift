//
//  TestViewController.swift
//  HandlesRound1
//
//  Created by Justin Smith on 1/27/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit


class SpriteScaffViewController : UIViewController {
  
  let rectangle = CGRect(x: 120, y: 140, width: 200, height: 200)
  let scaleFactor : CGFloat = 1.0
  
  var twoDView : Sprite2DView
  var handleView : HandleViewRound1
  
  override func loadView() {
    
    view = UIView()
    view.addGestureRecognizer(UITapGestureRecognizer(target: twoDView, action: #selector(Sprite2DView.tapped)))
    
    let boundingGrips = self.handleView
    boundingGrips.isExclusiveTouch = false
    
    boundingGrips.handler =    {  master, positions in
      // Scale
      let (grid, rect) = self.foo(master: master)
      let aligned = master.withInsetRect( ofSize: rect.size, hugging: (positions.0.oposite, positions.1.oposite))
      
      // "layout" my subview grid, witha model2d
      self.twoDView.scale = 1/self.scaleFactor
      let model = NonuniformModel2D(origin: aligned.origin, rowSizes: grid.y, colSizes: grid.x)
      let geometries = CEverything().geometries(model: model, scale: 1/self.scaleFactor, bounds: self.view.frame)
      self.twoDView.geometries = [geometries]
      self.twoDView.redraw( self.twoDView.index )
    }
    
    boundingGrips.completed = {  master, positions in
      let (_, rect) = self.foo(master: master)
      let aligned = master.withInsetRect( ofSize: rect.size, hugging:  (positions.0.oposite, positions.1.oposite))
      boundingGrips.set(master: aligned )
    }
    for v in [twoDView, boundingGrips]{ self.view.addSubview(v) }
  }
  
  
  init()
  {
    twoDView = Sprite2DView()
    
    self.handleView = HandleViewRound1(frame: UIScreen.main.bounds, state: .edge)

    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // Plan and target rect based on a Rect
  func foo(master: CGRect) -> (PlanModel, CGRect)
  {
    let scaledMasterSize = master.size * self.scaleFactor
    
    // Find appropriate model
    let x111 = maximizedGrid(availableInventory:[100,150,200], lessThan: scaledMasterSize)
    let grid = PlanModel(
      x: Grid(x111.x),
      y: Grid(x111.y)
    )
    
    // Find appropriate model scaled
    let x222 = CGSize(
      width: Grid(x111.x).sum / self.scaleFactor,
      height: Grid(x111.y).sum / self.scaleFactor
    )
    
    return (grid, CGRect(origin: master.origin, size: x222))
  }
  
}
