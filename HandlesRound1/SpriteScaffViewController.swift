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
import Graphe

class EGView : UIView {
  
}


import SpriteKit

public class SpriteScaffViewController : UIViewController {
  // View and Model
  var twoDView : Sprite2DView!
  var canvas : CanvasViewport!
  var outline : UIView!
  
  // Drawing pure function
  var editingView : GraphEditingView
  var loadedViews : [GraphEditingView]
  
  
  // Eventually dependency injected
  var initialFrame : CGRect
  
  public init(mapping: [GraphEditingView] )
  {
    editingView = mapping[0]
    loadedViews = mapping
    initialFrame = Current.screen
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  override public func viewDidAppear(_ animated: Bool) {
    // Set view upon initial loading
    buildFromScratch()
  }
  override public func loadView() {
    twoDView = Sprite2DView(frame:initialFrame )
    twoDView.layer.borderWidth = 1.0
    twoDView.scene?.scaleMode = .resizeFill
  
    canvas = CanvasViewport(frame: initialFrame, element: twoDView)
    canvas.selectionOriginChanged = self.originChange
    canvas.selectionSizeChanged = self.sizeChange
    canvas.didEndEdit = self.editEnded
    
  
    outline = EGView()
    outline.layer.borderColor = UIColor.blue.cgColor
    outline.layer.borderWidth = 3.0
    self.canvas.canvas.addSubview(outline)
    
    view = UIView(frame: initialFrame)
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SpriteScaffViewController.tap)))
    view.addSubview ( canvas )
  }
  /// Handler for Edit End
  func editEnded() {
    self.handleCompletion(master: self.canvas.master, positions: (.bottom, .left))
  }
  
  func buildFromScratch()
  {
    let size = Current.graph |> self.editingView.size
    let newRect = self.canvas.bounds.withInsetRect(ofSize: size, hugging: (.center, .center))
    
    self.canvas.master = newRect
    self.originChange(origin: newRect.origin)
    self.draw(in: newRect)
  }
  /// Handler for Selection Origin Changed
  func originChange( origin: CGPoint) {
  
    let editOrigin = self.editOrigin(newRect: canvas.master)
    self.twoDView.mainNode.position = editOrigin
  }
  
  var _previousRect = CGRect.zero
  /// Handler for Selection Size Changed
  ///
  /// Checks if newSize should be redrawn
  func sizeChange( size: CGSize) {
    let position : Position2D = (.center, .center)
    // Create New Model &  // Find Orirgin
    // Setting up our interior vie
    let s3 = size |> self.editingView.size3(Current.graph)
    (Current.graph.grid, Current.graph.edges) = self.editingView.build(s3, Current.graph.edges)
    let size = Current.graph |> self.editingView.size
    let newRect = (self.canvas.master, size, position) |> centeredRect
    
    if newRect.size != _previousRect.size {
      self.draw(in: newRect)
    }
    if newRect.origin != _previousRect.origin {
      self.originChange(origin: newRect.origin)
    }
    _previousRect = newRect
  }
  
  func handleCompletion( master : CGRect, positions: Position2D)
  {
    // Create New Model
    let size = Current.graph |> self.editingView.size
    let  newRect = (master, size, positions) |> centeredRect
    
    self.canvas.animateMaster(to: newRect)
  }
  
  /// Origin in SK Coordinates based on graphs origin
  func editOrigin(newRect: CGRect) -> CGPoint
  {
    let pointToSprite: (CGPoint) -> CGPoint = translateToCGPointInSKCoordinates(from: canvas.canvas.frame, to: twoDView.frame)
    let viewOrigin : CGPoint = (newRect.bottomLeft) |> pointToSprite
    let graphOrigin : CGPoint = Current.graph |> editingView.origin
    let editOrigin : CGPoint = (viewOrigin, graphOrigin|>asNegatedVector) |> moveByVector
    return editOrigin
  }
  
  /// Draw func by redrawing new composite from curent graph
  // newRect a product of the Bounding Box + a generated size + a position
  func draw(in newRect: CGRect) {
    // Create New Model
    let b = Current.graph |> self.editingView.composite
    // Set & Redraw Geometry
    self.twoDView.redraw(b) // + dude  )
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


