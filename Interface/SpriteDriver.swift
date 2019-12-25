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
import GrapheNaked
import BlackCricket
import ComposableArchitecture




struct SpriteState<Holder:GraphHolder> {
  init(scale : CGFloat, sizePreferences: [CGFloat], boundingRect: CGRect, graph: Holder, editingViews: [GenericEditingView<Holder>] ){
    self.scale = scale
    self.sizePreferences = sizePreferences
    self.frame = Changed(boundingRect)
    self.graph = graph
    self.editingView = editingViews[0]
    self.loadedViews = editingViews
    let viewportSize = frame.value.size
    let modelspaceSize_input = viewportSize / scale
    let roundedModelSize = modelspaceSize_input.rounded(places: 5)
    // ICAN : Pass *Holder* into editingView.size3 Function to get a func from Size to Size3
    let s3 = roundedModelSize |> self.editingView.size3(self.graph)
    // ICAN : set *Holder* grid and edgs from editingView.build Function
    (self.graph.grid, self.graph.edges) = self.editingView.build( self.sizePreferences,
      s3, self.graph.edges)
    //                           ICAN : Pass *Holder* into editingView.size Function to get a CGSize back
    let modelSpaceSize_output =  self.graph |> self.editingView.size
    self.currentSize = modelSpaceSize_output * scale
    self.layout = PositionedRect(ofSize: self.currentSize, aligned: (.center, .center), initialRect: boundingRect)
    self.origin = Changed(boundingRect.origin)
    self.size = Changed(boundingRect.size)
  }
  var scale : CGFloat
  public var sizePreferences : [CGFloat]
  public var frame : Changed<CGRect> {
    didSet {
      if let newFrame = frame.changed {
        self.origin.update(newFrame.origin)
        self.size.update(newFrame.size)
      }
    }
  }
  fileprivate var origin: Changed<CGPoint> {
    didSet {
      if let _ = origin.changed {
        layout.layout(in: self.frame.value)
      }
    }
  }
  fileprivate var size : Changed<CGSize> {
    didSet {
      if let newSize = size.changed {
        let bestFit = (newSize, self.scale) |> build
        self.currentSize = bestFit
        layout.container = self.currentSize
        layout.layout(in: self.frame.value)
      }
    }
  }
  let graph : Holder
  private(set) var layout : PositionedRect
  private(set) var currentSize : CGSize
  let editingView : GenericEditingView<Holder>
  let loadedViews : [GenericEditingView<Holder>]
  
  func build(for viewportSize: CGSize, atScale scale: CGFloat) -> CGSize {

    let modelspaceSize_input = viewportSize / scale
    let roundedModelSize = modelspaceSize_input.rounded(places: 5)
    
    // ICAN : Pass *Holder* into editingView.size3 Function to get a func from Size to Size3
    let s3 = roundedModelSize |> self.editingView.size3(self.graph)

    // ICAN : set *Holder* grid and edgs from editingView.build Function
    (self.graph.grid, self.graph.edges) = self.editingView.build( self.sizePreferences,
      s3, self.graph.edges)

    //                           ICAN : Pass *Holder* into editingView.size Function to get a CGSize back
    let modelSpaceSize_output =  self.graph |> self.editingView.size
    return modelSpaceSize_output * scale
  }
}

protocol SpriteDriverDelegate : class {
  func didAddEdge()
}

public protocol GraphHolder : class {
  associatedtype Content : Codable
  var id : String { get }
  var edges : [Edge<Content>] { get set }
  var grid : GraphPositions { get set }
  
}

import Combine
class SpriteDriver<Holder:GraphHolder> {
  
  var uiPointToSprite : ((CGPoint)->CGPoint)!
  var uiRectToSprite : ((CGRect)->CGRect)!
  var id: String?
  weak var delgate : SpriteDriverDelegate?
  public var spriteView : Sprite2DView
  var content : UIView { return self.spriteView }
  let store: Store<SpriteState<Holder>, Never>
  var cancellable : AnyCancellable!
  
  // Eventually dependency injected
  var initialFrame : CGRect
  
