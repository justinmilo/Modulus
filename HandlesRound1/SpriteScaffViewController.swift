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
    
    let c = (p |> toGridIndices)
    // c is something lik (0, 1)
    // or (1, 2)
    let x = (c, editBoundaries) |> modelRect
    // x is something like (0.0, 30.0, 100.0, 100.0)
    // (0.0, 0.0, 100.0, 30.0)
    print(c)
    print(x)
    
    let z = (x, self.handleView.lastMaster.origin.asVector()) |> moveByVector
    let cellRectValue = z |> rectToSprite
    let y = self.handleView.lastMaster.midY |> yToSprite
    let flippedRect = (cellRectValue, y )  |> mirrorVertically
    
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
    
    let boundOrigin = self.handleView.lastMaster.origin.asVector() |> flip(moveByVectorCurried) >>> pointToSprite
    let boundMirror = y |> flip(curry(mirrorVertically(point:along:)))
   
    let cHey = curry(indicesToPositions)
    let boundPositions = editBoundaries |> cHey
    let finalT = boundPositions >>> CGPoint.init(x:y:) >>> boundOrigin >>> boundMirror
    
    let (p1, p2) = lowToHigh(gIndex: c)
    let line = (p1 |> finalT, p2 |> finalT) |> Line.init
    let (p1x, p2x) = highToLow(gIndex: c)
    let line2 = (p1x |> finalT, p2x |> finalT) |> Line.init
    
    
    let boundContains = self.graph.edges |> curry(contains(edges:new:))
    let boundAdd = self.graph.edges |> curry(add(edges:new:))
    
    
    let frontPoint2Dto3D : (PointIndex2D, Int) -> [PointIndex] = { (p,max) in
      return  (0..<max).map{ (p.x, p.y, $0)}
    }
    let boundFront = graph.grid.pY.count |> flip(curry(frontPoint2Dto3D))
    
    let items = zip(p1 |> boundFront, p2 |> boundFront).map{
      return Edge(content: "Diag", p1: $0.0, p2: $0.1)
    }
    self.graph.edges = self.graph.edges + items
    

    addTempRect(rect: flippedRect, color: .white)
    self.twoDView.addChildR(line)
    
  }
  
}

typealias PointIndex2D = (x:Int, y:Int)

