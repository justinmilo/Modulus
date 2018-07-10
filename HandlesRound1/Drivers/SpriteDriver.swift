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

class SpriteDriver : Driver {
  
  func set(scale: CGFloat) {
    twoDView.scale = scale
  }
  
  public init(mapping: [GraphEditingView] )
  {
    editingView = mapping[0]
    loadedViews = mapping
    initialFrame = Current.screen
    
    twoDView = Sprite2DView(frame:initialFrame )
    twoDView.layer.borderWidth = 1.0
    twoDView.scene?.scaleMode = .resizeFill
    
    scaleObserver = NotificationObserver(
      notification: scaleChangeNotification,
      block: { [weak self] in
      self!.twoDView.scale = $0
    })
  }
  
  func layout(origin: CGPoint) {
    
    print("given origin", origin)
    print("new origin", uiPointToSprite(origin) )
    
    let heightVector = unitY * (Current.graph |> self.editingView.size).height * twoDView.scale
    self.twoDView.mainNode.position = uiPointToSprite(origin)  - heightVector
    
  }
  
  var _previousRect = CGSize.zero
  /// Handler for Selection Size Changed
  ///
  /// Checks if newSize should be redrawn
  func layout(size: CGSize) {
    // Create New Model &  // Find Orirgin
    // Setting up our interior vie)
    
    if size != _previousRect {
      // Set & Redraw Geometry
      let geom = Current.graph |> self.editingView.composite
      self.twoDView.redraw(geom)
      //self.twoDView.draw(newRect)
    }
    self._previousRect = size
  }
  
  var size : CGSize
  {
    get {
      return Current.graph |> self.editingView.size
    }
  }
  
  func size(for viewportSize: CGSize) -> CGSize {
    
    let modelspaceSize_input = (viewportSize / twoDView.scale)
    let roundedModelSize = modelspaceSize_input.rounded(places: 5)
    
    let s3 = roundedModelSize |> self.editingView.size3(Current.graph)
    (Current.graph.grid, Current.graph.edges) = self.editingView.build(s3, Current.graph.edges)
    let modelSpaceSize_output =  Current.graph |> self.editingView.size
    return modelSpaceSize_output * twoDView.scale
  }
  
  var editingView : GraphEditingView
  var loadedViews : [GraphEditingView]
  var twoDView : Sprite2DView
  var content : UIView { return self.twoDView }
  
  // Eventually dependency injected
  var initialFrame : CGRect
  
  func bind(to uiRect: CGRect)
  {
    print(twoDView.frame, twoDView.frame)
    self.uiPointToSprite = translateToCGPointInSKCoordinates(from: uiRect, to: twoDView.frame)
  }
  
  var uiPointToSprite : ((CGPoint)->CGPoint)!
  var scaleObserver : NotificationObserver!
}
