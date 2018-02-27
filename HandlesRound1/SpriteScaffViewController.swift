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
  
  func highlightCell (touch: CGPoint) {
    func spriteRect(b: CGRect, height: CGFloat) -> CGRect
    {
      let r = CGRect(x:b.x ,
                     y: height - b.y,
                     width: b.width,
                     height: -b.height).standardized
      return r
    }
    func spriteY(y: CGFloat, height: CGFloat) -> CGFloat
    {
      return height - y
    }
    func spritePoint(point: CGPoint, height: CGFloat) -> CGPoint {
      return CGPoint(x: point.x, y: height - point.y )
    }
    
    func mirrorVertically(point: CGPoint, along y: CGFloat) -> CGPoint {
      let delta = y - point.y
      let newOriginY = y + delta
      return CGPoint(x: point.x, y: newOriginY)
    }
    func mirrorVertically(rect: CGRect, along y: CGFloat) -> CGRect {
      let delta = y - rect.origin.y
      let newOriginY = y + delta
      print(delta)
      print(newOriginY)
      let newRect = CGRect(x: rect.x, y: newOriginY, width: rect.width, height: -rect.height)
      print(newRect)
      print(newRect.standardized)
      return newRect.standardized
    }
    
    
    let pointToCell : (CGPoint) -> CGRect
    let viewToModel : (CGPoint, CGRect) -> (CGPoint) = {
      return CGPoint( $0.x - $1.origin.x, $0.y - $1.origin.y)
    }
    let gridTap : (CGPoint, GraphPositions2DSorted) -> (Int?, Int?) =
    {
      func middle( check: CGFloat, values: [CGFloat] ) -> Int?
      {
        return Array(zip(values, values.dropFirst())).index{ (a1, a2) -> Bool in
          print(a1, check, a2 )
          return a1 < check && check < a2

        }
      }
      
      return ( ($0.x, $1.pX) |> middle,
               ($0.y, $1.pY) |> middle)
    }
    let cellRect : ((Int, Int), GraphPositions2DSorted) -> (CGRect) = {
      i, pos in
      return CGPoint(pos.pX[i.0], pos.pY[i.1]) + CGPoint(pos.pX[i.0 + 1], pos.pY[i.1 + 1])
    }
    func handleTupleOptionOrFail<A>(a:(Optional<A>, Optional<A>)) -> (A,A) {
      if let v1 = a.0, let v2 = a.1 {
        return (v1, v2)
      }
      else {
        fatalError()
      }
    }
    let frontGraphSorted : (GraphPositions) -> GraphPositions2DSorted = {
      return GraphPositions2DSorted.init(pX: $0.pX, pY: $0.pZ)
    }
    
    pointToCell = { p1 in
      print("-")
      let y = (p1, self.twoDView.bounds.height) |> spritePoint
      let rect = ( self.handleView.lastMaster, self.twoDView.bounds.height) |> spriteRect
      let p = viewToModel( y, rect)
      let c = (p, self.graph.grid |> frontGraphSorted) |> gridTap >>> handleTupleOptionOrFail
      let x = (c, self.graph.grid |> frontGraphSorted) |> cellRect
      let z = (x, self.handleView.lastMaster.origin.asVector()) |> moveByVector
      return z
    }
    
    let cellRectValue = (pointToCell(touch), self.twoDView.bounds.height) |> spriteRect
    let y = (self.handleView.lastMaster.midY, self.twoDView.bounds.height) |> spriteY
    let line = Line(start: CGPoint(0, y), end: CGPoint(400, y))
    let point = Line(start: (cellRectValue.origin, unitX * 10) |> moveByVector,
                    end:  (cellRectValue.origin, unitX * -10) |> moveByVector)
    twoDView.addChildR(line);  twoDView.addChildR(point);
    let flippedRect = (cellRectValue, y ) |> mirrorVertically
    
    func addTempRect( rect: CGRect, color: UIColor) {
      let globalLabel = SKShapeNode(rect: rect )
      globalLabel.fillColor = color
      self.twoDView.scene?.addChild(globalLabel)
      globalLabel.alpha = 0.0
      let fadeInOut = SKAction.sequence([
        .fadeAlpha(to: 0.3, duration: 0.2),
        .fadeAlpha(to: 0.0,duration: 0.4)])
      globalLabel.run(fadeInOut, completion: {
        print("HHHHH")
      })
    }
    
    // t raddTempRect(rect: cellRectValue, color: .white)
    addTempRect(rect: flippedRect, color: .yellow)
    
  }
  
}
extension CGRect : Geometry {
  var position : CGPoint {
    get {
      return origin
    }
    set {
      self.origin = newValue
    }
  }
}
