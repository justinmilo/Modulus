//
//  TentView.swift
//  TentApp
//
//  Created by Justin Smith Nussli on 11/27/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import UIKit
import SwiftUI
import Interface
@testable import Modular
import ComposableArchitecture

struct QuadState {
  var scale : CGFloat =  1.0
  public var sizePreferences : [CGFloat] = [100.0]
  
  
  var selectionSizes = (plan: CGRect(50, 50, 300, 400),
                        rotated: CGRect(50, 50, 300, 400),
                        front: CGRect(50, 50, 300, 400),
                        side: CGRect(50, 50, 300, 400))
  
  var planState: InterfaceState<TentGraph>
  var rotatedPlanState: InterfaceState<TentGraph>
  var frontState: InterfaceState<TentGraph>
  var sideState: InterfaceState<TentGraph>
  
  init () {
    planState = InterfaceState(
    sizePreferences: self.sizePreferences,
    scale: self.scale,
    windowBounds: UIScreen.main.bounds,
    selection: selectionSizes.plan)
    rotatedPlanState = InterfaceState(
    sizePreferences: self.sizePreferences,
    scale: self.scale,
    windowBounds: UIScreen.main.bounds,
    selection: selectionSizes.rotated)
    frontState = InterfaceState(
    sizePreferences: self.sizePreferences,
    scale: self.scale,
    windowBounds: UIScreen.main.bounds,
    selection: selectionSizes.front)
    sideState = InterfaceState(
    sizePreferences: self.sizePreferences,
    scale: self.scale,
    windowBounds: UIScreen.main.bounds,
    selection: selectionSizes.side)
  }
  
  
}

enum QuadAction {
  case plan(InterfaceAction<TentGraph>)
  var plan: InterfaceAction<TentGraph>? {
    get {
      guard case let .plan(value) = self else { return nil }
      return value
    }
    set {
      guard case .plan = self, let newValue = newValue else { return }
      self = .plan(newValue)
    }
  }
  case rotated(InterfaceAction<TentGraph>)
  var rotated: InterfaceAction<TentGraph>? {
    get {
      guard case let .rotated(value) = self else { return nil }
      return value
    }
    set {
      guard case .rotated = self, let newValue = newValue else { return }
      self = .rotated(newValue)
    }
  }
  case front(InterfaceAction<TentGraph>)
  var front: InterfaceAction<TentGraph>? {
    get {
      guard case let .front(value) = self else { return nil }
      return value
    }
    set {
      guard case .front = self, let newValue = newValue else { return }
      self = .front(newValue)
    }
  }
  case side(InterfaceAction<TentGraph>)
  var side: InterfaceAction<TentGraph>? {
    get {
      guard case let .side(value) = self else { return nil }
      return value
    }
    set {
      guard case .side = self, let newValue = newValue else { return }
      self = .side(newValue)
    }
  }
}

let quadReducer =  combine(
  pullback(interfaceReducer, value: \QuadState.planState, action: \QuadAction.plan),
  pullback(interfaceReducer, value: \QuadState.rotatedPlanState, action: \QuadAction.rotated),
  pullback(interfaceReducer, value: \QuadState.frontState, action: \QuadAction.front),
  pullback(interfaceReducer, value: \QuadState.sideState, action: \QuadAction.side),
  {(state: inout QuadState, action: QuadAction) -> [Effect<QuadAction>] in
    
    return []
})


import Singalong
struct QuadTentView : UIViewControllerRepresentable {
  
  let store : Store<QuadState, QuadAction> = Store(
    initialValue: QuadState(),
    reducer:  quadReducer
      //|> logging
  )
  
  
  func makeUIViewController(context: UIViewControllerRepresentableContext<QuadTentView>) -> UINavigationController {
    
    func controller(_ vc: UIViewController, _ titled : String)->UIViewController{
       vc.title = titled
      return  vc
    }
    
    let graph = TentGraph()
    
    let storeOne = self.store.view(value: {$0.planState}, action: { .plan($0) })
    let one = tentVC(store: storeOne, title: "Top", graph: graph, tentMap: tentPlanMap)
    let store2 = self.store.view(value: {$0.rotatedPlanState}, action: { .rotated($0) })
    let two = tentVC(store: store2, title: "Rotated Plan", graph: graph, tentMap: tentPlanMapRotated)
     let store3 = self.store.view(value: {$0.frontState}, action: { .front($0) })
    let three = tentVC( store: store3, title: "Front", graph: graph, tentMap: tentFrontMap)
    let store4 = self.store.view(value: {$0.sideState}, action: { .side($0) })
    let four =  tentVC(store: store4, title: "Side", graph: graph, tentMap: tentSideMap)

    let delegate = QuadDriver(upper: [one, two], lower: [three, four])

    let a = embedInNav(delegate.group)

    return a
    
    
  }
  
  func updateUIViewController(_ uiViewController: UINavigationController, context: UIViewControllerRepresentableContext<QuadTentView>) {
    
  }

  typealias UIViewControllerType = UINavigationController
  
  
}


