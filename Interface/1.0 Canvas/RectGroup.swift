//
//  HandleGroup.swift
//  CanvasTester
//
//  Created by Justin Smith  on 12/15/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import UIKit
import SwiftUI
import ComposableArchitecture
import Singalong

struct RectGroupTesterUI : UIViewControllerRepresentable {
  typealias UIViewControllerType = RectGroupTesterVC

  /// Creates a `UIViewController` instance to be presented.
  func makeUIViewController(context: Context) -> RectGroupTesterVC {
    RectGroupTesterVC(
      store: Store(initialState:
        RectGroupState(rect: CGRect(30, 90, 200, 200), handleBoundary:  CGRect(20, 50, 300, 400)),
                   reducer: rectGroupReducer.debug(), environment: RectGroupEnvironment()))
  }

  /// Updates the presented `UIViewController` (and coordinator) to the latest
  /// configuration.
  func updateUIViewController(_ uiViewController: RectGroupTesterVC, context: Context) {
    
  }
  
}

struct RectGroupState : Equatable {
  var rect : CGRect
  var handles : HandleGroupState
  var handleBoundary : CGRect
  init(rect: CGRect, handleBoundary: CGRect) {
    self.rect = rect
    self.handleBoundary = handleBoundary
    self.handles = HandleGroupState(
      top:BoundedState(boundary: handleBoundary,
                       handle: HandleState(point: rect.topCenter)),
      bottom:BoundedState(boundary: handleBoundary,
        handle: HandleState(point: rect.bottomCenter)),
      
      left:BoundedState(boundary: handleBoundary,
                       handle: HandleState(point: rect.centerLeft)),
      right:BoundedState(boundary: handleBoundary,
                          handle: HandleState(point: rect.centerRight))
    )
  }
}

public enum RectGroupAction {
  case handles(HandleGroupAction)
}
public struct RectGroupEnvironment { }

let symetricalPullReducer =  Reducer<RectGroupState, RectGroupAction, RectGroupEnvironment>{(state: inout RectGroupState, action: RectGroupAction, env: RectGroupEnvironment) -> Effect<RectGroupAction,Never> in
    switch action{
      
    case
    .handles(.top(.handle(.didMoveFinger))),
    .handles(.top(.handle(.didLetGo))):
      state.handles.bottom.handle.point.y = state.handles.bottom.handle.point.y-state.handles.top.handle.delta.dy
    case
    .handles(.bottom(.handle(.didMoveFinger))),
    .handles(.bottom(.handle(.didLetGo))):
      state.handles.top.handle.point.y = state.handles.top.handle.point.y-state.handles.bottom.handle.delta.dy
    case
    .handles(.left(.handle(.didMoveFinger))),
    .handles(.left(.handle(.didLetGo))):
      state.handles.right.handle.point.x = state.handles.right.handle.point.x-state.handles.left.handle.delta.dx
    case
    .handles(.right(.handle(.didMoveFinger))),
    .handles(.right(.handle(.didLetGo))):
      state.handles.left.handle.point.x = state.handles.left.handle.point.x-state.handles.right.handle.delta.dx
      
    default:
      break
    }
   return .none
}

