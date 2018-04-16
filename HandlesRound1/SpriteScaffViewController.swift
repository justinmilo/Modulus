//
//  TestViewController.swift
//  HandlesRound1
//
//  Created by Justin Smith on 1/27/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit








import SpriteKit


func zurry<B>(_ g: ()->B ) -> B
{
  return g()
}
func flip<A, C>(_ f: @escaping (A) -> () -> C) -> () -> (A) -> C {
  return { { a in f(a)() } }
}

let negatedVector = zurry(flip(CGPoint.asVector)) >>> zurry(flip(CGVector.negated))





class SpriteScaffViewController : UIViewController {
  // View and Model
  var twoDView : Sprite2DView!
  var handleView : HandleViewRound1!
  var rootView : UIView!
  var scrollView : UIScrollView!
  
  let graph : ScaffGraph
  
  // Drawing pure function
  var editingView : GraphEditingView
  var loadedViews : [GraphEditingView]
  
  // Eventually dependency injected
  var initialFrame : CGRect
  
  init(graph: ScaffGraph, mapping: [GraphEditingView] )
  {
    self.graph = graph
    
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
    //let size = self.graph |> self.editingView.size
    //let newRect = self.view.bounds.withInsetRect(ofSize: size, hugging: (.center, .center))
    //self.handleView.set(master: newRect)
    
    let size = self.graph |> self.editingView.size
    let newRect = self.handleView.bounds.withInsetRect(ofSize: size, hugging: (.center, .center))
    self.handleView.set(master: newRect)
    self.draw(in: newRect)

  }
  
  var b: NSKeyValueObservation!
  
  override func loadView() {
    let originZeroFrame = CGPoint.zero + CGSize(width:372, height:500)
    
    rootView = UIView(frame: originZeroFrame)
    rootView.layer.borderColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor
    rootView.layer.borderWidth = 1.0
    
    scrollView = UIScrollView(frame: initialFrame)
    scrollView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    scrollView.layer.borderColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1).cgColor
    scrollView.layer.borderWidth = 1.0
    scrollView.addSubview(rootView)
    scrollView.contentSize = rootView.bounds.size
    scrollView.showsVerticalScrollIndicator = true
    scrollView.showsHorizontalScrollIndicator = true
    
    
    
    twoDView = Sprite2DView(frame:
      //originZeroFrame) 
       CGPoint.zero + CGSize( 1000, 1000) )
    twoDView.layer.borderColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1).cgColor
    twoDView.layer.borderWidth = 1.0
    
    handleView = HandleViewRound1(frame: originZeroFrame,
                                  outerBounds: originZeroFrame.insetBy(dx: 30, dy: 30),
                                  master: originZeroFrame.insetBy(dx: 60, dy: 60),
                                  scrollView: self.scrollView,
                                  rootView: self.rootView,
                                  cameraNode: twoDView.cameraNode
    )
    handleView.layer.borderColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1).cgColor
    handleView.layer.borderWidth = 1.0
    
    
   [twoDView, handleView].forEach{ v in rootView.addSubview(v) }
    
    view = UIView(frame: initialFrame)
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SpriteScaffViewController.tap)))
    view.addSubview ( scrollView )
    
//    b = view.observe(\UIView.safeAreaInsets, options: NSKeyValueObservingOptions.new) { (a, b) in
//      print("From the observe!", self.view.safeAreaInsets)
//      self.scrollView.contentInset.bottom = b.newValue!.bottom + 4
//      //self.scrollView.contentSize = self.rootView.bounds.size.applying(edgeInsets: b.newValue!)
//    }
    
    self.handleView.handler =    {
      master, positions in
      
      
       // Create New Model &  // Find Orirgin
      (self.graph.grid, self.graph.edges) = (master.size, self.graph.edges) |> self.editingView.build
      let size = self.graph |> self.editingView.size
      let newRect = (master, size, positions) |> centeredRect
      
      self.draw(in: newRect)

    }
    
    self.handleView.completed = {
      master, positions in
      // Create New Model
      (self.graph.grid, self.graph.edges) = (master.size, self.graph.edges) |> self.editingView.build
      let size = self.graph |> self.editingView.size
      let  newRect = (master, size, positions) |> centeredRect
      
      self.handleView.set(master: newRect )
    }
    
  }
  
  // newRect a product of the Bounding Box + a generated size + a position
  func draw(in newRect: CGRect) {
    // overriding whatever the position is
    //let newRect = self.view.bounds.withInsetRect(ofSize: newRect.size, hugging: (.center, .center))
    
    
    self.twoDView.cameraNode.position = newRect.center
    
    let b = self.graph |> self.editingView.composite // >>> moop
    
    // Set & Redraw Geometry
    self.twoDView.redraw( b )
    
    
    /// OVERRIDING THE MASTER
    //self.handleView.set(master: newRect)
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
    //let nede = ( tS, self.graph |> editingView.origin >>> negatedVector)
    //  |> moveByVector
    let p = (tS, rectS) |> viewSpaceToModelSpace
    
    // Properly models concern
    let editBoundaries = self.graph |> editingView.grid2D ///
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
    
    self.graph.edges = editingView.selectedCell(indices, self.graph.grid, self.graph.edges)
    
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

