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


public struct SpriteState<Holder:GraphHolder> : Equatable {
   public static func == (lhs: SpriteState<Holder>, rhs: SpriteState<Holder>) -> Bool {
      // TODO : Make sure this is right
      if lhs.graph == rhs.graph { return true } else { return false }
//      spriteFrame
//      scale
//      graph
//      sizePreferences
//      layoutOrigin
//      layoutSize
//      layoutFrame
//      modelSpaceAllowableSize
   }
   
  init(spriteFrame: CGRect, scale : CGFloat, sizePreferences: [CGFloat], graph: Holder, editingViews: [GenericEditingView<Holder>] ){
    self.spriteFrame = spriteFrame
    self.scale = scale
    self.sizePreferences = sizePreferences
    self.graph = graph
    self.editingView = editingViews[0]
    self.loadedViews = editingViews
    self.frame = Changed(.zero)
    self.aligned = (.center, .center)
    self.layoutFrame = .zero
    self.layoutOrigin = Changed(.zero)
    self.layoutSize = Changed(.zero)
    self.modelSpaceAllowableSize = Changed(.zero)
  }
  public var frame : Changed<CGRect> {
    didSet {
      if let newFrame = frame.changed {
        self.modelSpaceAllowableSize.update(newFrame.size / self.scale)
        if let newSize = self.modelSpaceAllowableSize.changed {

          let roundedModelSize = newSize.rounded(places: 5)
          // ICAN : Pass *Holder* into editingView.size3 Function to get a func from Size to Size3
          let s3 = roundedModelSize |> self.editingView.size3(self.graph)
          // ICAN : set *Holder* grid and edgs from editingView.build Function
          (self.graph.grid, self.graph.edges) = self.editingView.build( self.sizePreferences,
                                                                        s3, self.graph.edges)
          //                           ICAN : Pass *Holder* into editingView.size Function to get a CGSize back
        }
        layoutFrame = newFrame.withInsetRect(ofSize: viewSpaceSize, hugging: aligned)
        layoutOrigin.update(layoutFrame.origin)
        layoutSize.update(layoutFrame.size)
      }
    }
  }
  public var spriteFrame: CGRect
  public var scale : CGFloat
  public let graph : Holder
  var sizePreferences : [CGFloat]
  let editingView : GenericEditingView<Holder>
  let loadedViews : [GenericEditingView<Holder>]
  public var modelSpaceSize : CGSize { self.graph |> self.editingView.size }
  public var viewSpaceSize : CGSize { modelSpaceSize * self.scale }
  public var nodeOrigin : CGPoint {
    CGPoint(x: self.layoutOrigin.value.x,
            y: self.spriteFrame.height - self.viewSpaceSize.height - self.layoutOrigin.value.y)
  }
  public var aligned : (HorizontalPosition, VerticalPosition)
  
  fileprivate var modelSpaceAllowableSize : Changed<CGSize>
  private(set) var layoutOrigin : Changed<CGPoint>
  private(set) var layoutSize : Changed<CGSize>
  private(set) var layoutFrame : CGRect
  
  func uiPointToSprite(_ point: CGPoint) -> CGPoint {
    //translateToCGPointInSKCoordinates(from: self.spriteFrame, to: self.spriteFrame)
    let skPointFunc : (CGPoint)->SKPoint = translate(from: self.spriteFrame, toSKCoordIn: self.spriteFrame)
    //translateToCGRectInSKCoordinates(from: self.spriteFrame, to: self.spriteFrame)
    //return    CGPoint(x: point.x, y: self.spriteFrame.height - point.y)
    return skPointFunc(point).rawValue
  }
  func uiRectToSprite(_ rect: CGRect) -> CGRect {
    //translateToCGPointInSKCoordinates(from: self.spriteFrame, to: self.spriteFrame)
    let skPointFunc : (CGRect)->SKRect = translate(from: self.spriteFrame, toSKCoordIn: self.spriteFrame)
    //translateToCGRectInSKCoordinates(from: self.spriteFrame, to: self.spriteFrame)
    //return    CGPoint(x: point.x, y: self.spriteFrame.height - point.y)
    return skPointFunc(rect).rawValue
  }
  
  var rectAnimations : CGRect?
}

public enum SpriteAction {
  case spriteTapped(location: CGPoint)
  case endRectAnimation
}
struct SpriteEnvironment { }

