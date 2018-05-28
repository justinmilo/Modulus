//
//  TestViewController.swift
//  HandlesRound1
//
//  Created by Justin Smith on 1/27/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit
import Geo
import Singalong
import GrippableView




struct Driver
{
}



import SpriteKit

class SpriteScaffViewController : UIViewController {
  // View and Model
  var twoDView : Sprite2DView!
  var canvas : CanvasViewport!
  
  
  // Drawing pure function
  var editingView : GraphEditingView
  var loadedViews : [GraphEditingView]
  
  
  // Eventually dependency injected
  var initialFrame : CGRect
  
  init(mapping: [GraphEditingView] )
  {
    
    editingView = mapping[0]
    loadedViews = mapping
    
    initialFrame = UIScreen.main.bounds
    
    super.init(nibName: nil, bundle: nil)
    
    
  }
  
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  override func viewDidAppear(_ animated: Bool) {
    // Set view upon initial loading
    buildFromScratch()
  }
  
  func buildFromScratch()
  {
    //let size = Current.graph |> self.editingView.size
    //let newRect = self.view.bounds.withInsetRect(ofSize: size, hugging: (.center, .center))
    //self.handleView.set(master: newRect)
    
    let size = Current.graph |> self.editingView.size
    let newRect = self.canvas.bounds.withInsetRect(ofSize: size, hugging: (.center, .center))
    
    self.canvas.master = newRect
    self.draw(in: newRect)

  }
  
  var b: NSKeyValueObservation!
  
  override func loadView() {

    twoDView = Sprite2DView(frame:initialFrame )
    twoDView.layer.borderWidth = 1.0
    twoDView.scene?.scaleMode = .resizeFill
  
    
    canvas = CanvasViewport(frame: initialFrame, element: twoDView)
    
    view = UIView(frame: initialFrame)
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SpriteScaffViewController.tap)))
    view.addSubview ( canvas )
    
    //self.handleView.handler = handleChange(master:position:)
    //self.handleView.completed = handleCompletion(master:positions:)
    canvas.masterChanged = self.handleChange
  }
  
  func handleChange( master: CGRect)
  {
    self.handleChange(master: master, position: (.center, .center))
    // Create New Mod
  }
  
  
  func handleChange( master: CGRect, position: Position2D)
  {
    
    // Create New Model &  // Find Orirgin
    // Setting up our interior vie
    (Current.graph.grid, Current.graph.edges) = (master.size, Current.graph.edges) |> self.editingView.build
    let size = Current.graph |> self.editingView.size
    let newRect = (master, size, position) |> centeredRect
    
    self.draw(in: newRect)

  }
  
  func handleCompletion( master : CGRect, positions: Position2D)
  {
    // Create New Model
    (Current.graph.grid, Current.graph.edges) = (master.size, Current.graph.edges) |> self.editingView.build
    let size = Current.graph |> self.editingView.size
    let  newRect = (master, size, positions) |> centeredRect
    
    // TODO
    self.canvas.master = newRect
    }
  
  func layout(with size: CGSize, at offset:CGPoint)
  {
//    let deltaToScrollCenter = CGVector.zero
//    scrollView.contentOffset = deltaToScrollCenter + offset
    
  }
  
  // newRect a product of the Bounding Box + a generated size + a position
  func draw(in newRect: CGRect) {
    
    // Create New Model &  // Find Origin

    let pointToSprite = translateToCGPointInSKCoordinates(from: canvas.canvas.frame, to: twoDView.frame)
    let viewOrigin = (newRect.bottomLeft) |> pointToSprite
    let graphOrigin = Current.graph |> editingView.origin
    let o2 = (viewOrigin, graphOrigin |> asNegatedVector) |> moveByVector
    
    // Create Geometry
    let moveAll = o2.asVector() |> move(by:) |> curry(map) // function to move all individual elements
    let b = Current.graph |> self.editingView.composite >>> moveAll
    
    /// Add UI Elements to test layout
    
    
    // Set & Redraw Geometry
    self.twoDView.redraw(b) // + dude  )
    
    
    
    /// Add UI Elements to test layout
    
    
    
    //
    // testView.frame = newRect
    //
    
    /// OVERRIDING THE MASTER
    //self.handleView.set(master: newRect)
  }
  
  

  @objc func tap(g: UIGestureRecognizer)
  {
    // if insideTGyg`1``1`q`1q`q1
    if self.canvas.master.contains(
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
    let rectS = self.canvas.master |> rectToSprite
    //let nede = ( tS, Current.graph |> editingView.origin >>> negatedVector)
    //  |> moveByVector
    let p = (tS, rectS) |> viewSpaceToModelSpace
    
    // Properly models concern
    let editBoundaries = Current.graph |> editingView.grid2D ///
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
    let z = (mRect, self.canvas.master.origin.asVector()) |> moveByVector
    let cellRectValue = z |> rectToSprite
    let y = self.canvas.master.midY |> yToSprite
    let flippedRect = (cellRectValue, y )  |> mirrorVertically
    // flipped rect is situated in sprite kit space
    
    Current.graph.edges = editingView.selectedCell(indices, Current.graph.grid, Current.graph.edges)
    
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

