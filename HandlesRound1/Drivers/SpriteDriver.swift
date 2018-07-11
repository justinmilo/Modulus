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
  
  public init(mapping: [GraphEditingView] )
  {
    editingView = mapping[0]
    loadedViews = mapping
    initialFrame = Current.screen
    
    twoDView = Sprite2DView(frame:initialFrame )
    //twoDView.layer.borderWidth = 1.0
    twoDView.scene?.scaleMode = .resizeFill
    
    scaleObserver = NotificationObserver(
      notification: scaleChangeNotification,
      block: { [weak self] in
      self!.twoDView.scale = $0
        print("      ------    SCALE CHANGED TO ", $0, " ------ ")
    })
  }
  
  var _previousOrigin = (CGPoint.zero, CGPoint.zero)
  
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
      let geom = Current.graph |> self.editingView.composite
      self.twoDView.redraw(geom)
      //self.twoDView.draw(newRect)
    }
    self._previousSize = size
    print("#End-Layout Size")
  }
  
  var size : CGSize
  {
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
    print("#End-Bind")
  }
  
  var uiPointToSprite : ((CGPoint)->CGPoint)!
  
  var scaleObserver : NotificationObserver!
}
