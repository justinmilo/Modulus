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


public struct SpriteState<Holder:GraphHolder> {
  init(screen: CGRect, scale : CGFloat, sizePreferences: [CGFloat], graph: Holder, editingViews: [GenericEditingView<Holder>] ){
    spriteFrame = screen
    self.scale = scale
    self.sizePreferences = sizePreferences
    self.graph = graph
    self.editingView = editingViews[0]
    self.loadedViews = editingViews
    //                           ICAN : Pass *Holder* into editingView.size Function to get a CGSize back
    let boundingRect = CGRect(origin: .zero, size: .zero )
    self.frame = Changed(boundingRect)
    self.aligned = (.center, .center)
    self.layoutFrame = boundingRect
    self.layoutOrigin = Changed(.zero)
    self.layoutSize = Changed(.zero)

    self.modelSpaceAllowableSize = Changed(boundingRect.size  * self.scale)
  }
  
  public var spriteFrame: CGRect
  public var scale : CGFloat
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
  
  fileprivate var modelSpaceAllowableSize : Changed<CGSize>
  public let graph : Holder
  var sizePreferences : [CGFloat]
  public var modelSpaceSize : CGSize { self.graph |> self.editingView.size }
  public var viewSpaceSize : CGSize { modelSpaceSize * self.scale }
  let editingView : GenericEditingView<Holder>
  let loadedViews : [GenericEditingView<Holder>]
  public var nodeOrigin : CGPoint {
    CGPoint(x: self.layoutOrigin.value.x,
            y: self.spriteFrame.height - self.viewSpaceSize.height - self.layoutOrigin.value.y)
  }
  public var aligned : (HorizontalPosition, VerticalPosition)
   
  private(set) var layoutOrigin : Changed<CGPoint>
  private(set) var layoutSize : Changed<CGSize>
  private(set) var layoutFrame : CGRect
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
  
  
  var id: String?
  weak var delgate : SpriteDriverDelegate?
  public var spriteView : Sprite2DView
  var content : UIView { return self.spriteView }
  let store: Store<SpriteState<Holder>, Never>
  var cancellable : AnyCancellable!
  
  public init(store: Store<SpriteState<Holder>, Never>) {
    self.store = store
    
    spriteView = Sprite2DView(frame:store.value.spriteFrame )
 
    self.cancellable = store.$value.sink {
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
          let geom = self.store.value.graph |> self.store.value.editingView.composite
          self.spriteView.redraw(geom)
      }
    }
    
    
    
  }
  
 
  
  
  
  
  // MARK: ...TAP ITEMS

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