func spriteReducer<Holder:GraphHolder>()->Reducer<SpriteState<Holder>, SpriteAction, SpriteEnvironment>{
   
   Reducer{
      (state: inout SpriteState<Holder>, action: SpriteAction, environment:SpriteEnvironment ) -> Effect<SpriteAction, Never> in
  switch action {
  case .endRectAnimation:
    state.rectAnimations = nil

    return .none
  case .spriteTapped(location: let touch):
     
    // Properly Controllers concern
    let tS = touch |> state.uiPointToSprite
    let rectS = state.layoutFrame |> state.uiRectToSprite
    
    let viewSpaceToModelSpace : (CGPoint, CGRect, CGFloat) -> CGPoint = { (viewPoint, viewModelFrame, scale) -> CGPoint in
      CGPoint(viewPoint.x - viewModelFrame.origin.x, viewPoint.y - viewModelFrame.origin.y) * (1/scale)
    }
    let p = (tS, rectS, state.scale) |> viewSpaceToModelSpace
    // Properly models concern
    // ICAN : Pass *Holder* into editingView.grid2D Function to get Graph Positions 2D Sorted back
    let editBoundaries = state.graph |> state.editingView.grid2D
    let indicesOpt = pointToGridIndices(editBoundaries, p)
    guard let opt1 = indicesOpt.0, let opt2 = indicesOpt.1 else {
      return .none
    }
    let indices = (opt1, opt2)
    
    // Get Model Rect
    let mRect = (indices, editBoundaries) |> modelRect
    // mRect is something like (0.0, 30.0, 100.0, 100.0)
    // (0.0, 0.0, 100.0, 30.0)
    
    let scaledMRect = mRect.scaled(by: state.scale)
//
    let copyToSprite = state.uiPointToSprite
    let yToSprite = { copyToSprite(CGPoint(0, $0)) }  >>> { return $0.y }
    
    // bring model rect into the real world!
    let mRect2 = mRect.scaled(by: 1/state.scale)
//    let z = (scaledMRect, self._previousOrigin.ui.asVector() ) |> moveByVector
    let z = (scaledMRect, state.layoutOrigin.value.asVector() ) |> moveByVector
    let cellRectValue = z |> state.uiRectToSprite
    let y = state.layoutFrame.midY |> yToSprite
    let flippedRect = (cellRectValue, y )  |> mirrorVertically
    // flipped rect is situated in sprite kit space
    
    state.graph.edges = state.editingView.selectedCell(indices, state.graph.grid, state.graph.edges)
    state.rectAnimations = flippedRect

    return Effect(value: .endRectAnimation)
      
  }
      }
}

public protocol GraphHolder : class, Equatable {
  associatedtype Content : Codable
  var id : String { get }
  var edges : [Edge<Content>] { get set }
  var grid : GraphPositions { get set }
  
}

import Combine
public class SpriteDriver<Holder:GraphHolder> {
  
  
  var id: String?
  public var spriteView : Sprite2DView
  var content : UIView { return self.spriteView }
  let store: Store<SpriteState<Holder>, SpriteAction>
   let viewStore: ViewStore<SpriteState<Holder>, SpriteAction>

  var cancellables : Set<AnyCancellable> = []
  var dontRefire : Bool = false

  public init(store: Store<SpriteState<Holder>, SpriteAction>) {
    self.store = store
   self.viewStore = ViewStore(self.store)
    
    spriteView = Sprite2DView(frame:viewStore.spriteFrame )
 
    spriteView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SpriteDriver.tap)))

    viewStore.publisher.sink {
      [weak self] state in
      guard let self = self else { return }
      
      self.spriteView.frame = state.spriteFrame
      self.spriteView.scale = state.scale
      
      if let origin = state.layoutOrigin.changed {
        let heightVector = unitY * state.viewSpaceSize.height // * self.store.value.scale
        self.spriteView.mainNode.position = state.nodeOrigin
      }
      
      if let size = state.layoutSize.changed {
          // Set & Redraw Geometry
          let geom = self.viewStore.graph |> self.viewStore.editingView.composite
          self.spriteView.redraw(geom)
      }
      
      if let rect = state.rectAnimations {
        self.spriteView.addTempRect(rect: rect, color: .white)
        let geom = self.viewStore.graph |> self.viewStore.editingView.composite
        self.spriteView.redraw(geom)
      }
      
      
    }.store(in: &self.cancellables)
  }
  
 
  
  
  
  
  // MARK: ...TAP ITEMS
  // MARK: TAP ITEMS...
  @objc func tap(g: UIGestureRecognizer) {
    self.viewStore.send(.spriteTapped(location:  g.location(ofTouch: 0, in: self.spriteView) ))
  }
//
//  private var swapIndex = 0
//  func changeCompositeStyle ()
//  {
//    swapIndex = swapIndex+1 >= loadedViews.count ? 0 : swapIndex+1
//    self.editingView = loadedViews[swapIndex]
//    //      buildFromScratch()
//    self._layout(size: _previousSize)
//
//  }
//
//  private var swapIndex2 = 0
  
}


/*
extension SpriteState : CustomStringConvertible {
  public var description: String {
"""
  SpriteState:
    screenSize \(self.screenSize.rounded(places: 2)),
    spriteFrame \(self.spriteFrame.rounded(places: 2)),
    scale \(self.scale.rounded(places: 2)),
    frame \(self.frame.changed.map{ _ in "hasChanged"} ?? "hasn't Changed")
    frame \(self.frame.value.rounded(places: 2))
    modelSpaceAllowableSize \(self.modelSpaceAllowableSize.changed.map{ _ in "hasChanged"} ?? "hasn't Changed")
    modelSpaceAllowableSize \(self.modelSpaceAllowableSize.value.rounded(places: 2))
    layoutOrigin \(self.layoutOrigin.changed.map{ _ in "hasChanged"} ?? "hasn't Changed")
    layoutOrigin \(self.layoutOrigin.value.rounded(places: 2))
    layoutSize \(self.layoutSize.changed.map{ _ in "hasChanged"} ?? "hasn't Changed")
    layoutSize \(self.layoutSize.value.rounded(places: 2))

    
    modelSpaceSize \(self.modelSpaceSize.rounded(places: 2)),
    viewSpaceSize \(self.viewSpaceSize.rounded(places: 2)),
    nodeOrigin \(self.nodeOrigin),
"""
  }
}
*/