import Geo
let rectGroupReducer = Reducer<RectGroupState, RectGroupAction, RectGroupEnvironment>.combine(
   handleGroupReducer.pullback(state: \.handles, action: /RectGroupAction.handles, environment: {_ in HandleGroupEnvironment()} ),
  symetricalPullReducer,
  Reducer{(state: inout RectGroupState, action: RectGroupAction,env: RectGroupEnvironment) -> Effect<RectGroupAction,Never> in
    switch action{
      
    case
    .handles(.top(.handle(.didMoveFinger))),
    .handles(.top(.handle(.didLetGo))),
    .handles(.bottom(.handle(.didMoveFinger))),
    .handles(.bottom(.handle(.didLetGo))):
      state.rect.origin.y = state.handles.top.handle.point.y
      state.rect.size.height = state.handles.bottom.handle.point.y - state.handles.top.handle.point.y
      state.handles.left.handle.point = state.rect.centerLeft
      state.handles.right.handle.point = state.rect.centerRight
      
    case
    .handles(.left(.handle(.didMoveFinger))),
    .handles(.left(.handle(.didLetGo))),
    .handles(.right(.handle(.didMoveFinger))),
    .handles(.right(.handle(.didLetGo))):
      state.rect.origin.x = state.handles.left.handle.point.x
      state.rect.size.width = abs(state.handles.left.handle.point.x - state.handles.right.handle.point.x)
      state.handles.top.handle.point = state.rect.topCenter
      state.handles.bottom.handle.point = state.rect.bottomCenter
      
    case .handles(.top(.timerUpdate)):
      if state.handles.top.status.1 == .above {
        let delta = state.handles.top.status.2
        state.rect.origin.y = state.handles.top.handle.point.y + delta.dy
        state.rect.size.height = state.handles.bottom.handle.point.y - state.handles.top.handle.point.y + abs(delta.dy)
        state.handles.bottom.handle.point += -delta
      }
      
      
    case .handles(.bottom(.timerUpdate)):
      if state.handles.bottom.status.1 == .below {
        let delta = state.handles.bottom.status.2
        state.rect.size.height = abs(state.handles.bottom.handle.point.y - state.handles.top.handle.point.y) + abs(delta.dy)
        state.rect.origin.y = state.handles.bottom.handle.point.y + delta.dy - state.rect.size.height

        state.handles.top.handle.point += -delta
      }
      
    case .handles(.left(.timerUpdate)):
      if state.handles.left.status.0 == .leftOf {
        let delta = state.handles.left.status.2
        state.rect.origin.x = state.handles.left.handle.point.x + delta.dx
        state.rect.size.width = state.handles.right.handle.point.x - state.handles.left.handle.point.x + abs(delta.dx)
        state.handles.right.handle.point += -delta
      }
      
    case .handles(.right(.timerUpdate)):
      if state.handles.right.status.0 == .rightOf {
        let delta = state.handles.right.status.2
        state.rect.origin.x = state.handles.left.handle.point.x + delta.dx
        state.rect.size.width = state.handles.right.handle.point.x - state.handles.left.handle.point.x + abs(delta.dx)
        state.handles.right.handle.point += -delta
      }
      
    default:
      break
    }
   return .none
}
)

import Combine

class RectGroupTesterVC : UIViewController {
  var store : Store<RectGroupState,RectGroupAction>
   var viewStore : ViewStore<RectGroupState,RectGroupAction>
  private var cancellables: Set<AnyCancellable> = []
  var topDriver : BoundedHandleDriver!
  var bottomDriver : BoundedHandleDriver!
  var leftDriver : BoundedHandleDriver!
  var rightDriver : BoundedHandleDriver!
  
  private var rect = NoHitView()

  init(store: Store<RectGroupState,RectGroupAction>) {
    self.store = store
   self.viewStore = ViewStore(self.store)
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    addBorder(view: rect, width: 3.0, color: #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1))
    view.addSubview(rect)
   topDriver = BoundedHandleDriver(store: store.scope(state: { $0.handles.top }, action: { .handles(.top($0)) }), view: self.view, boundaryColor: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1))
   bottomDriver = BoundedHandleDriver(store: store.scope(state: { $0.handles.bottom }, action: { .handles(.bottom($0)) }), view: self.view, boundaryColor: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1))
   leftDriver = BoundedHandleDriver(store: store.scope(state: { $0.handles.left }, action: { .handles(.left($0)) }), view: self.view, boundaryColor: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1))
   rightDriver = BoundedHandleDriver(store: store.scope(state: { $0.handles.right }, action: { .handles(.right($0)) }), view: self.view, boundaryColor: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1))
    
   
   self.viewStore.publisher.rect
      .sink{ [weak self] in
      guard let self = self else { return }
      self.rect.frame = $0
   }.store(in: &self.cancellables)
  }
}
