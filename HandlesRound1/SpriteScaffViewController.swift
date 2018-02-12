//
//  TestViewController.swift
//  HandlesRound1
//
//  Created by Justin Smith on 1/27/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit
















class SpriteScaffViewController : UIViewController {
  // View and Model
  var twoDView : Sprite2DView
  var handleView : HandleViewRound1
  let graph : ScaffGraph
  
  // Drawing pure function
  var f_flattenGraph: (ScaffGraph) -> [C2Edge]
  var f_edgesToTexture: ([C2Edge], CGPoint) -> [Geometry]
  

  // HandleView Pure Handle Sizing Functios
  var create : (CGSize) -> (GraphPositions, [Edge])
  var f_graph2DSize : (ScaffGraph) -> CGSize
  var mangleOrigin : (ScaffGraph, CGRect, CGFloat) -> CGPoint
  
  
  init(graph: ScaffGraph, mapping: GraphMapping )
  {
    
    self.graph = graph
    self.twoDView = Sprite2DView(frame: UIScreen.main.bounds)
    self.handleView = HandleViewRound1(frame: UIScreen.main.bounds, state: .edge)
    
    self.f_edgesToTexture = mapping.f_edgesToTexture
    self.f_flattenGraph = mapping.f_flattenGraph
    
    self.create = mapping.f_sizeToGraph
    self.f_graph2DSize = mapping.f_graphToSize
    self.mangleOrigin = originFromFullScaff
    
    super.init(nibName: nil, bundle: nil)
  }
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  

  override func viewDidAppear(_ animated: Bool) {
    // Set view upon initial loading
    let size = self.graph |> self.f_graph2DSize
    let newRect = self.view.bounds.withInsetRect(ofSize: size, hugging: (.center, .center))
    self.handleView.set(master: newRect)
    self.draw(in: newRect)
  }
  
  
  override func loadView() {
    view = UIView()
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SpriteScaffViewController.swapControl)))
    
    for v in [twoDView, handleView]{ self.view.addSubview(v) }
    
    self.handleView.handler =    {
      master, positions in
       // Create New Model &  // Find Orirgin
      (self.graph.grid, self.graph.edges) = (master.size |> self.create)
      let size = self.graph |> self.f_graph2DSize
      let newRect = (master, size, positions) |> bindSize
      
      self.draw(in: newRect)
    }
    
    self.handleView.completed = {
      master, positions in
      // Create New Model
      (self.graph.grid, self.graph.edges) = (master.size |> self.create)
      let size = self.graph |> self.f_graph2DSize
      let  newRect = (master, size, positions) |> bindSize
      
      self.handleView.set(master: newRect )
    }
    
  }
  
  
  
  func draw(in newRect: CGRect) {
    // Create New Model &  // Find Orirgin
    let origin = (self.graph, newRect, self.twoDView.bounds.height) |> self.mangleOrigin
    
    // Create Geometry
    let b = (self.graph |> self.f_flattenGraph, origin) |> self.f_edgesToTexture
    let g = (self.graph |> self.f_flattenGraph, origin) |> modelToLinework
    
    // Set & Redraw Geometry
    self.twoDView.geometries = [[b],[g]]
    self.twoDView.redraw( self.twoDView.index )
  }
  
  struct ModalView {
    let modelToGeometry : ([C2Edge], CGPoint) -> [Geometry]
    let build: (CGSize) -> (GraphPositions, [Edge])
    let flattenSize : (ScaffGraph) -> CGSize
    let mangleOrigin : (ScaffGraph, CGRect, CGFloat) -> CGPoint
  }
  

  private var bool = true
  @objc func swapControl()
  {
    self.twoDView.tapped()
    
    if (!bool) {
      self.create = fullScaff
      self.f_graph2DSize = sizeFromFullScaff
      self.mangleOrigin = originFromFullScaff
    }
    else {
      self.create = gridScaff
      self.f_graph2DSize = sizeFromGridScaff
      self.mangleOrigin = originFromGridScaff
    }
    bool = !bool
    
    
    let size = self.graph |> self.f_graph2DSize
    
    let newRect = CGRect(origin: self.handleView.lastMaster.origin, size:size)
    self.handleView.set(master: newRect )
  }
  
}
