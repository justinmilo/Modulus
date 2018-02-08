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

func finalRectFrom( master: CGRect, positions: (VerticalPosition, HorizontalPosition)) -> (ScaffGraph, CGRect)
{
  let graph = (master.size |> add3rdDim |> createGrid)
  // Find Orirgin
  let scaffSize = graph.boundsOfGrid.0 |> remove3rdDim
  let aligned = master.withInsetRect( ofSize: scaffSize, hugging:  (positions.0.oposite, positions.1.oposite))
  
  return (graph, aligned)
}


class SpriteScaffViewController : UIViewController {
  
  var twoDView : Sprite2DView
  var handleView : HandleViewRound1
  var graph : ScaffGraph
  
  let add3rdDim : (CGSize) -> CGSize3 = {
    return CGSize3(width: $0.width, depth: 400, elev : $0.height)
  }
  let remove3rdDim : (CGSize3) -> CGSize = {
    return CGSize(width: $0.width, height:  $0.elev)
  }
  
  override func loadView() {
    
    view = UIView()
    view.addGestureRecognizer(UITapGestureRecognizer(target: twoDView, action: #selector(Sprite2DView.tapped)))
    
    self.handleView.handler =    {
      master, positions in
       // Create New Model
      self.graph = (master.size |> self.add3rdDim |> createGrid)
      // Find Orirgin
      let scaffSize = self.graph.boundsOfGrid.0 |> self.remove3rdDim
      let aligned = master.withInsetRect( ofSize: scaffSize, hugging: (positions.0.oposite, positions.1.oposite))
      let swappedOrigin = (aligned, self.twoDView.bounds.height) |> originSwap
      let offsetFromScrewJack = swappedOrigin + unitY * self.graph.boundsOfGrid.1
      
      // Create Geometry
      let g = (self.graph.frontEdgesNoZeros, offsetFromScrewJack) |> modelToLinework
      let b = (self.graph.frontEdgesNoZeros, offsetFromScrewJack) |> modelToTexturesElev
      
      // Set & Redraw Geometry
      self.twoDView.geometries = [[g], [b]]
      self.twoDView.redraw( self.twoDView.index )
    }
    
    self.handleView.completed = {
      master, positions in
      // Create New Model
      let (graph, newRect) = (master, positions) |> finalRectFrom
      self.graph = graph
      self.handleView.set(master: newRect )
    }
    for v in [twoDView, handleView]{ self.view.addSubview(v) }
  }
  
  
  init()
  {
    twoDView = Sprite2DView(frame: UIScreen.main.bounds)
    self.graph = (CGSize3(width: 150, depth: 150, elev: 820) |> createScaffolding)
    self.handleView = HandleViewRound1(frame: UIScreen.main.bounds, state: .edge)
    super.init(nibName: nil, bundle: nil)
  }

  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  

  
}
