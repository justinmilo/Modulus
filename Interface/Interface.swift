//
//  ViewController.swift
//  ScrollViewGrower
//
//  Created by Justin Smith on 4/26/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit
import Geo
@testable import GrippableView
import Singalong
import Make2D
import ComposableArchitecture
import GrapheNaked




public struct InterfaceState<Holder:GraphHolder> {
  public init(
    graph: Holder,
    mapping: [GenericEditingView<Holder>],
    sizePreferences: [CGFloat],
    scale : CGFloat,
    windowBounds: CGRect,
    offset : CGPoint
  ) {
    self.windowBounds = windowBounds
    
    self.spriteState =  SpriteState(spriteFrame: windowBounds,
                                    scale : scale,
                                    sizePreferences: sizePreferences,
                                    graph: graph,
                                    editingViews: mapping )
    let currentSize = self.spriteState.viewSpaceSize
    let selection = offset + currentSize
    
    self.canvasState = CanvasSelectionState(frame: windowBounds,
                                            rect: selection,
                                            handleBoundary: windowBounds
                                              .inset(by: UIEdgeInsets(top: 120, left: 40, bottom: 100, right: 40)))
    
    self.spriteState.spriteFrame = self.canvasFrame
    self.spriteState.frame.update(self.selection)
  }
  public let windowBounds : CGRect
  public var spriteState : SpriteState<Holder>
  public var canvasState : CanvasSelectionState
}

/// Read only properties of InterfaceState
extension InterfaceState {
  public var canvasFrame : CGRect { self.canvasState.canvasFrame }
  public var canvasSize : CGSize { self.canvasState.scroll.canvasSize }
  public var canvasOffset : CGPoint { self.canvasState.scroll.canvasOffset }
}
/// Read and Write properties
extension InterfaceState {
  public var scale : CGFloat  {
    get { self.canvasState.scale }
    set {
      self.canvasState.scale = newValue
      self.spriteState.spriteFrame = self.canvasFrame
      self.spriteState.scale = newValue
      self.spriteState.frame.update(selection)
    }
  }
  public var selection : CGRect {
    get { self.canvasState.selection }
    set {
      self.canvasState.selection = newValue
      self.spriteState.spriteFrame = self.canvasFrame
      self.spriteState.frame.update(newValue)
    }
  }
  public var selectionView : CGRect {
    get { self.canvasState.selectionView }
    set {
      self.canvasState.selectionView = newValue
      self.spriteState.spriteFrame = self.canvasFrame
      self.spriteState.frame.update(selection)
    }
  }
}

extension InterfaceState {
  public var sizePreferences : [CGFloat] { get { self.spriteState.sizePreferences } set { self.spriteState.sizePreferences = newValue} }
}

public enum InterfaceAction<Holder:GraphHolder> {
  case canvasAction(CanvasSelectionAction)
  case sprite(SpriteAction)
}

import CasePathse

