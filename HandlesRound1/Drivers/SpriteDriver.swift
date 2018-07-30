//
//  SpriteDriver.swift
//  HandlesRound1
//
//  Created by Justin Smith on 6/16/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import CoreGraphics
import Singalong
import Layout
import Geo
import Graphe
import BlackCricket

class SpriteDriver : Driver {
  
  var uiPointToSprite : ((CGPoint)->CGPoint)!
  var uiRectToSprite : ((CGRect)->CGRect)!
  var scaleObserver : NotificationObserver!
  
  public init(mapping: [GraphEditingView] )
  {
    editingView = mapping[0]
    loadedViews = mapping
    initialFrame = Current.screen
    
    twoDView = Sprite2DView(frame:initialFrame )
    //twoDView.layer.borderWidth = 1.0
    twoDView.scene?.scaleMode = .resizeFill
    
    twoDView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SpriteDriver.tap)))
    
    scaleObserver = NotificationObserver(
      notification: scaleChangeNotification,
      block: { [weak self] in
      self!.twoDView.scale = $0
        print("      ------    SCALE CHANGED TO ", $0, " ------ ")
    })
  }
  
  var _previousOrigin = (ui:CGPoint.zero, sprite:CGPoint.zero)
  
  func layout(origin: CGPoint) {
    print("#Beg-Layout Origin")
    let heightVector = unitY * (Current.graph |> self.editingView.size).height * Current.scale
    
    print("given origin", origin)
    print("new origin", uiPointToSprite(origin)  - heightVector )
    self._previousOrigin = (origin, uiPointToSprite(origin)  - heightVector )
    
    self.twoDView.mainNode.position = uiPointToSprite(origin)  - heightVector
    print("#End-Layout Origin")

  }
  
  var _previousSize = CGSize.zero
  /// Handler for Selection Size Changed
  ///
  /// Checks if newSize should be redrawn
  func layout(size: CGSize) {
    print("#Beg-Layout Size")

    // Create New Model &  // Find Orirgin
    // Setting up our interior vie)
    
    if size != _previousSize {
      // Set & Redraw Geometry
      self._layout(size: size)
      //self.twoDView.draw(newRect)
    }
    self._previousSize = size
    print("#End-Layout Size")
  }
  
  private func _layout(size: CGSize)
  {
    let geom = Current.graph |> self.editingView.composite
    self.twoDView.redraw(geom)
  }
  
  var _previousSetRect : CGRect { get { return CGRect(origin: _previousOrigin.ui, size:_previousSize) }}
  
  var size : CGSize {
    get {
      return (Current.graph |> self.editingView.size) * Current.scale
    }
  }
  
  func build(for viewportSize: CGSize) -> CGSize {
    print("#Beg-Build Simple")
    return self.build(for:viewportSize, atScale: Current.scale)
    print("#End-Build Simple")

  }
  
  func build(for viewportSize: CGSize, atScale scale: CGFloat) -> CGSize {
    print("#Beg-Build Scale")

    let modelspaceSize_input = viewportSize / scale
    let roundedModelSize = modelspaceSize_input.rounded(places: 5)
    
    let s3 = roundedModelSize |> self.editingView.size3(Current.graph)
    (Current.graph.grid, Current.graph.edges) = self.editingView.build(s3, Current.graph.edges)
    let modelSpaceSize_output =  Current.graph |> self.editingView.size
    return modelSpaceSize_output * twoDView.scale
    print("#End-Build Scale")

  }
  
  var editingView : GraphEditingView
  var loadedViews : [GraphEditingView]
  var twoDView : Sprite2DView
  var content : UIView { return self.twoDView }
  
  // Eventually dependency injected
  var initialFrame : CGRect
  
  func bind(to uiRect: CGRect)
  {
    print("#Beg-Bind")
    self.uiPointToSprite = translateToCGPointInSKCoordinates(from: uiRect, to: twoDView.frame)
    self.uiRectToSprite = translateToCGRectInSKCoordinates(from: uiRect, to: twoDView.frame)
    print("#End-Bind")
  }
  
  
  // MARK: TAP ITEMS...
  @objc func tap(g: UIGestureRecognizer)
  {
    // if insideTGyg
    if _previousSetRect.contains(
      g.location(ofTouch: 0, in: self.twoDView)
      ) {
      highlightCell(touch: g.location(ofTouch: 0, in: self.twoDView))
      print("TOuch")
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
    //      buildFromScratch()
    self._layout(size: _previousSize)

  }
  
  private var swapIndex2 = 0

 
  

  
    func highlightCell (touch: CGPoint) {
  
      let scale = twoDView.scale; #warning("weird access of twoDView.scale")

  
      // Properly Controllers concern
      let tS = touch |> uiPointToSprite
      let rectS = self._previousSetRect |> uiRectToSprite
      
      let p = (tS, rectS) |> viewSpaceToModelSpace
      let scaledP = p * 1/scale
      // Properly models concern
      let editBoundaries = Current.graph |> editingView.grid2D ///
      let toGridIndices = editBoundaries |> curry(pointToGridIndices) >>>  handleTupleOptionWith
  
      // Get Model Indices
      let indices = (scaledP |> toGridIndices)
      // indices is something lik (0, 1)
      // or (1, 2)
  
  
      // Get Model Rect
      let mRect = (indices, editBoundaries) |> modelRect
      // mRect is something like (0.0, 30.0, 100.0, 100.0)
      // (0.0, 0.0, 100.0, 30.0)
      
      let scaledMRect = mRect.scaled(by: scale)
      
      let yToSprite = { self.uiPointToSprite!(CGPoint(0, $0)) }  >>> { return $0.y }
  
      // bring model rect into the real world!
      //let mRect2 = mRect.scaled(by: 1/self.twoDView.scale)
      let z = (scaledMRect, self._previousOrigin.ui.asVector() ) |> moveByVector
      let cellRectValue = z |> uiRectToSprite
      let y = _previousSetRect.midY |> yToSprite
      let flippedRect = (cellRectValue, y )  |> mirrorVertically
      // flipped rect is situated in sprite kit space
  
      Current.graph.edges = editingView.selectedCell(indices, Current.graph.grid, Current.graph.edges)
  
      self._layout(size: _previousSize)
      self.twoDView.addTempRect(rect: flippedRect, color: .white)
    }
  
  
  
  
  
  // MARK: ...TAP ITEMS

}



