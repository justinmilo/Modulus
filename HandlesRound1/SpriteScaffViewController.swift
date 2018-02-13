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
  var editingView : GraphEditingView
  var loadedViews : [GraphEditingView]
  
  init(graph: ScaffGraph, mapping: [GraphEditingView] )
  {
    self.graph = graph
    self.twoDView = Sprite2DView(frame: UIScreen.main.bounds)
    self.handleView = HandleViewRound1(frame: UIScreen.main.bounds, state: .edge)
    
    self.editingView = mapping[0]
    self.loadedViews = mapping
    
    super.init(nibName: nil, bundle: nil)
  }
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  

  override func viewDidAppear(_ animated: Bool) {
    // Set view upon initial loading
    buildFromScratch()
  }
  
  func buildFromScratch()
  {
    let size = self.graph |> self.editingView.size
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
      (self.graph.grid, self.graph.edges) = (master.size |> self.editingView.build)
      let size = self.graph |> self.editingView.size
      let newRect = (master, size, positions) |> bindSize
      
      self.draw(in: newRect)
    }
    
    self.handleView.completed = {
      master, positions in
      // Create New Model
      (self.graph.grid, self.graph.edges) = (master.size |> self.editingView.build)
      let size = self.graph |> self.editingView.size
      let  newRect = (master, size, positions) |> bindSize
      
      self.handleView.set(master: newRect )
    }
    
  }
  
  
  
  func draw(in newRect: CGRect) {
    // Create New Model &  // Find Orirgin
    let origin = (self.graph, newRect, self.twoDView.bounds.height) |> self.editingView.origin
    
    // Create Geometry
    let b = origin |> (self.graph |> self.editingView.composite)
    
    // Set & Redraw Geometry
    self.twoDView.redraw( b )
  }
  
  
  

  private var swapIndex = 0
  @objc func swapControl()
  {
    swapIndex = swapIndex+1 >= loadedViews.count ? 0 : swapIndex+1
    self.editingView = loadedViews[swapIndex]
    
    buildFromScratch()
  }
  
}