public func interfaceReducer<Holder:GraphHolder>(state: inout InterfaceState<Holder>, action: InterfaceAction<Holder>) -> [Effect<InterfaceAction<Holder>>] {
  let reducer =  combine (
    pullback(spriteReducer, value: \InterfaceState<Holder>.spriteState, action: /InterfaceAction<Holder>.sprite),
    pullback(canvasSelectionReducer, value: \InterfaceState<Holder>.canvasState, action: /InterfaceAction<Holder>.canvasAction),
    { (state: inout InterfaceState<Holder>, action: InterfaceAction<Holder>) -> [Effect<InterfaceAction<Holder>>] in
        switch action {
        case
            .canvasAction(.handles(.handles(.top(.timerUpdate)))),
            .canvasAction(.handles(.handles(.top(.handle(.didPress(_)))))),
            .canvasAction(.handles(.handles(.top(.handle(.animationComplete))))),
            .canvasAction(.handles(.handles(.bottom(.timerUpdate)))),
            .canvasAction(.handles(.handles(.bottom(.handle(.didPress(_)))))),
            .canvasAction(.handles(.handles(.bottom(.handle(.animationComplete))))),
            .canvasAction(.handles(.handles(.left(.timerUpdate)))),
            .canvasAction(.handles(.handles(.left(.handle(.didPress(_)))))),
            .canvasAction(.handles(.handles(.left(.handle(.animationComplete))))),
            .canvasAction(.handles(.handles(.right(.timerUpdate)))),
            .canvasAction(.handles(.handles(.right(.handle(.didPress(_)))))),
            .canvasAction(.handles(.handles(.right(.handle(.animationComplete))))),
            .canvasAction(.scroll(.scroll(.grow(.onZoomBegin)))),
            .canvasAction(.scroll(.scroll(.grow(.onZoom)))),
            .canvasAction(.scroll(.scroll(.grow(.onDragBegin)))),
            .canvasAction(.scroll(.scroll(.grow(.onDrag)))),
            .canvasAction(.scroll(.scroll(.grow(.onDragEnd)))),
            .canvasAction(.scroll(.scroll(.grow(.onDecelerate)))),
            .canvasAction(.scroll(.scroll(.grow(.onDecelerateEnd)))),
            .sprite:
              return []
        case .canvasAction(.handles(.handles(.top(.handle(.didLetGo))))),
             .canvasAction(.handles(.handles(.bottom(.handle(.didLetGo))))),
             .canvasAction(.handles(.handles(.left(.handle(.didLetGo))))),
             .canvasAction(.handles(.handles(.right(.handle(.didLetGo))))):
          state.canvasState.selection = state.spriteState.layoutFrame
          return []
        case .canvasAction(.handles(.handles(.top(.handle(.didMoveFinger(_)))))),
             .canvasAction(.handles(.handles(.bottom(.handle(.didMoveFinger(_)))))),
             .canvasAction(.handles(.handles(.left(.handle(.didMoveFinger(_)))))),
             .canvasAction(.handles(.handles(.right(.handle(.didMoveFinger(_)))))):
          state.spriteState.spriteFrame = state.canvasFrame
          state.spriteState.frame.update(state.selection)
          return []
        case .canvasAction(.scroll(.scroll(.grow(.onZoomEnd)))):
          state.spriteState.scale = state.scale
          return []
      }
  },
    { (state: inout InterfaceState<Holder>, action: InterfaceAction<Holder>) -> [Effect<InterfaceAction<Holder>>] in
        switch action {
        case  .canvasAction(.scroll(.scroll(.grow(.onZoomBegin)))),
          .canvasAction(.scroll(.scroll(.grow(.onZoom)))),
          .canvasAction(.scroll(.scroll(.grow(.onDragBegin)))),
          .canvasAction(.scroll(.scroll(.grow(.onDrag)))),
          .canvasAction(.scroll(.scroll(.grow(.onDecelerate)))):
          break
        case .canvasAction(.scroll(.scroll(.grow(.onZoomEnd)))):
          state.canvasState.scroll.centered.clip()
          state.spriteState.spriteFrame = state.canvasFrame
          state.spriteState.frame.update(state.selection)
          break
        case .canvasAction(.scroll(.scroll(.grow(.onDragEnd(_, let willDecelerate))))):
          if !willDecelerate {
            state.canvasState.scroll.centered.clip()
            state.spriteState.spriteFrame = state.canvasFrame
            state.spriteState.frame.update(state.selection)
          }
          break
        case .canvasAction(.scroll(.scroll(.grow(.onDecelerateEnd)))):
          state.canvasState.scroll.centered.clip()
          state.spriteState.spriteFrame = state.canvasFrame
          state.spriteState.frame.update(state.selection)
          break
        default:
          break
        }
        return []
    }
  )
  let effects = reducer(&state, action)
  return effects
}

import Combine
public class InterfaceController<Holder:GraphHolder> : UIViewController {
  var viewport : CanvasViewport!
  var driver : SpriteDriver<Holder>
  public let store: Store<InterfaceState<Holder>, InterfaceAction<Holder>>
  private var cancellable : AnyCancellable!
  
  public init(store: Store<InterfaceState<Holder>, InterfaceAction<Holder>> ){
    self.store = store
    self.driver = SpriteDriver(store: store.view(value: {$0.spriteState}, action: { .sprite($0) }))
    super.init(nibName: nil, bundle: nil)
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("Init with coder not implemented")
  }
   
  override public func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override public func loadView() {
    viewport = CanvasViewport(frame: store.value.windowBounds,
                              store: store.view(value: { $0.canvasState}, action: {.canvasAction($0)}),
                              rootContent: self.driver.content
    )
    
    self.view = viewport
    self.view.backgroundColor = self.driver.spriteView.scene?.backgroundColor
    
  }
  
  
  
}

