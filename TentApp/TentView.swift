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
  
  var planState: InterfaceState<TentGraph> {
    get {
      return InterfaceState(
                            sizePreferences: self.sizePreferences,
                            scale: self.scale,
                            windowBounds: UIScreen.main.bounds,
                            selection: selectionSizes.plan)
    }
    set {
      selectionSizes.plan = newValue.selection
      scale = newValue.scale
      sizePreferences = newValue.sizePreferences
    }
  }
  var rotatedPlanState: InterfaceState<TentGraph> {
    get {
      return InterfaceState(
                            sizePreferences: self.sizePreferences,
                            scale: self.scale,
                            windowBounds: UIScreen.main.bounds,
                            selection: selectionSizes.plan)
    }
    set {
      selectionSizes.plan = newValue.selection
      scale = newValue.scale
      sizePreferences = newValue.sizePreferences
    }
  }
  
  var frontState: InterfaceState<TentGraph> {
    get {
      return InterfaceState(
                            sizePreferences: self.sizePreferences,
                            scale: self.scale,
                            windowBounds: UIScreen.main.bounds,
                            selection: selectionSizes.plan)
    }
    set {
      selectionSizes.plan = newValue.selection
      scale = newValue.scale
      sizePreferences = newValue.sizePreferences
    }
  }
    
  var sideState: InterfaceState<TentGraph> {
    get {
      return InterfaceState(
                            sizePreferences: self.sizePreferences,
                            scale: self.scale,
                            windowBounds: UIScreen.main.bounds,
                            selection: selectionSizes.plan)
    }
    set {
      selectionSizes.plan = newValue.selection
      scale = newValue.scale
      sizePreferences = newValue.sizePreferences
    }
  }
  
  
  
}

enum QuadAction {
  case interfaceAction(InterfaceAction<TentGraph>)
  var interfaceAction: InterfaceAction<TentGraph>? {
    get {
      guard case let .interfaceAction(value) = self else { return nil }
      return value
    }
    set {
      guard case .interfaceAction = self, let newValue = newValue else { return }
      self = .interfaceAction(newValue)
    }
  }
}

let quadReducer =  combine(
  pullback(interfaceReducer, value: \QuadState.planState, action: \QuadAction.interfaceAction),
  pullback(interfaceReducer, value: \QuadState.rotatedPlanState, action: \QuadAction.interfaceAction),
  pullback(interfaceReducer, value: \QuadState.frontState, action: \QuadAction.interfaceAction),
  pullback(interfaceReducer, value: \QuadState.sideState, action: \QuadAction.interfaceAction)
  )


import Singalong
struct QuadTentView : UIViewControllerRepresentable {
  
  let store : Store<QuadState, QuadAction> = Store(initialValue: QuadState(), reducer:  quadReducer |> logging)
  
  
  func makeUIViewController(context: UIViewControllerRepresentableContext<QuadTentView>) -> UINavigationController {
    
    func controller(_ vc: UIViewController, _ titled : String)->UIViewController{
       vc.title = titled
      return  vc
    }
    
    let graph = TentGraph()
    
    let storeOne = self.store.view(value: {$0.planState}, action: { .interfaceAction($0) })
    let one = tentVC(store: storeOne, title: "Top", graph: graph, tentMap: tentPlanMap)
    let store2 = self.store.view(value: {$0.rotatedPlanState}, action: { .interfaceAction($0) })
    let two = tentVC(store: store2, title: "Rotated Plan", graph: graph, tentMap: tentPlanMapRotated)
     let store3 = self.store.view(value: {$0.frontState}, action: { .interfaceAction($0) })
    let three = tentVC( store: store3, title: "Front", graph: graph, tentMap: tentFrontMap)
    let store4 = self.store.view(value: {$0.sideState}, action: { .interfaceAction($0) })
    let four =  tentVC(store: store4, title: "Side", graph: graph, tentMap: tentSideMap)

    let delegate = QuadDriver(upper: [one, two], lower: [three, four])

    let a = embedInNav(delegate.group)

    return a
    
    
  }
  
  func updateUIViewController(_ uiViewController: UINavigationController, context: UIViewControllerRepresentableContext<QuadTentView>) {
    
  }

  typealias UIViewControllerType = UINavigationController
  
  
}


