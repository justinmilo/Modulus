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

struct HandleGroupTesterUI : UIViewControllerRepresentable {
  typealias UIViewControllerType = HandleGroupTesterVC

  /// Creates a `UIViewController` instance to be presented.
  func makeUIViewController(context: Context) -> HandleGroupTesterVC {
    HandleGroupTesterVC(
      store: Store(initialState:
        HandleGroupState(
          top:BoundedState(boundary: CGRect(20, 50, 300, 300),
                           handle: HandleState(point: CGPoint(100,50))),
          bottom:BoundedState(boundary: CGRect(20, 50, 300, 300),
                              handle: HandleState(point: CGPoint(100,200))),
          left:BoundedState(boundary: CGRect(20, 50, 300, 300),
                            handle: HandleState(point: CGPoint(50,100))),
          right:BoundedState(boundary: CGRect(20, 50, 300, 300),
                             handle: HandleState(point: CGPoint(200,100)))
        ),
                   reducer: handleGroupReducer.debug(), environment: HandleGroupEnvironment()))
  }

  /// Updates the presented `UIViewController` (and coordinator) to the latest
  /// configuration.
  func updateUIViewController(_ uiViewController: HandleGroupTesterVC, context: Context) {
    
  }
  
}

struct HandleGroupState : Equatable {
  var top : BoundedState
  var bottom : BoundedState
  var left : BoundedState
  var right : BoundedState
}

public enum HandleGroupAction {
  case top(BoundedAction)
  case bottom(BoundedAction)
  case left(BoundedAction)
  case right(BoundedAction)
}

public struct HandleGroupEnvironment { }

let handleGroupReducer = Reducer<HandleGroupState,HandleGroupAction, HandleGroupEnvironment>
   .combine(
      boundedReducer.pullback(state: \.top, action: /HandleGroupAction.top, environment: {_ in BoundedEnvironment()} ),
      boundedReducer.pullback(state: \.bottom, action: /HandleGroupAction.bottom, environment: {_ in BoundedEnvironment()} ),
      boundedReducer.pullback(state: \.left, action: /HandleGroupAction.left, environment: {_ in BoundedEnvironment()} ),
      boundedReducer.pullback(state: \.right, action: /HandleGroupAction.right, environment: {_ in BoundedEnvironment()} ),
      Reducer{(state: inout HandleGroupState, action: HandleGroupAction, environment: HandleGroupEnvironment) -> Effect<HandleGroupAction, Never> in
      switch action{
      case .top(.handle(.didMoveFinger)):
        state.top.handle.point.x = state.top.handle.previousLocation.x
      case .bottom(.handle(.didMoveFinger)):
        state.bottom.handle.point.x = state.bottom.handle.previousLocation.x
      case .left(.handle(.didMoveFinger)):
        state.left.handle.point.y = state.left.handle.previousLocation.y
      case  .right(.handle(.didMoveFinger)):
        state.right.handle.point.y = state.right.handle.previousLocation.y
        
      case (.top(.handle(.didPress))):
        state.top.boundary.size.height = state.bottom.handle.point.y - state.top.boundary.minY
        state.top.boundary.origin.y = state.top.boundary.minY
        
      case (.bottom(.handle(.didPress))):
        state.bottom.boundary.size.height = state.bottom.boundary.maxY - state.top.handle.point.y 
        state.bottom.boundary.origin.y = state.top.handle.point.y
        
      case (.left(.handle(.didPress))):
        state.left.boundary.size.width = abs(state.left.boundary.minX - state.right.handle.point.x)
        state.left.boundary.origin.x = state.left.boundary.minX
        
      case (.right(.handle(.didPress))):
        state.right.boundary.size.width = state.right.boundary.maxX - state.left.handle.point.x
        state.right.boundary.origin.x = state.left.handle.point.x
      default:
        break
      }
         return .none
  }
)

class HandleGroupTesterVC : UIViewController {
  var store : Store<HandleGroupState,HandleGroupAction>
  var topDriver : BoundedHandleDriver!
  var bottomDriver : BoundedHandleDriver!
  var leftDriver : BoundedHandleDriver!
  var rightDriver : BoundedHandleDriver!
  init(store: Store<HandleGroupState,HandleGroupAction>) {
    self.store = store
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    topDriver = BoundedHandleDriver(store: store.scope(state: { $0.top }, action: { .top($0) }), view: self.view, boundaryColor: #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1))
    bottomDriver = BoundedHandleDriver(store: store.scope(state: { $0.bottom }, action: { .bottom($0) }), view: self.view, boundaryColor: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1))
    leftDriver = BoundedHandleDriver(store: store.scope(state: { $0.left }, action: { .left($0) }), view: self.view, boundaryColor: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1))
    rightDriver = BoundedHandleDriver(store: store.scope(state: { $0.right }, action: { .right($0) }), view: self.view, boundaryColor: #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1))

  }
}
