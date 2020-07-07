//
//  CanvasSelection.swift
//  CanvasTester
//
//  Created by Justin Smith  on 12/22/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import UIKit

public struct CanvasSelectionState : Equatable {
  internal var scroll: AreaOfInterestState
  var handles: RectGroupState
  init(frame: CGRect, rect: CGRect, handleBoundary: CGRect) {
    
    self.handles = RectGroupState(rect: rect, handleBoundary: handleBoundary)
    
    let grow = GrowState(
      read: ReadScrollState(
        contentSize: frame.size,
        contentOffset: CGPoint(0,0),
        rootContentFrame: frame.size.asRect(),
        areaOfInterest: rect,
        zoomScale: 1.0),
      drag: .none,
      zoom: .none)
    let centered = CenteredGrowState(portSize: frame.size,
                                                    grow: grow,
                                                    currentScale:1.0 ,
                                                    setter: .none)
    self.scroll = AreaOfInterestState(centered: centered)
  }
}
extension CanvasSelectionState {
  public var canvasFrame : CGRect { self.scroll.centered.grow.read.rootContentFrame }
  public var interimZoom : CGFloat { self.scroll.centered.grow.read.zoomScale }
}
extension CanvasSelectionState {
  public var scale : CGFloat  {
    get { self.scroll.scale }
    set {
      self.scroll.scale = newValue
      self.handles.rect = self.scroll.viewAreaOfInterest
      self.handles.handles.top.handle.point = self.handles.rect.topCenter
      self.handles.handles.bottom.handle.point = self.handles.rect.bottomCenter
      self.handles.handles.left.handle.point = self.handles.rect.centerLeft
      self.handles.handles.right.handle.point = self.handles.rect.centerRight
    }
  }
  public var selection : CGRect  {
    get { self.scroll.scrollAreaofInterest }
    set {
      self.scroll.scrollAreaofInterest = newValue
      self.handles.rect = self.scroll.viewAreaOfInterest
      self.handles.handles.top.handle.point = self.handles.rect.topCenter
      self.handles.handles.bottom.handle.point = self.handles.rect.bottomCenter
      self.handles.handles.left.handle.point = self.handles.rect.centerLeft
      self.handles.handles.right.handle.point = self.handles.rect.centerRight
    }
  }
  public var selectionView : CGRect {
    get { self.scroll.viewAreaOfInterest }
    set {
      self.scroll.viewAreaOfInterest = newValue
      self.handles.rect = newValue
      self.handles.handles.top.handle.point = self.handles.rect.topCenter
      self.handles.handles.bottom.handle.point = self.handles.rect.bottomCenter
      self.handles.handles.left.handle.point = self.handles.rect.centerLeft
      self.handles.handles.right.handle.point = self.handles.rect.centerRight
    }
  }

}

public enum CanvasSelectionAction {
  case scroll(AreaOfInterestAction)
  case handles(RectGroupAction)
}

public struct CanvasSelectionEnvironment {
}


import ComposableArchitecture

let contenSRPullback : Reducer<CanvasSelectionState,CanvasSelectionAction, CanvasSelectionEnvironment> = contentScrollReducer.pullback(state: \CanvasSelectionState.scroll, action: /CanvasSelectionAction.scroll, environment: { _ in AreaOfInterestEnvironment() } )
let rectGRPullback : Reducer<CanvasSelectionState,CanvasSelectionAction, CanvasSelectionEnvironment>  = rectGroupReducer.pullback(state: \.handles, action: /CanvasSelectionAction.handles, environment: { _ in RectGroupEnvironment() })

let canvasSelectionReducer =  Reducer<CanvasSelectionState,CanvasSelectionAction, CanvasSelectionEnvironment>
   .combine(
      contenSRPullback,
      rectGRPullback,
   Reducer{ (state: inout CanvasSelectionState, action: CanvasSelectionAction, env: CanvasSelectionEnvironment) -> Effect<CanvasSelectionAction,Never> in
       switch action {
       case .scroll(.scroll(.grow(.onZoomBegin))):
         state.handles.handles.top.handle.hidden = true
         state.handles.handles.bottom.handle.hidden = true
         state.handles.handles.left.handle.hidden = true
         state.handles.handles.right.handle.hidden = true
       case .scroll(.scroll(.grow(.onZoomEnd))):
        state.handles.handles.top.handle.hidden = false
        state.handles.handles.bottom.handle.hidden = false
        state.handles.handles.left.handle.hidden = false
        state.handles.handles.right.handle.hidden = false
       default: break
       }
      return .none
    },
Reducer{ (state: inout CanvasSelectionState, action: CanvasSelectionAction, env: CanvasSelectionEnvironment) in
    switch action {
    case .scroll(_):
      state.handles.rect = state.scroll.viewAreaOfInterest
      state.handles.handles.top.handle.point = state.handles.rect.topCenter
      state.handles.handles.bottom.handle.point = state.handles.rect.bottomCenter
      state.handles.handles.left.handle.point = state.handles.rect.centerLeft
      state.handles.handles.right.handle.point = state.handles.rect.centerRight
    case .handles(_):
      state.scroll.viewAreaOfInterest = state.handles.rect
    }
    return .none
}
)

import Combine
import Singalong

public class CanvasViewport : UIView {
  var store : Store<CanvasSelectionState,CanvasSelectionAction>
  private var topDriver : BoundedHandleDriver!
  private var bottomDriver : BoundedHandleDriver!
  private var leftDriver : BoundedHandleDriver!
  private var rightDriver : BoundedHandleDriver!
  var rootContent : UIView
  private var rect = NoHitView()
  private var handleOutline = NoHitView()

  init(frame: CGRect, store: Store<CanvasSelectionState,CanvasSelectionAction>, rootContent: UIView) {
    self.store = store
    self.rootContent = rootContent
    super.init(frame: frame)
    
    let newStore = self.store.scope(state: {$0.scroll}, action: {.scroll($0)})
    let aoiView = AreaOfInterestView(frame: frame, store: newStore, rootContent: rootContent)
    self.addSubview(aoiView)

    topDriver = BoundedHandleDriver(store: store.scope(state: { $0.handles.handles.top }, action: { .handles(.handles(.top($0))) }), view: self)
    bottomDriver = BoundedHandleDriver(store: store.scope(state: { $0.handles.handles.bottom }, action: { .handles(.handles(.bottom($0))) }), view: self)
    leftDriver = BoundedHandleDriver(store: store.scope(state: { $0.handles.handles.left }, action: { .handles(.handles(.left($0))) }), view: self)
    rightDriver = BoundedHandleDriver(store: store.scope(state: { $0.handles.handles.right }, action: { .handles(.handles(.right($0))) }), view: self)
    
    self.clipsToBounds = true
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}


class CanvasSelectionVC : UIViewController {
  var store : Store<CanvasSelectionState,CanvasSelectionAction>

   init(store: Store<CanvasSelectionState, CanvasSelectionAction>) {
      self.store = store
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    
    let frame = self.view.frame.size.asRect()
   let aoiView = CanvasViewport(frame: frame, store: self.store, rootContent: NoHitView())
    self.view.addSubview(aoiView)
    }
  }