  public init(screenSize: CGRect, store: Store<SpriteState<Holder>, Never>) {
    self.store = store
    initialFrame = screenSize
    
    spriteView = Sprite2DView(frame:initialFrame )
    
    spriteView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SpriteDriver.tap)))
    
 
    self.cancellable = store.$value.sink {
      [weak self] state in
      guard let self = self else { return }
      self.spriteView.scale = state.scale
      
      if let origin = state.layout.origin.changed {
        let heightVector = unitY * (self.store.value.graph |> state.editingView.size).height * self.store.value.scale
        self._previousOrigin = (origin, self.uiPointToSprite(origin)  - heightVector )
        self.spriteView.mainNode.position = self.uiPointToSprite(origin)  - heightVector
      }
      
      if let size = state.layout.size.changed {
        

        // Create New Model &  // Find Orirgin
        // Setting up our interior vie)
        
          // Set & Redraw Geometry
          self._layout(size: size)
        //self.twoDView.draw(newRect)
      }
    }
    
    
    
  }
  
  var _previousOrigin = (ui:CGPoint.zero, sprite:CGPoint.zero)
  
  var _previousSize = CGSize.zero
  /// Handler for Selection Size Changed
  ///
  
  private func _layout(size: CGSize)
  {
    // ICAN : Pass *Holder* into editingView.composite Function to get a Composite Struct back
    let geom = self.store.value.graph |> self.store.value.editingView.composite
    self.spriteView.redraw(geom)
  }
  
  var _previousSetRect : CGRect { get { return CGRect(origin: _previousOrigin.ui, size:_previousSize) }}
  
  var size : CGSize {
    get {
      // ICAN : Pass *Holder* into editingView.size Function to get a CGSize back
      return (self.store.value.graph |> self.store.value.editingView.size) * self.store.value.scale
    }
  }
  
  
  
  func bind(to uiRect: CGRect) {
    self.uiPointToSprite = translateToCGPointInSKCoordinates(from: uiRect, to: spriteView.frame)
    self.uiRectToSprite = translateToCGRectInSKCoordinates(from: uiRect, to: spriteView.frame)
  }
  
  
  // MARK: TAP ITEMS...
  @objc func tap(g: UIGestureRecognizer) {
    // if insideTGyg
    if _previousSetRect.contains(
      g.location(ofTouch: 0, in: self.spriteView)
      ) {
      highlightCell(touch: g.location(ofTouch: 0, in: self.spriteView))
      print("TOuch")
    }
    else {
      changeCompositeStyle()
    }
  }
  
  private var swapIndex = 0
  func changeCompositeStyle ()
  {
//    swapIndex = swapIndex+1 >= loadedViews.count ? 0 : swapIndex+1
//    self.editingView = loadedViews[swapIndex]
//    //      buildFromScratch()
//    self._layout(size: _previousSize)
//
  }
  
  private var swapIndex2 = 0
  
  func highlightCell (touch: CGPoint) {
        
    // Properly Controllers concern
    let tS = touch |> uiPointToSprite
    let rectS = self._previousSetRect |> uiRectToSprite
    
    let p = (tS, rectS) |> viewSpaceToModelSpace
    let scaledP = p * 1/self.store.value.scale

    // Properly models concern
    // ICAN : Pass *Holder* into editingView.grid2D Function to get Graph Positions 2D Sorted back
    let editBoundaries = self.store.value.graph |> self.store.value.editingView.grid2D ///
    let curried = curry(pointToGridIndices)
    let handledCurried = curried >>>  handleTupleOptionWith
    let toGridIndices = handledCurried(editBoundaries)
    
    // Get Model Indices
    let indices = (scaledP |> toGridIndices)
    // indices is something lik (0, 1)
    // or (1, 2)
    
    
    // Get Model Rect
    let mRect = (indices, editBoundaries) |> modelRect
    // mRect is something like (0.0, 30.0, 100.0, 100.0)
    // (0.0, 0.0, 100.0, 30.0)
    
    let scaledMRect = mRect.scaled(by: self.store.value.scale)
    
    let yToSprite = { self.uiPointToSprite!(CGPoint(0, $0)) }  >>> { return $0.y }
    
    // bring model rect into the real world!
    //let mRect2 = mRect.scaled(by: 1/self.twoDView.scale)
    let z = (scaledMRect, self._previousOrigin.ui.asVector() ) |> moveByVector
    let cellRectValue = z |> uiRectToSprite
    let y = _previousSetRect.midY |> yToSprite
    let flippedRect = (cellRectValue, y )  |> mirrorVertically
    // flipped rect is situated in sprite kit space
    
    self.store.value.graph.edges = self.store.value.editingView.selectedCell(indices, self.store.value.graph.grid, self.store.value.graph.edges)
    delgate?.didAddEdge()
    
    self._layout(size: _previousSize)
    self.spriteView.addTempRect(rect: flippedRect, color: .white)
  }
  
  // MARK: ...TAP ITEMS

}



