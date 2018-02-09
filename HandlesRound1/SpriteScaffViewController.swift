//
//  TestViewController.swift
//  HandlesRound1
//
//  Created by Justin Smith on 1/27/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit

func originSwap(origin: CGRect, height: CGFloat) -> CGPoint
{
  return CGPoint(origin.x, height - origin.y - origin.height)
}


let add3rdDim : (CGSize) -> CGSize3 = {
  return CGSize3(width: $0.width, depth: 400, elev : $0.height)
}
let remove3rdDim : (CGSize3) -> CGSize = {
  return CGSize(width: $0.width, height:  $0.elev)
}

func bindSize( master: CGRect, scaffSize: CGSize, positions: (VerticalPosition, HorizontalPosition)) -> (CGRect)
{
  // Find Orirgin
  let aligned = master.withInsetRect( ofSize: scaffSize, hugging:  (positions.0.oposite, positions.1.oposite))
  
  return (aligned)
}

let findOrigin : (CGPoint, CGFloat) -> (CGPoint) = {
  aligned, adapterHeight in

  let offsetFromScrewJack = aligned + unitY * adapterHeight
  return offsetFromScrewJack
}

let fullScaff : (CGSize) -> ScaffGraph = add3rdDim >>> createScaffolding
let gridScaff : (CGSize) -> ScaffGraph = add3rdDim >>> createGrid
let sizeFromGridScaff : (ScaffGraph) -> CGSize = { $0.boundsOfGrid.0 } >>> remove3rdDim
let sizeFromFullScaff : (ScaffGraph) -> CGSize = { $0.bounds } >>> remove3rdDim

let originFromGridScaff : (ScaffGraph, CGRect, (VerticalPosition, HorizontalPosition), CGFloat) -> CGPoint =
{ (graph, master, positions, boundsHeight) in
  // Find Orirgin
  let size = graph |> sizeFromGridScaff
  let newRect = (master, size, positions) |> bindSize
  var origin = (newRect, boundsHeight) |> originSwap
  origin = ((origin, graph.boundsOfGrid.1)  |>  findOrigin)
  return origin
}
let originFromFullScaff : (ScaffGraph, CGRect, (VerticalPosition, HorizontalPosition), CGFloat) -> CGPoint =
{ (graph, master, positions, boundsHeight) in
  // Find Orirgin
  let size = graph |> sizeFromFullScaff
  let newRect = (master, size, positions) |> bindSize
  var origin = (newRect, boundsHeight) |> originSwap
  return origin
}



class SpriteScaffViewController : UIViewController {
  
  var twoDView : Sprite2DView
  var handleView : HandleViewRound1
  var graph : ScaffGraph
  

  
  var create : (CGSize) -> ScaffGraph
  var size : (ScaffGraph) -> CGSize
  var mangleOrigin : (ScaffGraph, CGRect, (VerticalPosition, HorizontalPosition), CGFloat) -> CGPoint
 
  override func loadView() {
    
    view = UIView()
    view.addGestureRecognizer(UITapGestureRecognizer(target: twoDView, action: #selector(Sprite2DView.tapped)))
    
    let button = UIButton(type: .system)
    button.setTitle("Swap", for: .normal)
    button.addTarget(self, action: #selector(SpriteScaffViewController.swapControl), for: UIControlEvents.touchUpInside)
    button.frame = CGRect(20,20, 100,50)
   
    
    self.handleView.handler =    {
      master, positions in
       // Create New Model &  // Find Orirgin
      self.graph = (master.size |> self.create)
      let origin = (self.graph, master, positions, self.twoDView.bounds.height) |> self.mangleOrigin
      
      // Create Geometry
      let g = (self.graph.frontEdgesNoZeros, origin) |> modelToLinework
      let b = (self.graph.frontEdgesNoZeros, origin) |> modelToTexturesElev
      
      // Set & Redraw Geometry
      self.twoDView.geometries = [[g], [b]]
      self.twoDView.redraw( self.twoDView.index )
    }
    
    self.handleView.completed = {
      master, positions in
      // Create New Model
      self.graph = (master.size |> self.create)
      let size = self.graph |> self.size
      
      let  newRect = (master, size, positions) |> bindSize
      self.handleView.set(master: newRect )
    }
    for v in [twoDView, handleView, button]{ self.view.addSubview(v) }
  }
  
  
  init()
  {
    twoDView = Sprite2DView(frame: UIScreen.main.bounds)
    self.graph = (CGSize3(width: 150, depth: 150, elev: 820) |> createScaffolding)
    self.handleView = HandleViewRound1(frame: UIScreen.main.bounds, state: .edge)
    
    self.create = fullScaff
    self.size = sizeFromFullScaff
    self.mangleOrigin = originFromFullScaff
    
    super.init(nibName: nil, bundle: nil)
  }

  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private var bool = true
  @objc func swapControl()
  {
    if (!bool) {
      self.create = fullScaff
      self.size = sizeFromFullScaff
      self.mangleOrigin = originFromFullScaff
    }
    else {
      self.create = gridScaff
      self.size = sizeFromGridScaff
      self.mangleOrigin = originFromGridScaff
    }
    bool = !bool
    
    
    let size = self.graph |> self.size
    let newRect = CGRect(origin: self.handleView.lastMaster.origin, size:size)
    self.handleView.set(master: newRect )
  }
  
}
