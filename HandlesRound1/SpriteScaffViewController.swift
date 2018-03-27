//
//  TestViewController.swift
//  HandlesRound1
//
//  Created by Justin Smith on 1/27/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit








import SpriteKit







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
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SpriteScaffViewController.tap)))
    
    for v in [twoDView, handleView]{ self.view.addSubview(v) }
    
    self.handleView.handler =    {
      master, positions in
       // Create New Model &  // Find Orirgin
      (self.graph.grid, self.graph.edges) = (master.size, self.graph.edges) |> self.editingView.build
      let size = self.graph |> self.editingView.size
      let newRect = (master, size, positions) |> bindSize
      
      self.draw(in: newRect)
    }
    
    self.handleView.completed = {
      master, positions in
      // Create New Model
      (self.graph.grid, self.graph.edges) = (master.size, self.graph.edges) |> self.editingView.build
      let size = self.graph |> self.editingView.size
      let  newRect = (master, size, positions) |> bindSize
      
      self.handleView.set(master: newRect )
    }
    
  }
  
  
  
  func draw(in newRect: CGRect) {
    // Create New Model &  // Find Orirgin
    let origin = (self.graph, newRect, self.twoDView.bounds.height) |> self.editingView.origin
    
    // Create Geometry
    let moop : ([Geometry]) -> [Geometry] = move(by:origin.asVector()) |> curry(map)
    let b = self.graph |> self.editingView.composite >>> moop
    
    // Set & Redraw Geometry
    self.twoDView.redraw( b )
  }
  
  
  

  
  @objc func tap(g: UIGestureRecognizer)
  {
    // if insideTGyg`1``1`q`1q`q1
    if self.handleView.lastMaster.contains(
      g.location(ofTouch: 0, in: self.view)
    ) {
      highlightCell(touch: g.location(ofTouch: 0, in: self.view))
    }
    else {
      changeCompositeStyle()
    }
  }
  
  private var swapIndex = 0
  func changeCompositeStyle ()
  {
    swapIndex = swapIndex+1 >= loadedViews.count ? 0 : swapIndex+1
    self.editingView = loadedViews[swapIndex]
    buildFromScratch()
  }
  
  private var swapIndex2 = 0
  func highlightCell (touch: CGPoint) {
    
    
    
    // bind values to these functions
    let rectToSprite = self.twoDView.bounds.height |> curry(uiToSprite(height:rect:))
    let pointToSprite = self.twoDView.bounds.height |> curry(uiToSprite(height:point:))
    let yToSprite = self.twoDView.bounds.height |> curry(uiToSprite(height:y:))
    

    // Properly Controllers concern
    let tS = touch |> pointToSprite
    let rectS = self.handleView.lastMaster |> rectToSprite
    let p = (tS, rectS) |> viewSpaceToModelSpace
    
    // Properly models concern
    let editBoundaries = self.graph |> editingView.parseEditBoundaries ///
    let toGridIndices = editBoundaries |> curry(pointToGridIndices) >>>  handleTupleOptionWith
    
    // Get Model Indices
    let indices = (p |> toGridIndices)
    // c is something lik (0, 1)
    // or (1, 2)
    
    
    // Get Model Rect
    let mRect = (indices, editBoundaries) |> modelRect
    // x is something like (0.0, 30.0, 100.0, 100.0)
    // (0.0, 0.0, 100.0, 30.0)

    // bring model rect into the real world!
    let z = (mRect, self.handleView.lastMaster.origin.asVector()) |> moveByVector
    let cellRectValue = z |> rectToSprite
    let y = self.handleView.lastMaster.midY |> yToSprite
    let flippedRect = (cellRectValue, y )  |> mirrorVertically
    // flipped rect is situated in sprite kit space
    
    
    // Handle the 2D to 3D conversion
    let mapFrontIndicesToY : (PointIndex2D, Int) -> [PointIndex] =
    { (p,max) in
      return  (0..<max).map{ (p.x, $0, p.y)}
    }
    // bind for all pY.Count
    let boundFront = graph.grid.pY.count |> flip(curry(mapFrontIndicesToY))
    // get all diags at touch
    let diagsAtTouch = filterDiagsWithBayIndex(edges: self.graph.edges, bayIndex: indices)
    
    // start the switch around what the previoous diag value was
    if diagsAtTouch.count == 0
    {
      let reducedEdges = self.graph.edges.filter { !diagsAtTouch.contains($0) }
      let (p1x, p2x) = lowToHigh(gIndex: indices)
      let items = zip(p1x |> boundFront, p2x |> boundFront).map{
        return Edge(content: "Diag", p1: $0.0, p2: $0.1)
      }
      self.graph.edges = reducedEdges + items
    }
    else if let sampleDiag = diagsAtTouch.first, edgeXDiagUp.call(sampleDiag)
    {
      let reducedEdges = self.graph.edges.filter { !diagsAtTouch.contains($0) }
      let (p1x, p2x) = highToLow(gIndex: indices)
      let items = zip(p1x |> boundFront, p2x |> boundFront).map{
        return Edge(content: "Diag", p1: $0.0, p2: $0.1)
      }
      self.graph.edges = reducedEdges + items
    }
    else if let sampleDiag = diagsAtTouch.first, edgeXDiagDown.call(sampleDiag)
    {
      let reducedEdges = self.graph.edges.filter { !diagsAtTouch.contains($0) }
      
      self.graph.edges = reducedEdges
    }
    
    
    buildFromScratch()
    addTempRect(rect: flippedRect, color: .white)
  }
  
  
  func addTempRect( rect: CGRect, color: UIColor) {
    let globalLabel = SKShapeNode(rect: rect )
    globalLabel.fillColor = color
    self.twoDView.scene?.addChild(globalLabel)
    globalLabel.alpha = 0.0
    let fadeInOut = SKAction.sequence([
      .fadeAlpha(to: 0.3, duration: 0.2),
      .fadeAlpha(to: 0.0,duration: 0.4)])
    globalLabel.run(fadeInOut, completion: {
      print("End and Fade Out")
    })
  }
}

typealias PointIndex2D = (x:Int, y:Int)

